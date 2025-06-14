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

    // MARK: - Sorted Player Lists

    // Funzione helper per ottenere un Player da un ID
    private func playerByID(_ id: UUID) -> Player? {
        players.first { $0.id == id }
    }

    // Lista ordinata per "Participants and fees": selezionati in base all'ordine in `selectedParticipants`, poi non selezionati per nickname
    private var sortedPlayersForParticipants: [Player] {
        let participantPlayerIDs = Set(selectedParticipants.map { $0.playerID })

        // Ottieni i giocatori selezionati nell'ordine in cui appaiono in `selectedParticipants`
        let selected = selectedParticipants.compactMap { participant in
            players.first { $0.id == participant.playerID }
        }

        // Ottieni i giocatori non selezionati e ordinali per nickname
        let unselected = players.filter { !participantPlayerIDs.contains($0.id) }
                               .sorted { $0.nickname < $1.nickname }

        return selected + unselected
    }
    
    // Lista ordinata per "Winners and placements": vincitori prima, poi altri partecipanti non vincitori
    private var sortedParticipantsForWinners: [Participant] {
        let winnerPlayerIDs = Set(winners.map { $0.playerID })
        let currentParticipants = selectedParticipants

        let winningParticipants = currentParticipants.filter { winnerPlayerIDs.contains($0.playerID) }
        let nonWinningParticipants = currentParticipants.filter { !winnerPlayerIDs.contains($0.playerID) }

        // Ordina i vincitori per posizione, poi per nickname
        let sortedWinning = winningParticipants.sorted { p1, p2 in
            if let w1 = winners.first(where: { $0.playerID == p1.playerID }),
               let w2 = winners.first(where: { $0.playerID == p2.playerID }) {
                return w1.position < w2.position
            }
            return false // Fallback, non dovrebbe accadere se la logica è corretta
        }

        // Ordina i non-vincitori per nickname
        let sortedNonWinning = nonWinningParticipants.sorted { p1, p2 in
            guard let player1 = playerByID(p1.playerID),
                  let player2 = playerByID(p2.playerID) else { return false }
            return player1.nickname < player2.nickname
        }

        return sortedWinning + sortedNonWinning
    }

    // MARK: - Body View

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
                        // Usa la lista ordinata per i partecipanti
                        ForEach(sortedPlayersForParticipants) { player in
                            // Questo controllo `if let index = ...` determina se il giocatore è un partecipante selezionato
                            if let index = indexOfParticipant(playerID: player.id) {
                                VStack(spacing: 8) {
                                    // Il nickname rimane centrato, come prima
                                    Text(player.nickname)
                                        .font(.headline)
                                        .frame(maxWidth: .infinity, alignment: .center)

                                    // Layout a 3 colonne per Participants and fees
                                    HStack(spacing: 0) {
                                        // 1. Numero progressivo (allineato a sinistra)
                                        Text("\(index + 1).")
                                            .font(.subheadline)
                                            .frame(width: 25, alignment: .leading)
                                            .foregroundColor(.gray)

                                        Spacer()

                                        // 2. Blocco dei controlli per la cifra (centrato)
                                        HStack(spacing: 5) {
                                            Button {
                                                decrementEntryFee(at: index)
                                            } label: {
                                                Image(systemName: "minus.circle.fill")
                                                    .foregroundColor(.red)
                                                    .frame(width: 35, height: 35)
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
                                                    .frame(width: 35, height: 35)
                                                    .contentShape(Rectangle())
                                            }
                                            .buttonStyle(BorderlessButtonStyle())
                                        }

                                        Spacer()

                                        // 3. Bottone "X" (allineato a destra)
                                        Button {
                                            removeParticipant(at: index)
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .foregroundColor(.red)
                                                .frame(width: 35, height: 35)
                                                .contentShape(Rectangle())
                                        }
                                        .buttonStyle(BorderlessButtonStyle())
                                    }
                                    .padding(.horizontal, 0)
                                }
                                .padding(.vertical, 5)
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
                                            .foregroundColor(.accentColor)
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                }
                            }
                        }
                    }
                }//End Section

                if !selectedParticipants.isEmpty {
                    Section(header: Text("Total prize pool")) {
                        Text("€\(String(format: "%.2f", totalPrize))")
                            .bold()
                            .foregroundColor(.green)
                    }

                    Section(header: Text("Winners and placements")) {
                        // Usa la lista ordinata per i vincitori
                        ForEach(sortedParticipantsForWinners) { participant in
                            if let player = playerByID(participant.playerID) {
                                // Se il partecipante è già un vincitore
                                if let winnerIndex = winners.firstIndex(where: { $0.playerID == participant.playerID }) {
                                    VStack {
                                        Text(player.nickname)
                                            .font(.headline)
                                            .frame(maxWidth: .infinity, alignment: .center)

                                        // Inizio modifica per il layout a 3 colonne per Winners and placements
                                        HStack(spacing: 0) { // Spacing 0 per il controllo fine
                                            // 1. Picker (allineato a sinistra)
                                            Picker("", selection: Binding(
                                                get: { winners[winnerIndex].position },
                                                set: { winners[winnerIndex].position = $0 }
                                            )) {
                                                ForEach(1...selectedParticipants.count, id: \.self) { position in
                                                    Text("\(position)°").tag(position)
                                                }
                                            }
                                            .frame(width: 60) // Larghezza fissa per il picker

                                            Spacer() // Spinge il picker a sinistra e il blocco centrale a destra

                                            // 2. Blocco dei controlli per la cifra (centrato)
                                            HStack(spacing: 5) {
                                                Button {
                                                    decrementWinningAmount(at: winnerIndex)
                                                } label: {
                                                    Image(systemName: "minus.circle.fill")
                                                        .foregroundColor(.red)
                                                        .frame(width: 35, height: 35)
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
                                                        .frame(width: 35, height: 35)
                                                        .contentShape(Rectangle())
                                                }
                                                .buttonStyle(BorderlessButtonStyle())
                                            }

                                            Spacer()

                                            // 3. Bottone "X" (allineato a destra)
                                            Button {
                                                winners.remove(at: winnerIndex)
                                            } label: {
                                                Image(systemName: "xmark.circle.fill")
                                                    .foregroundColor(.red)
                                                    .frame(width: 35, height: 35)
                                                    .contentShape(Rectangle())
                                            }
                                            .buttonStyle(BorderlessButtonStyle())
                                        }
                                    }
                                } else {
                                    // Partecipanti selezionati ma non ancora vincitori
                                    HStack {
                                        Text(player.nickname)
                                            .font(.headline)
                                        Spacer()
                                        Button {
                                            addWinner(participant.playerID)
                                        } label: {
                                            Text("Add Winner")
                                                .foregroundColor(.accentColor)
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
                .tint(Color.accentColor) // Preferibile .accentColor
                ,
                trailing: Button("Save") {
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
                .tint(Color.accentColor) // Preferibile .accentColor
                .disabled(selectedParticipants.isEmpty || winners.isEmpty || !isPrizeBalanced)
            )
        }
    }

    // MARK: - Helper Functions

    private func indexOfParticipant(playerID: UUID) -> Int? {
        selectedParticipants.firstIndex(where: { $0.playerID == playerID })
    }

    private func addParticipant(_ playerID: UUID) {
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
