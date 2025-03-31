//
//  StatView.swift
//  LunePoker
//
//  Created by Michele Mariniello on 25/03/25.
//

import SwiftUI

struct StatView: View {
    let players: [Player]
    let matches: [Match]
    
    @State private var selectedStatistic: StatisticType = .totalBalance
    @State private var periodFilter: PeriodFilter = .allTime
    @State private var sortOrder: SortOrder = .descending
    
    // Definizione dei tipi di statistiche
    enum StatisticType: String, CaseIterable, Identifiable {
        case totalBalance = "Bilancio totale"
        case totalWinnings = "Vincite totali"
        case totalLosses = "Perdite totali"
        case firstPlaces = "Primi posti"
        case podiums = "Podi (top 3)"
        case participations = "Partecipazioni"
        case winRate = "% Vittorie"
        case averagePosition = "Posizione media"
        case biggestWin = "Vincita più grande"
        
        var id: String { self.rawValue }
    }
    
    // Filtro per periodo
    enum PeriodFilter: String, CaseIterable, Identifiable {
        case allTime = "Tutto"
        case lastMonth = "Ultimo mese"
        case lastThreeMonths = "Ultimi 3 mesi"
        case thisYear = "Quest'anno"
        
        var id: String { self.rawValue }
    }
    
    // Ordinamento
    enum SortOrder: String, CaseIterable, Identifiable {
        case ascending = "Crescente"
        case descending = "Decrescente"
        
