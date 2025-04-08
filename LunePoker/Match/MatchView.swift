//
//  MatchView.swift
//  LunePoker
//
//  Created by Michele Mariniello on 25/03/25.
//

import SwiftUI
import FirebaseDatabase

// Definizione della struttura Match aggiornata
struct Match: Identifiable, Codable {
    let id: UUID
    var date: Date
    var participants: [Participant] // Partecipanti con quote di ingresso
    var totalPrize: Double
    var winners: [Winner] // Vincitori con posizionamento e vincite
}

// Struttura per i partecipanti con quota d'ingresso
struct Participant: Identifiable, Codable {
    var id: UUID { playerID }
    let playerID: UUID
    var entryFee: Double
}

// Struttura per i vincitori aggiornata con posizionamento
struct Winner: Identifiable, Codable {
    var id: UUID { playerID }
    let playerID: UUID
    var position: Int // 1 = primo, 2 = secondo, ecc.
    var amount: Double
}

struct MatchView: View {
    // AppStorage per salvare le partite in modo persistente
    @AppStorage("matches") private var matchesData: Data = Data()
    
    // AppStorage per accedere ai giocatori esistenti
    @AppStorage("players") private var playersData: Data = Data()
    
    @State private var matches: [Match] = []
    @State private var players: [Player] = []
    @State private var isAddingMatch = false
    @State private var selectedMatch: Match?
    
    // Stati per l'alert di conferma eliminazione
    @State private var matchToDelete: Match?
    @State private var showDeleteAlert = false
    
    // Stato per mostrare il caricamento
    @State private var isLoading = false
    @State private var initialLoadCompleted = false
    
    var body: some View {
        ZStack {
            NavigationView {
                ZStack {
                    Color.black
                        .ignoresSafeArea(.all)
                    
                    VStack(spacing: 0) {
                        HStack {
                            Spacer()
                            Text("Partite")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Button(action: { isAddingMatch = true }) {
                                Image(systemName: "plus")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding()
                        
                        if isLoading && !initialLoadCompleted {
                            Spacer()
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.5)
                            Text("Sincronizzo le Partite...")
                                .foregroundColor(.gray)
                                .padding()
                            Spacer()
                        } else {
                            ScrollView {
                                LazyVStack(spacing: 15) {
                                    ForEach(matches.sorted(by: { $0.date > $1.date })) { match in
                                        MatchCard(match: match, players: players)
                                            .onTapGesture {
                                                selectedMatch = match
                                            }
                                            .contextMenu {
                                                Button(role: .destructive) {
                                                    matchToDelete = match
                                                    showDeleteAlert = true
                                                } label: {
                                                    Label("Delete", systemImage: "trash")
                                                }
                                            }
                                    }
                                }
                                .padding()
                            }
                        }
                    }
                    .sheet(isPresented: $isAddingMatch) {
                        AddMatchView(isPresented: $isAddingMatch, saveMatch: addMatch, players: players)
                    }
                    .sheet(item: $selectedMatch) { match in
                        EditMatchView(match: match, saveChanges: updateMatch, players: players)
                    }
                }
                .navigationBarHidden(true)
            }
            .onAppear {
                loadPlayers()
                if !initialLoadCompleted {
                    loadMatches()
                }
                setupMatchesObserver()
            }
//            .onDisappear {
//
//            }
            
            // Alert di conferma come overlay
            if showDeleteAlert, let match = matchToDelete {
                ZStack {
                    Color.black.opacity(0.3)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            showDeleteAlert = false
                            matchToDelete = nil
                        }

                    VStack {
                        Text("Conferma eliminazione")
                            .font(.headline)
                            .padding()

                        // Formattazione della data
                        let dateFormatter: DateFormatter = {
                            let formatter = DateFormatter()
                            formatter.dateStyle = .medium
                            return formatter
                        }()
                        
                        let dateString = dateFormatter.string(from: match.date)
                        
                        Text("Sei sicuro di voler eliminare la partita del \(dateString)?")
                            .padding(.horizontal)

                        HStack {
                            Button("Annulla") {
                                showDeleteAlert = false
                                matchToDelete = nil
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundStyle(.white)
                            .cornerRadius(8)

                            Button("Elimina") {
                                removeMatch(match)
                                showDeleteAlert = false
                                matchToDelete = nil
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                        .padding()
                    }
                    .frame(width: 300)
                    .background(Color.black)
                    .foregroundStyle(.white)
                    .cornerRadius(12)
                    .shadow(radius: 10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(Double(0.5)), lineWidth: 2))
                }
            }
        }
    }
    
    // Il resto delle funzioni rimane invariato ma aggiornato per Firebase
    private func addMatch(date: Date, participants: [Participant], winners: [Winner]) {
        // Calcola il montepremi totale dalla somma delle quote di ingresso
        let totalPrize = participants.reduce(0) { $0 + $1.entryFee }
        
        let newMatch = Match(id: UUID(), date: date, participants: participants, totalPrize: totalPrize, winners: winners)
        matches.append(newMatch)
        saveMatchesToFirebase()
    }
    
    private func updateMatch(updatedMatch: Match) {
        if let index = matches.firstIndex(where: { $0.id == updatedMatch.id }) {
            matches[index] = updatedMatch
            saveMatchesToFirebase()
        }
    }
    
    private func removeMatch(_ match: Match) {
        matches.removeAll { $0.id == match.id }
        saveMatchesToFirebase()
    }
    
    private func saveMatchesToFirebase() {
        isLoading = true
        FirebaseManager.shared.saveMatches(matches) { error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    print("Failed to save matches to Firebase: \(error)")
                    // Qui potresti mostrare un alert all'utente
                } else {
                    // Opzionale: fai qualcosa in caso di successo
                    print("Matches saved to Firebase successfully.")
                }
            }
        }
        // Continua a salvare anche localmente se lo desideri
        saveMatchesLocally()
    }

