//
//  PlayerView.swift
//  LunePoker
//
//  Created by Michele Mariniello on 25/03/25.

import SwiftUI
import FirebaseDatabase

struct Player: Identifiable, Codable {
    let id: UUID
    var name: String
    var nickname: String
    var description: String
    var SelectedCard1: String
    var SelectedCard2: String
}

struct PlayerView: View {
    @State private var players: [Player] = []
    @State private var isAddingPlayer = false
    @State private var selectedPlayer: Player?
    @State private var playerToDelete: Player?
    @State private var showDeleteAlert = false
    @State private var isLoading = false
    @State private var initialLoadCompleted = false
    
    var body: some View {
        ZStack {
            NavigationView {
                ZStack {
                    Color.black.edgesIgnoringSafeArea(.all)
                    
                    VStack(spacing: 0) {
                        // Header personalizzato
                        ZStack {
                            Text("Players")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            HStack {
                                Spacer()
                                Button(action: { isAddingPlayer = true }) {
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
                            Text("Synchronizing Players...")
                                .foregroundColor(.gray)
                                .padding()
                            Spacer()
                        } else {
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
                    }
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
                if !initialLoadCompleted {
                    loadPlayers()
                }
                setupPlayersObserver()
            }
            
            if showDeleteAlert, let player = playerToDelete {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        // Chiudi l'alert se si tocca fuori
                        showDeleteAlert = false
                        playerToDelete = nil
                    }
                
                VStack {
                    Text("Confirm deletion")
                        .font(.headline)
                        .padding()
                    
                    Text("Are you sure you want delete \(player.name)?")
                        .padding(.horizontal)
                    
                    HStack {
                        Button("Cancel") {
                            showDeleteAlert = false
                            playerToDelete = nil
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.7))
                        .foregroundStyle(.white)
                        .cornerRadius(8)
                        
                        Button("Delete") {
                            removePlayer(player)
                            showDeleteAlert = false
                            playerToDelete = nil
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
    
    // Funzione per aggiungere un nuovo giocatore
    private func addPlayer(name: String, nickname: String, description: String, card1: String, card2: String) {
        let newPlayer = Player(id: UUID(), name: name, nickname: nickname, description: description, SelectedCard1: card1, SelectedCard2: card2)
        players.append(newPlayer)
        savePlayersToFirebase()
    }
    
    // Funzione per aggiornare un giocatore
    private func updatePlayer(updatedPlayer: Player) {
        if let index = players.firstIndex(where: { $0.id == updatedPlayer.id }) {
            players[index] = updatedPlayer
            savePlayersToFirebase()
        }
    }
    
    // Funzione per rimuovere un giocatore
    private func removePlayer(_ player: Player) {
        players.removeAll { $0.id == player.id }
        savePlayersToFirebase()
    }
    
    // Funzione per salvare i dati su Firebase
    private func savePlayersToFirebase() {
        isLoading = true
        FirebaseManager.shared.savePlayers(players) { error in
            DispatchQueue.main.async {
                self.isLoading = false
                if let error = error {
                    print("Failed to save players to Firebase: \(error)")
                    // Qui potresti mostrare un alert all'utente
                } else {
                    print("Players saved to Firebase successfully.")
                }
            }
        }
    }
    
    // Funzione per caricare i dati SOLO da Firebase (room-specific)
    private func loadPlayers() {
        print("loadPlayers() chiamato - caricando da Firebase per room corrente")
        isLoading = true
        
        // Carica SOLO da Firebase (per la room corrente)
        FirebaseManager.shared.fetchPlayers { fetchedPlayers, error in
            DispatchQueue.main.async {
                print("Ritorno da FirebaseManager.shared.fetchPlayers")
                self.isLoading = false
                self.initialLoadCompleted = true
                
                if let error = error {
                    print("Errore durante il recupero dei giocatori da Firebase: \(error)")
                    return
                }
                
                if let fetchedPlayers = fetchedPlayers {
                    print("Giocatori recuperati da Firebase per questa room: \(fetchedPlayers.count)")
                    self.players = fetchedPlayers
                } else {
                    print("Nessun giocatore recuperato da Firebase per questa room.")
                    self.players = []
                }
            }
        }
    }
    
    // Configurazione dell'osservatore per i dati in tempo reale
    private func setupPlayersObserver() {
        FirebaseManager.shared.observePlayers { updatedPlayers in
            DispatchQueue.main.async {
                print("Received players update for current room: \(updatedPlayers?.count ?? 0)")
                guard let updatedPlayers = updatedPlayers else {
                    self.players = []
                    return
                }
                
                // Aggiorna i dati solo se sono cambiati
                if !self.players.elementsEqual(updatedPlayers, by: { $0.id == $1.id }) {
                    self.players = updatedPlayers
                    self.isLoading = false
                }
                
                if !self.initialLoadCompleted {
                    self.initialLoadCompleted = true
                    self.isLoading = false
                }
            }
        }
    }
}

#Preview {
    PlayerView()
}
