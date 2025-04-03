//
//  PlayerView.swift
//  LunePoker
//
//  Created by Michele Mariniello on 25/03/25.
//
//.multilineTextAlignment(.center)
import SwiftUI

struct Player: Identifiable, Codable {
    let id: UUID
    var name: String
    var nickname: String
    var description: String
    var SelectedCard1: String
    var SelectedCard2: String
}

struct PlayerView: View {
    @AppStorage("players") private var playersData: Data = Data()
    
    @State private var players: [Player] = []
    @State private var isAddingPlayer = false
    @State private var selectedPlayer: Player?
    @State private var playerToDelete: Player?
    @State private var showDeleteAlert = false

    var body: some View {
        ZStack {
            NavigationView {
                ZStack {
                    Color.black.edgesIgnoringSafeArea(.all)
                    
                    VStack(spacing: 0) {
                        // Header personalizzato
                        HStack {
                            Spacer()
                            Text("Players")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Button(action: { isAddingPlayer = true }) {
                                Image(systemName: "plus")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding()
                        
                        // Contenuto principale
                        ScrollView {
                            LazyVStack(spacing: 15) {
                                ForEach(players.sorted(by: { $0.name < $1.name })) { player in
                                    PlayerCard(player: player)
                                        .onTapGesture {
                                            selectedPlayer = player
                                        }
                                        .contextMenu {
                                            Button(role: .destructive) {
                                                playerToDelete = player
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
                    
                    // Sheet invariati
                    .sheet(isPresented: $isAddingPlayer) {
                        AddPlayerView(isPresented: $isAddingPlayer, savePlayer: addPlayer)
                    }
                    .sheet(item: $selectedPlayer) { player in
                        EditPlayerView(player: player, saveChanges: updatePlayer)
                    }
                }
                .navigationBarHidden(true)
            }
            .onAppear {
                loadPlayers()
            }
            
            // L'alert è ora un overlay su tutta la view
            if showDeleteAlert, let player = playerToDelete {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        // Chiudi l'alert se si tocca fuori
                        showDeleteAlert = false
                        playerToDelete = nil
                    }
                
                VStack {
                    Text("Conferma eliminazione")
                        .font(.headline)
                        .padding()
                    
                    Text("Sei sicuro di voler eliminare \(player.name)?")
                        .padding(.horizontal)
                    
                    HStack {
                        Button("Annulla") {
                            showDeleteAlert = false
                            playerToDelete = nil
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        
                        Button("Elimina") {
                            removePlayer(player)
                            showDeleteAlert = false
                            playerToDelete = nil
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
                .background(Color.white)
                .cornerRadius(12)
                .shadow(radius: 10)
            }
        }
    }

    // Funzione per aggiungere un nuovo giocatore
    private func addPlayer(name: String, nickname: String, description: String, card1: String, card2: String) {
        let newPlayer = Player(id: UUID(), name: name, nickname: nickname, description: description, SelectedCard1: card1, SelectedCard2: card2)
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
}//End Struct

#Preview {
    PlayerView()
}
