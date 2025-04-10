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
    
    enum StatisticType: String, CaseIterable, Identifiable {
        case totalBalance = "Total budget"
        case totalWinnings = "Total winnings"
        case totalLosses = "Total losses"
        case firstPlaces = "First places"
        case podiums = "Podiums (top 3)"
        case participations = "Participations"
        case winRate = "% Wins"
        case biggestWin = "Bigger win"
        
        var id: String { self.rawValue }
    }
    
    enum PeriodFilter: String, CaseIterable, Identifiable {
        case allTime = "All Time"
        case lastMonth = "Last Month"
        case lastThreeMonths = "Last 3 months"
        case thisYear = "This Year"
        
        var id: String { self.rawValue }
    }
    
    enum SortOrder: String, CaseIterable, Identifiable {
        case ascending = "Growing"
        case descending = "Descending"
        
        var id: String { self.rawValue }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background nero per tutta la vista
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack {
                    Text("Statistics")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                    
                    VStack(spacing: 10) {
                        Picker("Period", selection: $periodFilter) {
                            ForEach(PeriodFilter.allCases) { period in
                                Text(period.rawValue).tag(period)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        
                        HStack {
                            Picker("Statistic", selection: $selectedStatistic) {
                                ForEach(StatisticType.allCases) { statType in
                                    Text(statType.rawValue).tag(statType)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            
                            Spacer()
                            
                            Picker("Order", selection: $sortOrder) {
                                ForEach(SortOrder.allCases) { order in
                                    Text(order.rawValue).tag(order)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                    }
                    .padding()
                    .background(Color(UIColor.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    if matches.isEmpty {
                        Spacer()
                        Text("No games recorded")
                            .foregroundColor(.gray)
                            .padding()
                        Spacer()
                    } else if filteredMatches.isEmpty {
                        Spacer()
                        Text("No data available for the selected period")
                            .foregroundColor(.gray)
                            .padding()
                        Spacer()
                    } else {
                        List {
                            Section(header:
                                        Text(selectedStatistic.rawValue)
                                .font(.headline)
                                .foregroundColor(.white)
                            ) {
                                ForEach(sortedPlayerStats) { stat in
                                    PlayerStatRow(stat: stat, statType: selectedStatistic)
                                }
                            }
                            
                            Section(header: Text("General statistics")
                                .foregroundColor(.white)) {
                                    StatInfoRow(title: "Total matches", value: "\(filteredMatches.count)")
                                    StatInfoRow(title: "Total prize pool", value: "€\(String(format: "%.2f", totalPrizePool))")
                                    if let lastMatch = filteredMatches.sorted(by: { $0.date > $1.date }).first {
                                        StatInfoRow(title: "Last game", value: dateFormatter.string(from: lastMatch.date))
                                    }
                                }
                        }
                        .listStyle(InsetGroupedListStyle())
                        .onAppear {
                            UITableView.appearance().backgroundColor = .black
                            UITableViewCell.appearance().backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
                            
                            if #available(iOS 15.0, *) {
                                UITableView.appearance().sectionHeaderTopPadding = 0
                            }
                        }
                    }
                }
                .foregroundColor(.white)
            }
            .toolbarColorScheme(.dark, for: .navigationBar)
            .preferredColorScheme(.dark)
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
        let biggestWin: Double
        
        var id: UUID { player.id }
    }
    
    // MARK:     Calcola statistiche per tutti i giocatori
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
            let totalLosses = totalEntryFees
            
            // MARK: Calcolo percentuale vittorie   CONTROLLARE
            let winRate = totalParticipations > 0 ? (Double(firstPlaces) / Double(filteredMatches.count)) * 100 : 0
            
            return PlayerStat(
                player: player,
                totalParticipations: totalParticipations,
                totalWinnings: totalWinnings,
                totalLosses: totalLosses,
                balance: totalWinnings - totalEntryFees,
                firstPlaces: firstPlaces,
                podiums: podiums,
                winRate: winRate,
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
