//
//  PlayerView.swift
//  LunePoker
//
//  Created by Michele Mariniello on 25/03/25.
//

import SwiftUI

struct Player: Identifiable, Codable {
    let id: UUID
    var name: String
    var nickname: String
    var description: String
}

struct PlayerView: View {
    @AppStorage("players") private var playersData: Data = Data()
    
    @State private var players: [Player] = []
    @State private var isAddingPlayer = false
    @State private var selectedPlayer: Player?

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    LazyVStack(spacing: 15) {
                        ForEach(players) { player in
                            PlayerCard(player: player)
                                .onTapGesture {
                                    selectedPlayer = player
                                }
                                .contextMenu {
                                    Button(role: .destructive) {
                                        removePlayer(player)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                    .padding()
                }
                .navigationTitle("Players")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: { isAddingPlayer = true }) {
                            Image(systemName: "plus")
                        }
                    }
                }
                .sheet(isPresented: $isAddingPlayer) {
                    AddPlayerView(isPresented: $isAddingPlayer, savePlayer: addPlayer)
                }
                .sheet(item: $selectedPlayer) { player in
                    EditPlayerView(player: player, saveChanges: updatePlayer)
                }
            }
        }
        .onAppear {
            loadPlayers()
        }
    }


    // Funzione per aggiungere un nuovo giocatore
    private func addPlayer(name: String, nickname: String, description: String) {
        let newPlayer = Player(id: UUID(), name: name, nickname: nickname, description: description)
        players.append(newPlayer)
        savePlayers()
    }

    // Funzione per aggiornare un giocatore
    private func updatePlayer(updatedPlayer: Player) {
        if let index = players.firstIndex(where: { $0.id == updatedPlayer.id }) {
            players[index] = updatedPlayer
            savePlayers()
        }
    }

    // Funzione per rimuovere un giocatore
    private func removePlayer(_ player: Player) {
        players.removeAll { $0.id == player.id }
        savePlayers()
    }

    // Funzione per salvare i dati in AppStorage
    private func savePlayers() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(players)
            playersData = data
        } catch {
            print("Failed to save players: \(error)")
        }
    }

    // Funzione per caricare i dati da AppStorage
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
    PlayerView()
}
