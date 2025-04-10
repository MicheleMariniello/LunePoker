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
    let players: [Player]
    
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
                        ForEach((players.sorted {
                            (indexOfParticipant(playerID: $0.id) != nil ? 0 : 1) <
                                (indexOfParticipant(playerID: $1.id) != nil ? 0 : 1)
                        })) { player in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(player.nickname)
                                        .font(.headline)
                                }
                                
                                Spacer()
                                
                                if let index = indexOfParticipant(playerID: player.id) {
                                    // Pulsante -
                                    Button {
                                        decrementEntryFee(at: index)
                                    } label: {
                                        Image(systemName: "minus.circle.fill")
                                            .foregroundColor(.red)
                                            .frame(width: 44, height: 44)
                                            .contentShape(Rectangle())
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                    
                                    Text("€\(String(format: "%.2f", selectedParticipants[index].entryFee))")
                                        .frame(width: 70)
                                    
                                    // Pulsante +
                                    Button {
                                        incrementEntryFee(at: index)
                                    } label: {
                                        Image(systemName: "plus.circle.fill")
                                            .foregroundColor(.green)
                                            .frame(width: 44, height: 44)
                                            .contentShape(Rectangle())
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                    
                                    // Pulsante rimuovi
                                    Button {
                                        removeParticipant(at: index)
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.red)
                                            .frame(width: 44, height: 44)
                                            .contentShape(Rectangle())
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                } else {
                                    Button {
                                        addParticipant(player.id)
                                    } label: {
                                        Text("Add")
                                            .foregroundColor(.blue)
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
                        ForEach(selectedParticipants) { participant in
                            if let player = playerByID(participant.playerID) {
                                
                                VStack{
                                    
                                    Text(player.nickname)
                                        .font(.headline)
                                        .padding(.bottom, 5)
                                    
                                    HStack {
                                        Spacer()
                                        
                                        if let winnerIndex = winners.firstIndex(where: { $0.playerID == participant.playerID }) {
                                            HStack {
                                                Picker("", selection: Binding(
                                                    get: { winners[winnerIndex].position },
                                                    set: { winners[winnerIndex].position = $0 }
                                                )) {
                                                    ForEach(1...selectedParticipants.count, id: \.self) { position in
                                                        Text("\(position)°").tag(position)
                                                    }
                                                }
                                                .frame(width: 60)
                                                
                                                // Pulsante -
                                                Button {
                                                    decrementWinningAmount(at: winnerIndex)
                                                } label: {
                                                    Image(systemName: "minus.circle.fill")
                                                        .foregroundColor(.red)
                                                        .frame(width: 44, height: 44)
                                                        .contentShape(Rectangle())
                                                }
                                                .buttonStyle(BorderlessButtonStyle())
                                                
                                                Text("€\(String(format: "%.2f", winners[winnerIndex].amount))")
                                                    .frame(width: 70)
                                                
                                                // Pulsante +
                                                Button {
                                                    incrementWinningAmount(at: winnerIndex)
                                                } label: {
                                                    Image(systemName: "plus.circle.fill")
                                                        .foregroundColor(.green)
                                                        .frame(width: 44, height: 44)
                                                        .contentShape(Rectangle())
                                                }
                                                .buttonStyle(BorderlessButtonStyle())
                                                Spacer()
                                                // Pulsante rimuovi
                                                Button {
                                                    winners.remove(at: winnerIndex)
                                                } label: {
                                                    Image(systemName: "xmark.circle.fill")
                                                        .foregroundColor(.red)
                                                        .frame(width: 44, height: 44)
                                                        .contentShape(Rectangle())
                                                }
                                                .buttonStyle(BorderlessButtonStyle())
                                            }
                                        } else {
                                            Button {
                                                addWinner(participant.playerID)
                                            } label: {
                                                Text("Add Winner")
                                                    .foregroundColor(.blue)
                                                    .multilineTextAlignment(.center)
                                            }
                                            .buttonStyle(BorderlessButtonStyle())
                                        }
                                        Spacer()
                                    }//EndHStack
                                }
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
                },
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
                    saveMatch(
                        matchDate,
                        selectedParticipants,
                        winners
                    )
                    isPresented = false
                }
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
    }
    
    private func removeParticipant(at index: Int) {
        let playerID = selectedParticipants[index].playerID
        selectedParticipants.remove(at: index)
        // Rimuovi anche il giocatore dai vincitori se presente
        winners.removeAll(where: { $0.playerID == playerID })
    }
    
    private func sortedPlayers() -> [Player] {
        players.sorted { a, b in
            let aIsSelected = indexOfParticipant(playerID: a.id) != nil
            let bIsSelected = indexOfParticipant(playerID: b.id) != nil
            if aIsSelected && !bIsSelected {
                return true
            } else if !aIsSelected && bIsSelected {
                return false
            } else {
                return a.nickname < b.nickname // fallback per ordinamento stabile
            }
        }
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
}

#Preview {
    AddMatchView(
        isPresented: .constant(true),
        saveMatch: { _, _, _ in },
        players: [
            Player(id: UUID(), name: "Mario Rossi", nickname: "Marr", description: "Ho 20 anni", SelectedCard1: "AS", SelectedCard2: "KS"),
            Player(id: UUID(), name: "Luca Bianchi", nickname: "Zrro", description: "Ho 20 anni", SelectedCard1: "AS", SelectedCard2: "KS"),
            Player(id: UUID(), name: "Giulia Verdi", nickname: "a", description: "Ho 20 anni", SelectedCard1: "AS", SelectedCard2: "KS")
        ]
    )
}