    private func saveMatchesLocally() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(matches)
            matchesData = data
        } catch {
            print("Failed to save matches locally: \(error)")
        }
    }
    
    private func loadMatches() {
        isLoading = true
        
        // Prima carica i dati locali
        do {
            let decoder = JSONDecoder()
            matches = try decoder.decode([Match].self, from: matchesData)
        } catch {
            print("Failed to load matches locally: \(error)")
        }
        
        // Poi carica i dati da Firebase
        FirebaseManager.shared.fetchMatches { fetchedMatches, error in
            DispatchQueue.main.async {
                self.isLoading = false
                self.initialLoadCompleted = true
                
                if let error = error {
                    print("Error fetching matches from Firebase: \(error)")
                    return
                }
                
                if let fetchedMatches = fetchedMatches {
                    // Se i dati da Firebase sono vuoti ma abbiamo dati locali,
                    // sincronizziamo quelli locali con Firebase
                    if fetchedMatches.isEmpty && !self.matches.isEmpty {
                        self.saveMatchesToFirebase()
                    } else {
                        self.matches = fetchedMatches
                        
                        // Salviamo localmente per avere i dati anche offline
                        do {
                            let encoder = JSONEncoder()
                            let data = try encoder.encode(self.matches)
                            self.matchesData = data
                        } catch {
                            print("Failed to save matches locally after fetch: \(error)")
                        }
                    }
                }
            }
        }
    }
    
    private func loadPlayers() {
        do {
            let decoder = JSONDecoder()
            players = try decoder.decode([Player].self, from: playersData)
        } catch {
            print("Failed to load players: \(error)")
        }
    }

    
    // Configurazione dell'osservatore per i dati in tempo reale
    private func setupMatchesObserver() {
        FirebaseManager.shared.observeMatches { updatedMatches in
            DispatchQueue.main.async {
                guard let updatedMatches = updatedMatches else { return }
                
                // Aggiorna i dati solo se sono cambiati
                if !self.matches.elementsEqual(updatedMatches, by: { $0.id == $1.id }) {
                    self.matches = updatedMatches
                    
                    // Aggiorna anche i dati locali
                    do {
                        let encoder = JSONEncoder()
                        let data = try encoder.encode(self.matches)
                        self.matchesData = data
                    } catch {
                        print("Failed to save updated matches locally: \(error)")
                    }
                }
                
                // Assicuriamoci che initialLoadCompleted sia true dopo la prima sincronizzazione
                if !self.initialLoadCompleted {
                    self.initialLoadCompleted = true
                    self.isLoading = false
                }
            }
        }
    }
}
#Preview {
    MatchView()
}
