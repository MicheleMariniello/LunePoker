//
//  PlayerStatRow.swift
//  LunePoker
//
//  Created by Michele Mariniello on 31/03/25.
//
import SwiftUI

struct PlayerStatRow: View {
    let stat: StatView.PlayerStat
    let statType: StatView.StatisticType
    
    var body: some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading) {
                Text(stat.player.name)
                    .font(.headline)
                Text(stat.player.nickname)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            statValue
                .font(.system(.body, design: .monospaced))
                .fontWeight(.bold)
        }
    }
    
    var statValue: some View {
        Group {
            switch statType {
            case .totalBalance:
                Text("€\(String(format: "%.2f", stat.balance))")
                    .foregroundColor(stat.balance >= 0 ? .green : .red)
            case .totalWinnings:
                Text("€\(String(format: "%.2f", stat.totalWinnings))")
                    .foregroundColor(.green)
            case .totalLosses:
                Text("€\(String(format: "%.2f", stat.totalLosses))")
                    .foregroundColor(.red)
            case .firstPlaces:
                Text("\(stat.firstPlaces)")
                    .foregroundColor(.orange)
            case .podiums:
                Text("\(stat.podiums)")
                    .foregroundColor(.blue)
            case .participations:
                Text("\(stat.totalParticipations)")
            case .winRate:
                Text("\(String(format: "%.1f", stat.winRate))%")
                    .foregroundColor(.purple)
            case .biggestWin:
                Text("€\(String(format: "%.2f", stat.biggestWin))")
                    .foregroundColor(.green)
            }
        }
    }
}

struct PlayerStatRow_Previews: PreviewProvider {
    static var previews: some View {
        PlayerStatRow(
            stat: StatView.PlayerStat(
                player: Player(
                    id: UUID(),  // Genera un UUID valido
                    name: "Luca",
                    nickname: "LuPo",
                    description: "scarso",
                    SelectedCard1: "AS",
                    SelectedCard2: "AH"
                ),
                totalParticipations: 150, // Rimosso il cast inutile
                totalWinnings: 200.0,
                totalLosses: 50.0,
                balance: 3.0,
                firstPlaces: 5,
                podiums: 10,
                winRate: 30.0,
                biggestWin: 100.0
            ),
            statType: .totalBalance
        )
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
