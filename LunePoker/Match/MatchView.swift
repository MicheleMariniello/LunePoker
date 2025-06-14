//
//  MatchView.swift
//  LunePoker
//
//  Created by Michele Mariniello on 25/03/25.
//

import SwiftUI
import FirebaseDatabase

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
    var position: Int
    var amount: Double
}

struct MatchView: View {
    @State private var matches: [Match] = []
    @State private var players: [Player] = []
    @State private var isAddingMatch = false
    @State private var selectedMatch: Match?
    
    @State private var matchToDelete: Match?
    @State private var showDeleteAlert = false
    
    @State private var isLoading = false
    @State private var initialLoadCompleted = false
    
    var body: some View {
        ZStack {
            NavigationView {
                ZStack {
                    Color.black
                        .ignoresSafeArea(.all)
                    
                    VStack(spacing: 0) {
                        ZStack {
                            Text("Matches")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            HStack {
                                Spacer()
                                Button(action: { isAddingMatch = true }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title)
                                        .foregroundColor(.accent)
                                }
                            }
                        }
                        .padding()

                        
                        if isLoading && !initialLoadCompleted {
                            Spacer()
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.5)
                            Text("Synchronizing Matches...")
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
                if !initialLoadCompleted {
                    loadData()
                }
                setupObservers()
            }
            
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
                        Text("Confirm deletion")
                            .font(.headline)
                            .padding()
                        
                        // Formattazione della data
                        let dateFormatter: DateFormatter = {
                            let formatter = DateFormatter()
                            formatter.dateStyle = .medium
                            return formatter
                        }()
                        
                        let dateString = dateFormatter.string(from: match.date)
                        
                        Text("Are you sure you want delete the game from  \(dateString)?")
                            .padding(.horizontal)
                        
                        HStack {
                            Button("Cancel") {
                                showDeleteAlert = false
                                matchToDelete = nil
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.7))
                            .foregroundStyle(.white)
                            .cornerRadius(8)
                            
                            Button("Delete") {
                                removeMatch(match)
                                showDeleteAlert = false
                                matchToDelete = nil
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.accent)
                            .foregroundColor(.black)
                            .cornerRadius(8)
                        }
                        .padding()
                    }
                    .frame(width: 300)
                    .background(Color.black.opacity(0.9))
                    .foregroundStyle(.white)
                    .cornerRadius(12)
                    .shadow(radius: 10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(Double(0.5)), lineWidth: 2))
                }
            }
        }
    }
    
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
                } else {
                    print("Matches saved to Firebase successfully.")
                }
            }
        }
    }
    
    // Carica SOLO da Firebase (room-specific)
    private func loadData() {
        print("Caricando dati per la room corrente...")
        isLoading = true
        
        let group = DispatchGroup()
        
        // Carica players
        group.enter()
        FirebaseManager.shared.fetchPlayers { fetchedPlayers, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error fetching players from Firebase: \(error)")
                } else if let fetchedPlayers = fetchedPlayers {
                    print("Players caricati per questa room: \(fetchedPlayers.count)")
                    self.players = fetchedPlayers
                } else {
                    self.players = []
                }
                group.leave()
            }
        }
        
        // Carica matches
        group.enter()
        FirebaseManager.shared.fetchMatches { fetchedMatches, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error fetching matches from Firebase: \(error)")
                } else if let fetchedMatches = fetchedMatches {
                    print("Matches caricati per questa room: \(fetchedMatches.count)")
                    self.matches = fetchedMatches
                } else {
                    self.matches = []
                }
                group.leave()
            }
        }
        
        // Quando entrambi i caricamenti sono completi
        group.notify(queue: .main) {
            self.isLoading = false
            self.initialLoadCompleted = true
            print("Caricamento dati completato per la room corrente")
        }
    }
    
    // Configurazione degli osservatori per i dati in tempo reale
    private func setupObservers() {
        // Observer per matches
        FirebaseManager.shared.observeMatches { updatedMatches in
            DispatchQueue.main.async {
                print("Matches aggiornati per la room corrente: \(updatedMatches?.count ?? 0)")
                guard let updatedMatches = updatedMatches else {
                    self.matches = []
                    return
                }
                
                // Aggiorna i dati solo se sono cambiati
                if !self.matches.elementsEqual(updatedMatches, by: { $0.id == $1.id }) {
                    self.matches = updatedMatches
                }
                
                if !self.initialLoadCompleted {
                    self.initialLoadCompleted = true
                    self.isLoading = false
                }
            }
        }
        
        // Observer per players
        FirebaseManager.shared.observePlayers { updatedPlayers in
            DispatchQueue.main.async {
                print("Players aggiornati per la room corrente: \(updatedPlayers?.count ?? 0)")
                guard let updatedPlayers = updatedPlayers else {
                    self.players = []
                    return
                }
                
                // Aggiorna i dati solo se sono cambiati
                if !self.players.elementsEqual(updatedPlayers, by: { $0.id == $1.id }) {
                    self.players = updatedPlayers
                }
            }
        }
    }
}

#Preview {
    MatchView()
}
