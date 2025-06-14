//
//  EditRoomView.swift
//  LunePoker
//
//  Created by Michele Mariniello on 14/06/25.
//

import SwiftUI
import PhotosUI
import FirebaseAuth

struct EditRoomView: View {
    @Binding var room: Room
    @Environment(\.dismiss) private var dismiss
    
    @State private var roomName: String
    @State private var selectedImage: PhotosPickerItem?
    @State private var roomImage: UIImage?
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showImageOptions = false
    @State private var showCamera = false
    @State private var showLeaveAlert = false
    @State private var showDeleteAlert = false
    @State private var showPhotoPicker = false
    
    let onSave: (Room) -> Void
    
    init(room: Binding<Room>, onSave: @escaping (Room) -> Void) {
        self._room = room
        self.onSave = onSave
        self._roomName = State(initialValue: room.wrappedValue.name)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 30) {
                    // Room Image Section
                    VStack(spacing: 15) {
                        Text("Room Image")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Button(action: { showImageOptions = true }) {
                            ZStack {
                                Circle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 120, height: 120)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.accent, lineWidth: 2)
                                    )
                                
                                if let roomImage = roomImage {
                                    Image(uiImage: roomImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 120, height: 120)
                                        .clipShape(Circle())
                                } else if let imageURL = room.imageURL, !imageURL.isEmpty {
                                    AsyncImage(url: URL(string: imageURL)) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 120, height: 120)
                                            .clipShape(Circle())
                                    } placeholder: {
                                        Image(systemName: "house.fill")
                                            .font(.system(size: 40))
                                            .foregroundColor(.white)
                                    }
                                } else {
                                    Image(systemName: "house.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(.white)
                                }
                                
                                // Camera icon overlay
                                VStack {
                                    Spacer()
                                    HStack {
                                        Spacer()
                                        Circle()
                                            .fill(Color.accent)
                                            .frame(width: 30, height: 30)
                                            .overlay(
                                                Image(systemName: "camera.fill")
                                                    .font(.system(size: 15))
                                                    .foregroundColor(.black)
                                            )
                                            .offset(x: -10, y: -10)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Room Name Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Room Name")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        TextField("Enter room name", text: $roomName)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(10)
                            .foregroundColor(.white)
                            .font(.body)
                    }
                    
                    // Room Info
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Room Details")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        HStack {
                            Text("Code:")
                                .foregroundColor(.gray)
                            Text(room.code)
                                .foregroundColor(.white)
                                .fontWeight(.bold)
                        }
                        
                        HStack {
                            Text("Created:")
                                .foregroundColor(.gray)
                            Text(room.createdAt, style: .date)
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    
                    Spacer()
                    Button(action: saveChanges) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                    .scaleEffect(0.8)
                            }
                            Text(isLoading ? "Saving..." : "Save Changes")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accent)
                        .cornerRadius(12)
                    }
                    .disabled(isLoading || roomName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    
                    // Leave Room Button
                    Button(action: { showLeaveAlert = true }) {
                        HStack {
                            Image(systemName: "arrow.left.circle.fill")
                            Text("Leave Room")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accent)
                        .cornerRadius(12)
                    }
                    .padding(.bottom, 10)
                    
                    Button(action: { showDeleteAlert = true }) {
                        HStack {
                            Image(systemName: "trash.circle.fill")
                            Text("Delete Room")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.7))
                        .cornerRadius(12)
                    }
                    .padding(.bottom, 10)

                }
                .padding()
            }
            .navigationTitle("Edit Room")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() }.foregroundColor(.accent),
                trailing: EmptyView()
            )
        }
        .preferredColorScheme(.dark)
        .confirmationDialog("Select Image Source", isPresented: $showImageOptions) {
            Button("Photo Library") {
                showPhotoPicker = true
            }
            Button("Camera") {
                showCamera = true
            }
            Button("Cancel", role: .cancel) { }
        }
        .photosPicker(isPresented: $showPhotoPicker, selection: $selectedImage, matching: .images)
        .fullScreenCover(isPresented: $showCamera) {
            ImagePicker(image: $roomImage, sourceType: .camera)
        }
        .onChange(of: selectedImage) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    await MainActor.run {
                        roomImage = uiImage
                    }
                }
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .alert("Leave Room", isPresented: $showLeaveAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Leave", role: .destructive) {
                RoomManager.shared.leaveRoom()
                dismiss()
            }
        } message: {
            Text("Are you sure you want to leave this room? You'll need the room code to rejoin.")
        }
        .alert("Delete Room", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                deleteRoom()
            }
        } message: {
            Text("Are you sure you want to permanently delete this room? This action cannot be undone and will remove all players, matches, and statistics.")
        }
    }
    
    private func saveChanges() {
        guard !roomName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Room name cannot be empty"
            showError = true
            return
        }
        
        isLoading = true
        print("Starting save process...")
        
        // Se c'è una nuova immagine, prima la carichiamo
        if let roomImage = roomImage,
           let imageData = roomImage.jpegData(compressionQuality: 0.7) {
            
            print("Uploading new image, size: \(imageData.count) bytes")
            
            FirebaseManager.shared.uploadRoomImageAsBase64(imageData, roomId: room.id) { imageURL, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("Upload failed: \(error.localizedDescription)")
                        self.isLoading = false
                        self.errorMessage = "Failed to upload image: \(error.localizedDescription)"
                        self.showError = true
                        return
                    }
                    
                    print("Upload successful, URL: \(imageURL ?? "nil")")
                    
                    // Aggiorna la room con la nuova immagine e il nome
                    var updatedRoom = self.room
                    updatedRoom.name = self.roomName.trimmingCharacters(in: .whitespacesAndNewlines)
                    updatedRoom.imageURL = imageURL
                    
                    self.updateRoomInFirebase(updatedRoom)
                }
            }
        } else {
            print("No new image, updating only name")
            // Solo aggiornamento del nome
            var updatedRoom = room
            updatedRoom.name = roomName.trimmingCharacters(in: .whitespacesAndNewlines)
            updateRoomInFirebase(updatedRoom)
        }
    }
    
    private func updateRoomInFirebase(_ updatedRoom: Room) {
        FirebaseManager.shared.updateRoom(updatedRoom) { error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Failed to update room: \(error.localizedDescription)"
                    self.showError = true
                    return
                }
                
                // Successo - aggiorna la room e chiudi
                self.room = updatedRoom
                self.onSave(updatedRoom)
                self.dismiss()
            }
        }
    }
    
    private func deleteRoom() {
        isLoading = true
        
        FirebaseManager.shared.deleteRoom(room) { error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Failed to delete room: \(error.localizedDescription)"
                    self.showError = true
                    return
                }
                
                // Successo - esci dalla room e chiudi
                RoomManager.shared.leaveRoom()
                self.dismiss()
            }
        }
    }
}

// MARK: - ImagePicker for Camera
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    let sourceType: UIImagePickerController.SourceType
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            picker.dismiss(animated: true)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
