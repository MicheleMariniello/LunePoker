//
//  RoomSelectionView.swift
//  LunePoker
//
//  Created by Michele Mariniello on 14/06/25.
//

import SwiftUI

struct RoomSelectionView: View {
    @StateObject private var roomManager = RoomManager.shared
    @State private var showCreateRoom = false
    @State private var showJoinRoom = false
    @State private var showManageRooms = false
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showError = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 40) {
                // Logo/Title
                VStack(spacing: 10) {
                    Image(systemName: "suit.spade.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.accent)
                    
                    Text("Lune Poker")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Choose your room")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
                
                // Buttons
                VStack(spacing: 20) {
                    Button(action: { showCreateRoom = true }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                            Text("Create New Room")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accent)
                        .cornerRadius(12)
                    }
                    
                    Button(action: { showJoinRoom = true }) {
                        HStack {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.title2)
                            Text("Join Existing Room")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                        )
                    }
                    
                    // Pulsante per gestire room (eliminarle)
                    Button(action: { showManageRooms = true }) {
                        HStack {
                            Image(systemName: "gear")
                                .font(.title2)
                            Text("Manage Rooms")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.clear)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    }
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            
            // Loading overlay
            if isLoading {
                Color.black.opacity(0.7)
                    .ignoresSafeArea()
                
                VStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                    
                    Text("Processing...")
                        .foregroundColor(.white)
                        .padding(.top)
                }
            }
        }
        .sheet(isPresented: $showCreateRoom) {
            CreateRoomView(onRoomCreated: handleRoomCreated)
        }
        .sheet(isPresented: $showJoinRoom) {
            JoinRoomView(onRoomJoined: handleRoomJoined)
        }
        .sheet(isPresented: $showManageRooms) {
            ManageRoomsView()
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func handleRoomCreated(_ room: Room) {
        showCreateRoom = false
    }
    
    private func handleRoomJoined(_ room: Room) {
        showJoinRoom = false
    }
}

struct CreateRoomView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var roomName = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showError = false
    
    let onRoomCreated: (Room) -> Void
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 30) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Room Name")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        TextField("Enter room name", text: $roomName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.body)
                    }
                    
                    Button(action: createRoom) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "plus.circle.fill")
                            }
                            Text("Create Room")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(roomName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.gray : Color.accent)
                        .cornerRadius(12)
                    }
                    .disabled(roomName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Create Room")
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
    
    private func createRoom() {
        isLoading = true
        
        RoomManager.shared.createRoom(name: roomName.trimmingCharacters(in: .whitespacesAndNewlines)) { room, error in
            DispatchQueue.main.async {
                isLoading = false
                
                if let error = error {
                    errorMessage = error.localizedDescription
                    showError = true
                    return
                }
                
                if let room = room {
                    onRoomCreated(room)
                }
            }
        }
    }
}

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

struct ManageRoomsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var rooms: [Room] = []
    @State private var isLoading = false
    @State private var roomToDelete: Room?
    @State private var showDeleteAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack {
                    if isLoading {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(1.5)
                        Text("Loading rooms...")
                            .foregroundColor(.gray)
                            .padding()
                        Spacer()
                    } else if rooms.isEmpty {
                        Spacer()
                        VStack(spacing: 10) {
                            Image(systemName: "house.slash")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            Text("No rooms found")
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 15) {
                                ForEach(rooms, id: \.id) { room in
                                    RoomRowView(room: room) {
                                        roomToDelete = room
                                        showDeleteAlert = true
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("Manage Rooms")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.accent)
                }
            }
        }
        .onAppear {
            loadRooms()
        }
        .alert("Delete Room", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let room = roomToDelete {
                    deleteRoom(room)
                }
            }
        } message: {
            if let room = roomToDelete {
                Text("Are you sure you want to delete '\(room.name)'? This action cannot be undone.")
            }
        }
    }
    
    private func loadRooms() {
        isLoading = true
        RoomManager.shared.fetchAllRooms { fetchedRooms in
            DispatchQueue.main.async {
                self.isLoading = false
                self.rooms = fetchedRooms
            }
        }
    }
    
    private func deleteRoom(_ room: Room) {
        RoomManager.shared.deleteRoom(room) { error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error deleting room: \(error)")
                } else {
                    // Rimuovi la room dalla lista locale
                    self.rooms.removeAll { $0.id == room.id }
                }
            }
        }
    }
}

struct RoomRowView: View {
    let room: Room
    let onDelete: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(room.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("Code: \(room.code)")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text("Created: \(room.createdAt, style: .date)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
                    .font(.title2)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    RoomSelectionView()
}
