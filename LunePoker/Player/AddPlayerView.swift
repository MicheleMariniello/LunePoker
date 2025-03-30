//
//  AddPlayerView.swift
//  LunePoker
//
//  Created by Michele Mariniello on 26/03/25.
//

import SwiftUI

struct AddPlayerView: View {
    @Binding var isPresented: Bool
    var savePlayer: (String, String, String) -> Void

    @State private var name = ""
    @State private var nickname = ""
    @State private var description = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Player Info")) {
                    TextField("Name", text: $name)
                    TextField("Nickname", text: $nickname)
                    TextField("Description", text: $description)
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
                            savePlayer(name, nickname, description)
                            isPresented = false
                        }
                    }
                    .disabled(name.isEmpty || nickname.isEmpty)
                }
            }
        }
    }
}
//#Preview {
//    AddPlayerView(isPresented: true, savePlayer: addPlayer)
//}
