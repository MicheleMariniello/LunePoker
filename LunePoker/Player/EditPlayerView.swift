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
    @State private var selectedCard1 = ""
    @State private var selectedCard2 = ""

    init(player: Player, saveChanges: @escaping (Player) -> Void) {
        self.player = player
        self.saveChanges = saveChanges
        _name = State(initialValue: player.name)
        _nickname = State(initialValue: player.nickname)
        _description = State(initialValue: player.description)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Edit Player")) {
                    TextField("Name", text: $name)
                    TextField("Nickname", text: $nickname)
                    TextField("Description", text: $description)
                }
            }
            .navigationTitle("Edit Player")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let updatedPlayer = Player(id: player.id, name: name, nickname: nickname, description: description, SelectedCard1: selectedCard1, SelectedCard2: selectedCard2)
                        saveChanges(updatedPlayer)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .disabled(name.isEmpty || nickname.isEmpty)
                }
            }
        }
    }
}

#Preview {
    EditPlayerView(player: Player(id: UUID(), name: "mike", nickname: "turbo", description: "o fottissim", SelectedCard1: "AS", SelectedCard2: "KS"), saveChanges: {_ in})
}
