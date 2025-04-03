//
//  PlayerCard.swift
//  LunePoker
//
//  Created by Michele Mariniello on 25/03/25.
//
import SwiftUI

struct PlayerCard: View {
    let player: Player
    let backgroundImage = "Background_Cards"

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image(backgroundImage)
                .resizable()
                .scaledToFill()
                .frame(height: 150)
                .clipped()
                .cornerRadius(12)
                .overlay(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.black.opacity(0.7), Color.clear]),
                        startPoint: .bottom,
                        endPoint: .center
                    )
                )

            VStack(alignment: .leading, spacing: 8) {
                // Mostra le carte selezionate
                HStack {
                    Image(player.SelectedCard1)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 60)
                    Image(player.SelectedCard2)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 60)
                    Spacer()
                }
                Text("\(player.name) (\(player.nickname))")
                    .font(.headline)
                    .foregroundColor(.white)
                Text(player.description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))


            }
            .padding()
        }
        .frame(height: 150)
        .cornerRadius(12)
        .shadow(radius: 4)
    }
}

#Preview {
    PlayerCard(player: Player(id: UUID(), name: "Michele Mariniello", nickname: "Turbo", description: "o fortin", SelectedCard1: "AH", SelectedCard2: "AS"))
}
