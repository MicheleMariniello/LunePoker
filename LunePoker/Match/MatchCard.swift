//
//  MatchCard.swift
//  LunePoker
//
//  Created by Michele Mariniello on 30/03/25.
//

import SwiftUI

// Card per visualizzare una partita
struct MatchCard: View {
    let match: Match
    let players: [Player]
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(dateFormatter.string(from: match.date))
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("Montepremi: €\(String(format: "%.2f", match.totalPrize))")
                    .font(.subheadline)
                    .foregroundColor(.green)
            }
            
            Divider().background(Color.gray)
            
            Text("Partecipanti:")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            // Mostra i nomi dei partecipanti con le loro quote
            ForEach(match.participants) { participant in
                if let player = playerByID(participant.playerID) {
                    HStack {
                        Text(player.nickname)
                            .foregroundColor(.white)
                        Spacer()
                        Text("Quota: €\(String(format: "%.2f", participant.entryFee))")
                            .foregroundColor(.blue)
                    }
                }
            }
            
            if !match.winners.isEmpty {
                Divider().background(Color.gray)
                
                Text("Vincitori:")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                // Ordina i vincitori per posizione
                ForEach(match.winners.sorted(by: { $0.position < $1.position })) { winner in
                    if let player = playerByID(winner.playerID) {
                        HStack {
                            Text("\(getPositionText(winner.position)) - \(player.nickname)")
                                .foregroundColor(positionColor(winner.position))
                            Spacer()
                            Text("€\(String(format: "%.2f", winner.amount))")
                                .foregroundColor(.green)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private func playerByID(_ id: UUID) -> Player? {
        players.first { $0.id == id }
    }
    
    private func getPositionText(_ position: Int) -> String {
        switch position {
        case 1: return "1°"
        case 2: return "2°"
        case 3: return "3°"
        default: return "\(position)°"
        }
    }
    
    private func positionColor(_ position: Int) -> Color {
        switch position {
        case 1: return .yellow
        case 2: return .gray
        case 3: return Color(red: 0.8, green: 0.5, blue: 0.2) // Bronzo
        default: return .white
        }
    }
}


//#Preview {
//    MatchCard()
//}
