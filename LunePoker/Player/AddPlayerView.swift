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
    @State private var selectedCard1 = ""
    @State private var selectedCard2 = ""

    let suits = ["S", "H", "D", "C"] // Picche, Cuori, Quadri, Fiori
    let ranks = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]

    var deck: [String] {
        ranks.flatMap { rank in suits.map { suit in "\(rank)\(suit)" } }
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Player Info")) {
                    TextField("Name", text: $name)
                    TextField("Nickname", text: $nickname)
                    TextField("Description", text: $description)
                }

                Section(header: Text("Favorite Hand")) {
                    HStack {
                        Picker("Card 1", selection: $selectedCard1) {
                            ForEach(deck, id: \.self) { card in
                                Text(card)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())

                        Picker("Card 2", selection: $selectedCard2) {
                            ForEach(deck, id: \.self) { card in
                                Text(card)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    
                    HStack {
                        CardView(cardName: selectedCard1)
                        CardView(cardName: selectedCard2)
                    }
                }
            }
            .navigationTitle("New Player")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        if !name.isEmpty && !nickname.isEmpty {
                            savePlayer(name, nickname, description, selectedCard1, selectedCard2)
                            isPresented = false
                        }
                    }
                    .disabled(name.isEmpty || nickname.isEmpty)
                }
            }
        }
    }
}

// View per mostrare l'immagine della carta
struct CardView: View {
    var cardName: String

    var body: some View {
        Image(cardName)
            .resizable()
            .frame(width: 50, height: 70)
            .shadow(radius: 2)
    }
}



#Preview {
    @Previewable @State var isPresented = true
    
    AddPlayerView(isPresented: $isPresented) { name, nickname, description,arg,arg  in
        print("New player added: \(name), \(nickname), \(description)")
    }
}
