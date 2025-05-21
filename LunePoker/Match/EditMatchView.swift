//
//  EditMatchView.swift
//  LunePoker
//
//  Created by Michele Mariniello on 30/03/25.
//

import SwiftUI

struct EditMatchView: View {
    let match: Match
    var saveChanges: (Match) -> Void
    let players: [Player]
    
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var matchDate: Date
    @State private var selectedParticipants: [Participant]
    @State private var winners: [Winner]
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
    
    init(match: Match, saveChanges: @escaping (Match) -> Void, players: [Player]) {
        self.match = match
        self.saveChanges = saveChanges
        self.players = players
        
        _matchDate = State(initialValue: match.date)
        _selectedParticipants = State(initialValue: match.participants)
        _winners = State(initialValue: match.winners)
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
                        Text("There are no players available.")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(players) { player in
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
                                            .foregroundColor(.accent)
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
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(player.nickname)
                                            .font(.headline)
                                    }
                                    
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
                                        }
                                        .buttonStyle(BorderlessButtonStyle())
                                    }
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
            .navigationTitle("Edit Match")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                    .tint(Color.accent)
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
                    
                    // Controlla posizioni duplicate
                    let positions = winners.map { $0.position }
                    if Set(positions).count != positions.count {
                        errorMessage = "Ci sono posizioni duplicate tra i vincitori."
                        return
                    }
                    
                    let updatedMatch = Match(
                        id: match.id,
                        date: matchDate,
                        participants: selectedParticipants,
                        totalPrize: totalPrize,
                        winners: winners
                    )
                    saveChanges(updatedMatch)
                    presentationMode.wrappedValue.dismiss()
                }
                    .tint(Color.accent)
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
    let samplePlayers = [
        Player(id: UUID(), name: "Luca", nickname: "Lucky", description: "aa", SelectedCard1: "AS", SelectedCard2: "KS"),
        Player(id: UUID(), name: "Marco", nickname: "Ace", description: "bb", SelectedCard1: "AS", SelectedCard2: "KS"),
        Player(id: UUID(), name: "Giulia", nickname: "Queen", description: "cc", SelectedCard1: "AS", SelectedCard2: "KS")
    ]
    
    let sampleMatch = Match(
        id: UUID(),
        date: Date(),
        participants: [
            Participant(playerID: samplePlayers[0].id, entryFee: 10),
            Participant(playerID: samplePlayers[1].id, entryFee: 15)
        ],
        totalPrize: 25,
        winners: [
            Winner(playerID: samplePlayers[0].id, position: 1, amount: 15),
            Winner(playerID: samplePlayers[1].id, position: 2, amount: 10)
        ]
    )
    
    EditMatchView(
        match: sampleMatch,
        saveChanges: { _ in },
        players: samplePlayers
    )
}
