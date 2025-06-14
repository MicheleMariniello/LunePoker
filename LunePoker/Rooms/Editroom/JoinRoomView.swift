//
//  JoinRoomView.swift
//  LunePoker
//
//  Created by Michele Mariniello on 14/06/25.
//

import SwiftUI

struct JoinRoomView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var roomCode = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showError = false
    
    let onRoomJoined: (Room) -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 30) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Room Code")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        TextField("Enter room code", text: $roomCode)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.body)
                            .autocapitalization(.allCharacters)
                            .disableAutocorrection(true)
                            .onChange(of: roomCode) { newValue in
                                // Limita a 10 caratteri massimo e converte in maiuscolo
                                if newValue.count > 10 {
                                    roomCode = String(newValue.prefix(10))
                                }
                                roomCode = roomCode.uppercased()
                            }
                    }
                    
                    Button(action: joinRoom) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "arrow.right.circle.fill")
                            }
                            Text("Join Room")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(roomCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.accent)
                        .cornerRadius(12)
                    }
                    .disabled(roomCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Join Room")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.accent)
                }
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func joinRoom() {
        isLoading = true
        
        RoomManager.shared.joinRoom(code: roomCode) { room, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    errorMessage = error.localizedDescription
                    showError = true
                    return
                }
                
                if let room = room {
                    onRoomJoined(room)
                }
            }
        }
    }
}

