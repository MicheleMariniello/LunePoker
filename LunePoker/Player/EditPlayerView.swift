//
//  EditPlayerView.swift
//  LunePoker
//
//  Created by Michele Mariniello on 26/03/25.
//

import SwiftUI

struct EditPlayerView: View {
    @Environment(\.presentationMode) var presentationMode
    var player: Player
    var saveChanges: (Player) -> Void

    @State private var name: String
    @State private var nickname: String
    @State private var description: String
    @State private var selectedCard1: String
    @State private var selectedCard2: String

    let allCards = ["2H", "3H", "4H", "5H", "6H", "7H", "8H", "9H", "10H", "JH", "QH", "KH", "AH",
                    "2D", "3D", "4D", "5D", "6D", "7D", "8D", "9D", "10D", "JD", "QD", "KD", "AD",
                    "2C", "3C", "4C", "5C", "6C", "7C", "8C", "9C", "10C", "JC", "QC", "KC", "AC",
                    "2S", "3S", "4S", "5S", "6S", "7S", "8S", "9S", "10S", "JS", "QS", "KS", "AS"]
    
    let columns = [GridItem(.adaptive(minimum: 50))]

    init(player: Player, saveChanges: @escaping (Player) -> Void) {
        self.player = player
        self.saveChanges = saveChanges
        _name = State(initialValue: player.name)
        _nickname = State(initialValue: player.nickname)
        _description = State(initialValue: player.description)
        _selectedCard1 = State(initialValue: player.SelectedCard1)
        _selectedCard2 = State(initialValue: player.SelectedCard2)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Player Info")) {
                    TextField("Name", text: $name)
                    TextField("Nickname", text: $nickname)
                    TextField("Description", text: $description)
                }

                Section(header: Text("Seleziona Mano Preferita")) {
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(allCards, id: \.self) { card in
                            Image(card)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 70)
                                .overlay(RoundedRectangle(cornerRadius: 5)
                                    .stroke(isCardSelected(card) ? Color.green : Color.clear, lineWidth: 3))
                                .onTapGesture {
                                    selectCard(card)
                                }
                        }
                    }
                }
            }
            .navigationTitle("Edit Player")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .tint(Color.accent)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let updatedPlayer = Player(id: player.id, name: name, nickname: nickname, description: description, SelectedCard1: selectedCard1, SelectedCard2: selectedCard2)
                        saveChanges(updatedPlayer)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .tint(Color.accent)
                    .disabled(name.isEmpty || nickname.isEmpty || selectedCard1.isEmpty || selectedCard2.isEmpty)
                }
            }
        }
    }

    // Funzione per verificare se una carta è selezionata
    private func isCardSelected(_ card: String) -> Bool {
        return selectedCard1 == card || selectedCard2 == card
    }

    // Funzione per selezionare le carte
    private func selectCard(_ card: String) {
        if selectedCard1 == card {
            selectedCard1 = ""
        } else if selectedCard2 == card {
            selectedCard2 = ""
        } else if selectedCard1.isEmpty {
            selectedCard1 = card
        } else if selectedCard2.isEmpty {
            selectedCard2 = card
        }
    }
}

#Preview {
    EditPlayerView(player: Player(id: UUID(), name: "mike", nickname: "turbo", description: "o fottissim", SelectedCard1: "AS", SelectedCard2: "KS"), saveChanges: {_ in})
}