        var id: String { self.rawValue }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(UIColor.systemBackground)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    // Selettori per filtri e ordinamento
                    VStack(spacing: 10) {
                        Picker("Statistica", selection: $selectedStatistic) {
                            ForEach(StatisticType.allCases) { statType in
                                Text(statType.rawValue).tag(statType)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        
                        HStack {
                            Picker("Periodo", selection: $periodFilter) {
                                ForEach(PeriodFilter.allCases) { period in
                                    Text(period.rawValue).tag(period)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            
                            Spacer()
                            
                            Picker("Ordine", selection: $sortOrder) {
                                ForEach(SortOrder.allCases) { order in
                                    Text(order.rawValue).tag(order)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                    }
                    .padding()
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    if matches.isEmpty {
                        Spacer()
                        Text("Nessuna partita registrata")
                            .foregroundColor(.secondary)
                            .padding()
                        Spacer()
                    } else if filteredMatches.isEmpty {
                        Spacer()
                        Text("Nessun dato disponibile per il periodo selezionato")
                            .foregroundColor(.secondary)
                            .padding()
                        Spacer()
                    } else {
                        List {
                            Section(header:
                                        Text(selectedStatistic.rawValue)
                                .font(.headline)
                            ) {
                                ForEach(sortedPlayerStats) { stat in
                                    PlayerStatRow(stat: stat, statType: selectedStatistic)
                                }
                            }
                            
                            Section(header: Text("Statistiche generali")) {
                                StatInfoRow(title: "Totale partite", value: "\(filteredMatches.count)")
                                StatInfoRow(title: "Montepremi totale", value: "€\(String(format: "%.2f", totalPrizePool))")
                                if let lastMatch = filteredMatches.sorted(by: { $0.date > $1.date }).first {
                                    StatInfoRow(title: "Ultima partita", value: dateFormatter.string(from: lastMatch.date))
                                }
                            }
                        }
                        .listStyle(InsetGroupedListStyle())
                    }
                }
            }
            .navigationTitle("Statistiche")
        }
    }
    
    // MARK: - Computed Properties
    
    // Filtra le partite in base al periodo selezionato
    var filteredMatches: [Match] {
        let calendar = Calendar.current
        let currentDate = Date()
        
        switch periodFilter {
        case .allTime:
            return matches
        case .lastMonth:
            guard let oneMonthAgo = calendar.date(byAdding: .month, value: -1, to: currentDate) else {
                return matches
            }
            return matches.filter { $0.date >= oneMonthAgo }
        case .lastThreeMonths:
            guard let threeMonthsAgo = calendar.date(byAdding: .month, value: -3, to: currentDate) else {
                return matches
            }
            return matches.filter { $0.date >= threeMonthsAgo }
        case .thisYear:
            let components = calendar.dateComponents([.year], from: currentDate)
            guard let startOfYear = calendar.date(from: DateComponents(year: components.year, month: 1, day: 1)) else {
                return matches
            }
            return matches.filter { $0.date >= startOfYear }
        }
    }
    
    // Calcola il montepremi totale
    var totalPrizePool: Double {
        filteredMatches.reduce(0) { $0 + $1.totalPrize }
    }
    
    // Struttura per le statistiche di ogni giocatore
    struct PlayerStat: Identifiable {
        let player: Player
        let totalParticipations: Int
        let totalWinnings: Double
        let totalLosses: Double
        let balance: Double
        let firstPlaces: Int
        let podiums: Int
        let winRate: Double
        let averagePosition: Double
        let biggestWin: Double
        
        var id: UUID { player.id }
    }
    
    // Calcola statistiche per tutti i giocatori
    var playerStats: [PlayerStat] {
        players.map { player in
            let playerMatches = filteredMatches.filter { match in
                match.participants.contains { $0.playerID == player.id }
            }
            
            // Partecipazioni totali
            let totalParticipations = playerMatches.count
            
            // Calcolo vincite e perdite
            var totalWinnings: Double = 0
            var firstPlaces = 0
            var podiums = 0
            var positions: [Int] = []
            var biggestWin: Double = 0
            
            for match in playerMatches {
                // Verifico se il giocatore è tra i vincitori
                if let winner = match.winners.first(where: { $0.playerID == player.id }) {
                    totalWinnings += winner.amount
                    if winner.amount > biggestWin {
                        biggestWin = winner.amount
                    }
                    
                    // Conteggio posizionamenti
                    if winner.position == 1 {
                        firstPlaces += 1
                    }
                    if winner.position <= 3 {
                        podiums += 1
                    }
                    
                    positions.append(winner.position)
                }
            }
            
            // Calcolo perdite (entrate - vincite)
            let totalEntryFees = playerMatches.reduce(0.0) { total, match in
                if let participant = match.participants.first(where: { $0.playerID == player.id }) {
                    return total + participant.entryFee
                }
                return total
            }
            let totalLosses = totalEntryFees - totalWinnings
            
            // Calcolo posizione media
            let averagePosition = positions.isEmpty ? 0 : Double(positions.reduce(0, +)) / Double(positions.count)
            
            // Calcolo percentuale vittorie
            let winRate = totalParticipations > 0 ? (Double(firstPlaces) / Double(totalParticipations)) * 100 : 0
            
            return PlayerStat(
                player: player,
                totalParticipations: totalParticipations,
                totalWinnings: totalWinnings,
                totalLosses: totalLosses,
                balance: totalWinnings - totalEntryFees,
                firstPlaces: firstPlaces,
                podiums: podiums,
                winRate: winRate,
                averagePosition: averagePosition,
                biggestWin: biggestWin
            )
        }
    }
    
    // Ordina le statistiche dei giocatori in base alla statistica e all'ordine selezionati
    var sortedPlayerStats: [PlayerStat] {
        let filteredStats = playerStats.filter { $0.totalParticipations > 0 }
        
        switch selectedStatistic {
        case .totalBalance:
            return sortOrder == .descending
            ? filteredStats.sorted { $0.balance > $1.balance }
            : filteredStats.sorted { $0.balance < $1.balance }
        case .totalWinnings:
            return sortOrder == .descending
            ? filteredStats.sorted { $0.totalWinnings > $1.totalWinnings }
            : filteredStats.sorted { $0.totalWinnings < $1.totalWinnings }
        case .totalLosses:
            return sortOrder == .descending
            ? filteredStats.sorted { $0.totalLosses > $1.totalLosses }
            : filteredStats.sorted { $0.totalLosses < $1.totalLosses }
        case .firstPlaces:
            return sortOrder == .descending
            ? filteredStats.sorted { $0.firstPlaces > $1.firstPlaces }
            : filteredStats.sorted { $0.firstPlaces < $1.firstPlaces }
        case .podiums:
            return sortOrder == .descending
            ? filteredStats.sorted { $0.podiums > $1.podiums }
            : filteredStats.sorted { $0.podiums < $1.podiums }
        case .participations:
            return sortOrder == .descending
            ? filteredStats.sorted { $0.totalParticipations > $1.totalParticipations }
            : filteredStats.sorted { $0.totalParticipations < $1.totalParticipations }
        case .winRate:
            return sortOrder == .descending
            ? filteredStats.sorted { $0.winRate > $1.winRate }
            : filteredStats.sorted { $0.winRate < $1.winRate }
        case .averagePosition:
            return sortOrder == .descending
            ? filteredStats.sorted {
                // Per la posizione media, l'ordinamento è invertito (una posizione più bassa è migliore)
                if $0.averagePosition == 0 && $1.averagePosition > 0 { return false }
                if $1.averagePosition == 0 && $0.averagePosition > 0 { return true }
                return $0.averagePosition > $1.averagePosition
            }
            : filteredStats.sorted {
                if $0.averagePosition == 0 && $1.averagePosition > 0 { return true }
                if $1.averagePosition == 0 && $0.averagePosition > 0 { return false }
                return $0.averagePosition < $1.averagePosition
            }
        case .biggestWin:
            return sortOrder == .descending
            ? filteredStats.sorted { $0.biggestWin > $1.biggestWin }
            : filteredStats.sorted { $0.biggestWin < $1.biggestWin }
        }
    }
    
    // Formatter per date
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }
}

#Preview {
    let samplePlayers = [
        Player(id: UUID(), name: "Alice", nickname: "Ali", description: "aa", SelectedCard1: "AS", SelectedCard2: "KS"),
        Player(id: UUID(), name: "Bob", nickname: "olone", description: "aa", SelectedCard1: "AS", SelectedCard2: "KS"),
        Player(id: UUID(), name: "Charlie", nickname: "chaplin", description: "aa", SelectedCard1: "AS", SelectedCard2: "KS")
    ]
    
    let sampleMatches = [
        Match(id: UUID(), date: Date(), participants:[
            Participant(playerID: samplePlayers[0].id, entryFee: 10),
            Participant(playerID: samplePlayers[1].id, entryFee: 15),
            Participant(playerID: samplePlayers[2].id, entryFee: 20)], totalPrize: 100,
            winners: [Winner(playerID: samplePlayers[0].id, position: 1, amount: 50)
                       ]),
        Match(id: UUID(), date: Date().addingTimeInterval(-86400), participants: [
            Participant(playerID: samplePlayers[0].id, entryFee: 10),
            Participant(playerID: samplePlayers[1].id, entryFee: 15)], totalPrize: 80,
            winners: [Winner(playerID: samplePlayers[1].id, position: 1, amount: 40)
                     ])
    ]
    
    StatView(players: samplePlayers, matches: sampleMatches)
}
