//
//  AddPlayerView.swift
//  LunePoker
//
//  Created by Michele Mariniello on 26/03/25.
//

import SwiftUI

struct AddPlayerView: View {
    @Binding var isPresented: Bool
    var savePlayer: (String, String, String, String, String) -> Void

    @State private var name = ""
    @State private var nickname = ""
    @State private var description = ""
    
    @State private var selectedCards: [String] = []

    let allCards = ["2H", "3H", "4H", "5H", "6H", "7H", "8H", "9H", "10H", "JH", "QH", "KH", "AH",
                    "2C", "3C", "4C", "5C", "6C", "7C", "8C", "9C", "10C", "JC", "QC", "KC", "AC",
                    "2D", "3D", "4D", "5D", "6D", "7D", "8D", "9D", "10D", "JD", "QD", "KD", "AD",
                    "2S", "3S", "4S", "5S", "6S", "7S", "8S", "9S", "10S", "JS", "QS", "KS", "AS"]

    let columns = [GridItem(.adaptive(minimum: 50))]

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Info Giocatore")) {
                    TextField("Nome", text: $name)
                    TextField("Nickname", text: $nickname)
                    TextField("Descrizione", text: $description)
                }

                Section(header: Text("Seleziona Mano Preferita")) {
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(allCards, id: \.self) { card in
                            Image(card)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 50, height: 70)
                                .overlay(RoundedRectangle(cornerRadius: 5)
                                    .stroke(selectedCards.contains(card) ? Color.green : Color.clear, lineWidth: 3))
                                .onTapGesture {
                                    selectCard(card)
                                }
                        }
                    }
                }
            }
            .navigationTitle("Nuovo Giocatore")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        if !name.isEmpty && !nickname.isEmpty && selectedCards.count == 2 {
                            savePlayer(name, nickname, description, selectedCards[0], selectedCards[1])
                            isPresented = false
                        }
                    }
                    .disabled(name.isEmpty || nickname.isEmpty || selectedCards.count != 2)
                }
            }
        }
    }

    // Funzione per gestire la selezione delle carte
    private func selectCard(_ card: String) {
        if selectedCards.contains(card) {
            selectedCards.removeAll { $0 == card }
        } else if selectedCards.count < 2 {
            selectedCards.append(card)
        }
    }
}

#Preview {
    @Previewable @State var isPresented = true
    
    AddPlayerView(isPresented: $isPresented) { name, nickname, description,arg,arg  in
        print("New player added: \(name), \(nickname), \(description)")
    }
}
