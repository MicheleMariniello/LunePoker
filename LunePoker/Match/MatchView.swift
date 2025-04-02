//
//  MatchView.swift
//  LunePoker
//
//  Created by Michele Mariniello on 25/03/25.
//

import SwiftUI

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
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .ignoresSafeArea(.all)
                
                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        Text("Poker Matches")
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
                    
                    ScrollView {
                        LazyVStack(spacing: 15) {
                            ForEach(matches.sorted(by: { $0.date > $1.date })) { match in
                                MatchCard(match: match, players: players)
                                    .onTapGesture {
                                        selectedMatch = match
                                    }
                                    .contextMenu {
                                        Button(role: .destructive) {
                                            removeMatch(match)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                        .padding()
                    }
                    //                .navigationTitle("Poker Matches")
                    //                .toolbar {
                    //                    ToolbarItem(placement: .navigationBarTrailing) {
                    //                        Button(action: { isAddingMatch = true }) {
                    //                            Image(systemName: "plus")
                    //                        }
                    //                    }
                    //                }
                }
                .sheet(isPresented: $isAddingMatch) {
                    AddMatchView(isPresented: $isAddingMatch, saveMatch: addMatch, players: players)
                }
                .sheet(item: $selectedMatch) { match in
                    EditMatchView(match: match, saveChanges: updateMatch, players: players)
                }
            }
        }
        .onAppear {
            loadPlayers()
            loadMatches()
        }
    }
    
    // Funzione per aggiungere una nuova partita
    private func addMatch(date: Date, participants: [Participant], winners: [Winner]) {
        // Calcola il montepremi totale dalla somma delle quote di ingresso
        let totalPrize = participants.reduce(0) { $0 + $1.entryFee }
        
        let newMatch = Match(id: UUID(), date: date, participants: participants, totalPrize: totalPrize, winners: winners)
        matches.append(newMatch)
        saveMatches()
    }
    
    // Funzione per aggiornare una partita
    private func updateMatch(updatedMatch: Match) {
        if let index = matches.firstIndex(where: { $0.id == updatedMatch.id }) {
            matches[index] = updatedMatch
            saveMatches()
        }
    }
    
    // Funzione per rimuovere una partita
    private func removeMatch(_ match: Match) {
        matches.removeAll { $0.id == match.id }
        saveMatches()
    }
    
    // Funzione per salvare le partite in AppStorage
    private func saveMatches() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(matches)
            matchesData = data
        } catch {
            print("Failed to save matches: \(error)")
        }
    }
    
    // Funzione per caricare le partite da AppStorage
    private func loadMatches() {
        do {
            let decoder = JSONDecoder()
            matches = try decoder.decode([Match].self, from: matchesData)
        } catch {
            print("Failed to load matches: \(error)")
        }
    }
    
    // Funzione per caricare i giocatori da AppStorage
    private func loadPlayers() {
        do {
            let decoder = JSONDecoder()
            players = try decoder.decode([Player].self, from: playersData)
        } catch {
            print("Failed to load players: \(error)")
        }
    }
}

#Preview {
    MatchView()
}
