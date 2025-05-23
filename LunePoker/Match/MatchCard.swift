//
//  MatchCard.swift
//  LunePoker
//
//  Created by Michele Mariniello on 30/03/25.
//

import SwiftUI

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
                
                Text("Prize money: €\(String(format: "%.2f", match.totalPrize))")
                    .font(.subheadline)
                    .foregroundColor(.green)
            }
            
            if !match.winners.isEmpty {
                Divider().background(Color.gray)
                
                Text("Winners:")
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

#Preview {
    MatchCard(
        match: Match(
            id: UUID(),
            date: Date(),
            participants: [
                Participant(playerID: UUID(), entryFee: 50.0),
                Participant(playerID: UUID(), entryFee: 50.0),
                Participant(playerID: UUID(), entryFee: 50.0)
            ], totalPrize: 150.0,
            winners: [
                Winner(playerID: UUID(), position: 1, amount: 100.0),
                Winner(playerID: UUID(), position: 2, amount: 30.0),
                Winner(playerID: UUID(), position: 3, amount: 20.0)
            ]
        ),
        players: [
            Player(id: UUID(), name: "Mario Rossi", nickname: "Mario", description: "aa", SelectedCard1: "AS", SelectedCard2: "KS"),
            Player(id: UUID(), name: "Luca Bianchi", nickname: "Luca", description: "bb", SelectedCard1: "AS", SelectedCard2: "KS"),
            Player(id: UUID(), name: "Giulia Verdi", nickname: "Giulia", description: "cc", SelectedCard1: "AS", SelectedCard2: "KS")
        ]
    )
}

