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
    @AppStorage("players") private var playersData: Data = Data()
    
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
                        
                        if isLoading && !initialLoadCompleted {
                            Spacer()
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.5)
                            Text("Synchronizing data...")
                                .foregroundColor(.gray)
                                .padding()
                            Spacer()
                        } else {
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
                if !initialLoadCompleted {
                    loadPlayers()
                }
                setupPlayersObserver()
            }
            .onDisappear {
                // Non è necessario rimuovere osservatori qui poiché è gestito a livello di app
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
                    // Opzionale: fai qualcosa in caso di successo
                    print("Players saved to Firebase successfully.")
                }
            }
        }
        // Continua a salvare anche localmente se lo desideri
        savePlayersLocally()
    }

    private func savePlayersLocally() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(players)
            playersData = data
        } catch {
            print("Failed to save players locally: \(error)")
        }
    }

    // Funzione per caricare i dati da AppStorage e Firebase
    private func loadPlayers() {
        print("loadPlayers() chiamato")
        isLoading = true
        print("isLoading impostato a true")

        // Prima carica i dati locali
        do {
            print("Tentativo di caricare i giocatori localmente...")
            let decoder = JSONDecoder()
            players = try decoder.decode([Player].self, from: playersData)
            print("Giocatori caricati localmente: \(players.count)")
        } catch {
            print("Errore durante il caricamento dei giocatori localmente: \(error)")
        }

        // Poi carica i dati da Firebase
        print("Chiamata a FirebaseManager.shared.fetchPlayers...")
        FirebaseManager.shared.fetchPlayers { fetchedPlayers, error in
            DispatchQueue.main.async {
                print("Ritorno da FirebaseManager.shared.fetchPlayers")
                self.isLoading = false
                print("isLoading impostato a false")
                self.initialLoadCompleted = true
                print("initialLoadCompleted impostato a true")

                if let error = error {
                    print("Errore durante il recupero dei giocatori da Firebase: \(error)")
                    return
                }

                if let fetchedPlayers = fetchedPlayers {
                    print("Giocatori recuperati da Firebase: \(fetchedPlayers.count)")
                    if fetchedPlayers.isEmpty && !self.players.isEmpty {
                        print("I dati di Firebase sono vuoti, sincronizzo i dati locali...")
                        self.savePlayersToFirebase()
                    } else {
                        self.players = fetchedPlayers
                        print("Array di giocatori aggiornato con i dati di Firebase.")
                        self.savePlayersLocally() // Salva anche localmente
                    }
                } else {
                    print("Nessun giocatore recuperato da Firebase.")
                }
            }
        }
    }
    
    // Configurazione dell'osservatore per i dati in tempo reale
    private func setupPlayersObserver() {
        FirebaseManager.shared.observePlayers { updatedPlayers in
            DispatchQueue.main.async {
                print("Received players update: \(updatedPlayers?.count ?? 0)")
                guard let updatedPlayers = updatedPlayers else { return }
                
                // Aggiorna i dati solo se sono cambiati
                if !self.players.elementsEqual(updatedPlayers, by: { $0.id == $1.id }) {
                    self.players = updatedPlayers
                    self.isLoading = false
                    
                    // Aggiorna anche i dati locali
                    do {
                        let encoder = JSONEncoder()
                        let data = try encoder.encode(self.players)
                        self.playersData = data
                    } catch {
                        print("Failed to save updated players locally: \(error)")
                    }
                }
                
//                 Assicuriamoci che initialLoadCompleted sia true dopo la prima sincronizzazione
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
