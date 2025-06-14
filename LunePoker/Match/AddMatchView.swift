//
//  AddMatchView.swift
//  LunePoker
//
//  Created by Michele Mariniello on 30/03/25.
//

import SwiftUI

struct AddMatchView: View {
    @Binding var isPresented: Bool
    var saveMatch: (Date, [Participant], [Winner]) -> Void
    @Binding var players: [Player]
    
    @State private var matchDate = Date()
    @State private var selectedParticipants: [Participant] = []
    @State private var winners: [Winner] = []
    @State private var errorMessage: String? = nil
    
    // Calcola il montepremi totale dalla somma delle quote
    private var totalPrize: Double {
        selectedParticipants.reduce(0) { $0 + $1.entryFee }
    }
    
    // Calcola la somma delle vincite
    private var totalWinnings: Double {
        winners.reduce(0) { $0 + $1.amount }
    }
    
    // Controlla se il montepremi e le vincite sono bilanciate
    private var isPrizeBalanced: Bool {
        abs(totalPrize - totalWinnings) < 0.01
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Match Data")) {
                    DatePicker("Date", selection: $matchDate,
                               in: ...Date(),
                               displayedComponents: .date)
                }
                
                Section(header: Text("Participants and fees")) {
                    if players.isEmpty {
                        Text("There are no players available. Add players first.")
                            .foregroundColor(.secondary)
                    } else {
                        // Modifica qui: Ordina i giocatori in modo che i partecipanti selezionati
                        // siano in cima e ordinati per l'ordine in cui sono stati aggiunti (indice),
                        // mentre i non selezionati siano ordinati per nickname.
                        ForEach(players.sorted { p1, p2 in
                            let index1 = indexOfParticipant(playerID: p1.id)
                            let index2 = indexOfParticipant(playerID: p2.id)

                            if let i1 = index1, let i2 = index2 {
                                // Entrambi sono partecipanti selezionati, ordina per l'ordine di aggiunta
                                return i1 < i2
                            } else if index1 != nil {
                                // Solo p1 è un partecipante selezionato, mettilo prima
                                return true
                            } else if index2 != nil {
                                // Solo p2 è un partecipante selezionato, p2 viene dopo
                                return false
                            } else {
                                // Nessuno dei due è un partecipante selezionato, ordina per nickname
                                return p1.nickname < p2.nickname
                            }
                        }) { player in
                            if let index = indexOfParticipant(playerID: player.id) {
                                // Se il giocatore è un partecipante selezionato
                                VStack(spacing: 8) {
                                    Text(player.nickname)
                                        .font(.headline)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                    
                                    // Nuovo HStack per il layout a tre colonne
                                    HStack(spacing: 0) {
                                        // 1. Numero progressivo (sinistra)
                                        Text("\(index + 1).")
                                            .font(.subheadline)
                                            .frame(width: 25, alignment: .leading)
                                            .foregroundColor(.gray)
                                        
                                        Spacer() // Spinge il numero a sinistra e il blocco centrale a destra
                                        
                                        // 2. Blocco dei controlli per la cifra (centrato)
                                        HStack(spacing: 5) {
                                            Button {
                                                decrementEntryFee(at: index)
                                            } label: {
                                                Image(systemName: "minus.circle.fill")
                                                    .foregroundColor(.red)
                                                    .frame(width: 35, height: 35) // Resized for consistency
                                                    .contentShape(Rectangle())
                                            }
                                            .buttonStyle(BorderlessButtonStyle())
                                            
                                            Text("€\(String(format: "%.2f", selectedParticipants[index].entryFee))")
                                                .frame(width: 70)
                                                .font(.body)
                                            
                                            Button {
                                                incrementEntryFee(at: index)
                                            } label: {
                                                Image(systemName: "plus.circle.fill")
                                                    .foregroundColor(.green)
                                                    .frame(width: 35, height: 35) // Resized for consistency
                                                    .contentShape(Rectangle())
                                            }
                                            .buttonStyle(BorderlessButtonStyle())
                                        }
                                        
                                        Spacer() // Spinge il blocco centrale a sinistra e la 'x' a destra
                                        
                                        // 3. Pulsante rimuovi (destra)
                                        Button {
                                            removeParticipant(at: index)
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.red)
                                                .frame(width: 35, height: 35) // Resized for consistency
                                                .contentShape(Rectangle())
                                        }
                                        .buttonStyle(BorderlessButtonStyle())
                                    }
                                    .padding(.horizontal, 0) // Rimuove il padding dell'HStack
                                }
                                .padding(.vertical, 5) // Padding per l'intera riga
                            } else {
                                // Giocatori non selezionati
                                HStack {
                                    Text(player.nickname)
                                        .font(.headline)
                                    Spacer()
                                    Button {
                                        addParticipant(player.id)
                                    } label: {
                                        Text("Add")
                                            .foregroundColor(.accentColor) // Use .accentColor
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                }
                            }
                        }
                    }
                }
                
                if !selectedParticipants.isEmpty {
                    Section(header: Text("Total prize pool")) {
                        Text("€\(String(format: "%.2f", totalPrize))")
                            .bold()
                            .foregroundColor(.green)
                    }
                    
                    Section(header: Text("Winners and placements")) {
                        // Per i vincitori, ordiniamo i partecipanti in modo che i vincitori siano prima, ordinati per posizione
                        // e poi i non-vincitori. Questo richiede una funzione di ordinamento simile a quella usata in EditMatchView.
                        // Per ora, useremo selectedParticipants e controlleremo se sono vincitori.
                        
                        // Funzione per ordinare i partecipanti per la sezione vincitori
                        let sortedParticipantsForWinners = selectedParticipants.sorted { p1, p2 in
                            let w1 = winners.first(where: { $0.playerID == p1.playerID })
                            let w2 = winners.first(where: { $0.playerID == p2.playerID })
                            
                            // Se entrambi sono vincitori, ordina per posizione
                            if let w1 = w1, let w2 = w2 {
                                return w1.position < w2.position
                            }
                            // Se solo p1 è vincitore, p1 viene prima
                            if w1 != nil && w2 == nil {
                                return true
                            }
                            // Se solo p2 è vincitore, p2 viene prima
                            if w1 == nil && w2 != nil {
                                return false
                            }
                            // Se nessuno dei due è vincitore, ordina per nickname
                            guard let player1 = playerByID(p1.playerID),
                                  let player2 = playerByID(p2.playerID) else { return false }
                            return player1.nickname < player2.nickname
                        }
                        
                        ForEach(sortedParticipantsForWinners) { participant in
                            if let player = playerByID(participant.playerID) {
                                VStack {
                                    Text(player.nickname)
                                        .font(.headline)
                                        .frame(maxWidth: .infinity, alignment: .center)
                                        .padding(.bottom, 5)
                                    
                                    // Nuovo HStack per il layout a tre colonne
                                    HStack(spacing: 0) {
                                        if let winnerIndex = winners.firstIndex(where: { $0.playerID == participant.playerID }) {
                                            // 1. Picker (sinistra)
                                            Picker("", selection: Binding(
                                                get: { winners[winnerIndex].position },
                                                set: { winners[winnerIndex].position = $0 }
                                            )) {
                                                ForEach(1...selectedParticipants.count, id: \.self) { position in
                                                    Text("\(position)°").tag(position)
                                                }
                                            }
                                            .frame(width: 60)
                                            
                                            Spacer() // Spinge il picker a sinistra e il blocco centrale a destra
                                            
                                            // 2. Blocco dei controlli per la cifra (centrato)
                                            HStack(spacing: 5) {
                                                Button {
                                                    decrementWinningAmount(at: winnerIndex)
                                                } label: {
                                                    Image(systemName: "minus.circle.fill")
                                                        .foregroundColor(.red)
                                                        .frame(width: 35, height: 35) // Resized
                                                        .contentShape(Rectangle())
                                                }
                                                .buttonStyle(BorderlessButtonStyle())
                                                
                                                Text("€\(String(format: "%.2f", winners[winnerIndex].amount))")
                                                    .frame(width: 70)
                                                
                                                Button {
                                                    incrementWinningAmount(at: winnerIndex)
                                                } label: {
                                                    Image(systemName: "plus.circle.fill")
                                                        .foregroundColor(.green)
                                                        .frame(width: 35, height: 35) // Resized
                                                        .contentShape(Rectangle())
                                                }
                                                .buttonStyle(BorderlessButtonStyle())
                                            }
                                            
                                            Spacer() // Spinge il blocco centrale a sinistra e la 'x' a destra
                                            
                                            // 3. Pulsante rimuovi (destra)
                                            Button {
                                                winners.remove(at: winnerIndex)
                                            } label: {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.red)
                                                    .frame(width: 35, height: 35) // Resized
                                                    .contentShape(Rectangle())
                                            }
                                            .buttonStyle(BorderlessButtonStyle())
                                            
                                        } else {
                                            // Se il giocatore non è un vincitore selezionato
                                            Button {
                                                addWinner(participant.playerID)
                                            } label: {
                                                Text("Add Winner")
                                                    .foregroundColor(.accentColor)
                                            }
                                            .buttonStyle(BorderlessButtonStyle())
                                        }
                                    } // End HStack
                                } // End VStack
                            }
                        }
                        
                        if !winners.isEmpty {
                            HStack {
                                Text("Total winnings:")
                                Spacer()
                                Text("€\(String(format: "%.2f", totalWinnings))")
                                    .bold()
                                    .foregroundColor(isPrizeBalanced ? .green : .red)
                            }
                        }
                    }
                }
                
                if let error = errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("New Match")
            .navigationBarItems(
                leading: Button("Cancel") {
                    isPresented = false
                }
                .tint(Color.accentColor) // Use .accentColor
                ,
                trailing: Button("Save") {
                    // Validazione
                    if selectedParticipants.isEmpty {
                        errorMessage = "You must select at least one participant."
                        return
                    }
                    
                    if winners.isEmpty {
                        errorMessage = "You must select at least one winner."
                        return
                        }
                    
                    if !isPrizeBalanced {
                        errorMessage = "The total winnings must equal the total prize pool."
                        return
                    }
                    
                    let positions = winners.map { $0.position }
                    if Set(positions).count != positions.count {
                        errorMessage = "Ci sono posizioni duplicate tra i vincitori."
                        return
                    }
                    
                    saveMatch(
                        matchDate,
                        selectedParticipants,
                        winners
                    )
                    isPresented = false
                }
                .tint(Color.accentColor) // Use .accentColor
                .disabled(selectedParticipants.isEmpty || winners.isEmpty || !isPrizeBalanced)
            )
        }
    }
    
    // Funzioni helper per manipolare i partecipanti e le quote
    private func indexOfParticipant(playerID: UUID) -> Int? {
        selectedParticipants.firstIndex(where: { $0.playerID == playerID })
    }
    
    private func addParticipant(_ playerID: UUID) {
        // Imposta 10 euro come quota predefinita
        selectedParticipants.append(Participant(playerID: playerID, entryFee: 10.0))
        // Non è più necessario riordinare qui, perché il ForEach gestisce l'ordinamento dinamico
    }
    
    private func removeParticipant(at index: Int) {
        let playerID = selectedParticipants[index].playerID
        selectedParticipants.remove(at: index)
        // Rimuovi anche il giocatore dai vincitori se presente
        winners.removeAll(where: { $0.playerID == playerID })
        
        // Aggiorna le posizioni dei vincitori rimasti
        updateWinnerPositions()
    }
    
    private func incrementEntryFee(at index: Int) {
        var updatedParticipants = selectedParticipants
        updatedParticipants[index].entryFee += 5
        selectedParticipants = updatedParticipants
    }
    
    private func decrementEntryFee(at index: Int) {
        var updatedParticipants = selectedParticipants
        if updatedParticipants[index].entryFee >= 5 {
            updatedParticipants[index].entryFee -= 5
            selectedParticipants = updatedParticipants
        }
    }
    
    // Funzioni helper per manipolare i vincitori e le vincite
    private func addWinner(_ playerID: UUID) {
        let nextPosition = (winners.map { $0.position }.max() ?? 0) + 1
        winners.append(Winner(playerID: playerID, position: nextPosition, amount: 0))
        // Ordina i vincitori dopo l'aggiunta
        winners.sort { $0.position < $1.position }
    }
    
    private func incrementWinningAmount(at index: Int) {
        var updatedWinners = winners
        updatedWinners[index].amount += 5
        winners = updatedWinners
    }
    
    private func decrementWinningAmount(at index: Int) {
        var updatedWinners = winners
        if updatedWinners[index].amount >= 5 {
            updatedWinners[index].amount -= 5
            winners = updatedWinners
        }
    }
    
    private func playerByID(_ id: UUID) -> Player? {
        players.first { $0.id == id }
    }
    
    // Funzione per aggiornare le posizioni dei vincitori dopo una rimozione
    private func updateWinnerPositions() {
        // Riordina i vincitori per assicurare che le posizioni siano consecutive
        winners.sort { $0.position < $1.position }
        for i in 0..<winners.count {
            winners[i].position = i + 1
        }
    }
}

//#Preview {
//    AddMatchView(
//        isPresented: .constant(true),
//        saveMatch: { _, _, _ in },
//        players: [
//            Player(id: UUID(), name: "Mario Rossi", nickname: "Marr", description: "Ho 20 anni", SelectedCard1: "AS", SelectedCard2: "KS"),
//            Player(id: UUID(), name: "Luca Bianchi", nickname: "Zrro", description: "Ho 20 anni", SelectedCard1: "AS", SelectedCard2: "KS"),
//            Player(id: UUID(), name: "Giulia Verdi", nickname: "a", description: "Ho 20 anni", SelectedCard1: "AS", SelectedCard2: "KS")
//        ]
//    )
//}
