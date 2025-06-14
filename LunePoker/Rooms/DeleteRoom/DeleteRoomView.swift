//
//  DeleteRoomView.swift
//  LunePoker
//
//  Created by Michele Mariniello on 14/06/25.
//

import SwiftUI
import FirebaseAuth

struct DeleteRoomView: View {
    let room: Room
    let onRoomDeleted: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = false
    @State private var showFinalAlert = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    LazyVStack(spacing: 25) {
                        // Warning Icon Section
                        DeleteWarningHeader()
                        
                        // Room Info Section
                        DeleteRoomInfo(room: room)
                        
                        // Warning Message Section
                        DeleteWarningMessage()
                        
                        // Delete Button Section
                        DeleteButtonSection(
                            isLoading: isLoading,
                            showFinalAlert: $showFinalAlert
                        )
                    }
                    .padding()
                }
            }
            .navigationTitle("Delete Room")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                }
                .foregroundColor(.accent)
                .disabled(isLoading),
                trailing: EmptyView()
            )
        }
        .preferredColorScheme(.dark)
        .overlay(
            // Custom Final Confirmation Alert
            Group {
                if showFinalAlert {
                    DeleteConfirmationAlert(
                        room: room,
                        showAlert: $showFinalAlert,
                        deleteAction: deleteRoom
                    )
                }
            }
        )
        .overlay(
            // Custom Error Alert
            Group {
                if showError {
                    DeleteErrorAlert(
                        errorMessage: errorMessage,
                        showError: $showError
                    )
                }
            }
        )
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
                
                // Successo - chiama il callback e chiudi
                self.onRoomDeleted()
                self.dismiss()
            }
        }
    }
}

//// MARK: - Warning Header Component
//struct DeleteWarningHeader: View {
//    var body: some View {
//        VStack(spacing: 15) {
//            Image(systemName: "exclamationmark.triangle.fill")
//                .font(.system(size: 60))
//                .foregroundColor(.red)
//            
//            Text("Danger Zone")
//                .font(.title)
//                .fontWeight(.bold)
//                .foregroundColor(.red)
//        }
//        .padding(.top, 20)
//    }
//}

//// MARK: - Room Info Component
//struct DeleteRoomInfo: View {
//    let room: Room
//    
//    var body: some View {
//        VStack(spacing: 12) {
//            Text("You are about to delete:")
//                .font(.headline)
//                .foregroundColor(.white)
//            
//            VStack(spacing: 8) {
//                // Room image
//                DeleteRoomImageView(room: room)
//                
//                Text(room.name)
//                    .font(.title3)
//                    .fontWeight(.bold)
//                    .foregroundColor(.white)
//                
//                Text("Code: \(room.code)")
//                    .font(.subheadline)
//                    .foregroundColor(.gray)
//            }
//            .padding()
//            .background(Color.gray.opacity(0.1))
//            .cornerRadius(15)
//        }
//    }
//}

//// MARK: - Warning Message Component
//struct DeleteWarningMessage: View {
//    var body: some View {
//        VStack(spacing: 12) {
//            Text("⚠️ This action cannot be undone!")
//                .font(.subheadline)
//                .foregroundColor(.red)
//                .multilineTextAlignment(.center)
//                .fontWeight(.semibold)
//            
//            VStack(alignment: .leading, spacing: 6) {
//                Text("Deleting this room will permanently remove:")
//                    .font(.caption)
//                    .foregroundColor(.white)
//                    .fontWeight(.semibold)
//                
//                DeleteWarningList()
//            }
//            .padding()
//            .background(Color.red.opacity(0.1))
//            .cornerRadius(10)
//            .overlay(
//                RoundedRectangle(cornerRadius: 10)
//                    .stroke(Color.red.opacity(0.3), lineWidth: 1)
//            )
//        }
//    }
//}

//// MARK: - Warning List Component
//struct DeleteWarningList: View {
//    var body: some View {
//        VStack(alignment: .leading, spacing: 3) {
//            HStack {
//                Text("•")
//                    .foregroundColor(.red)
//                Text("All players and their information")
//                    .foregroundColor(.gray)
//                    .font(.caption)
//            }
//            
//            HStack {
//                Text("•")
//                    .foregroundColor(.red)
//                Text("All match history and results")
//                    .foregroundColor(.gray)
//                    .font(.caption)
//            }
//            
//            HStack {
//                Text("•")
//                    .foregroundColor(.red)
//                Text("All statistics and analytics")
//                    .foregroundColor(.gray)
//                    .font(.caption)
//            }
//            
//            HStack {
//                Text("•")
//                    .foregroundColor(.red)
//                Text("Room settings and customizations")
//                    .foregroundColor(.gray)
//                    .font(.caption)
//            }
//        }
//    }
//}

//// MARK: - Delete Button Section
//struct DeleteButtonSection: View {
//    let isLoading: Bool
//    @Binding var showFinalAlert: Bool
//    
//    var body: some View {
//        VStack(spacing: 10) {
//            Button(action: { showFinalAlert = true }) {
//                HStack {
//                    if isLoading {
//                        ProgressView()
//                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
//                            .scaleEffect(0.8)
//                    } else {
//                        Image(systemName: "trash.fill")
//                            .font(.title3)
//                    }
//                    Text(isLoading ? "Deleting..." : "Delete Room Forever")
//                        .font(.subheadline)
//                        .fontWeight(.bold)
//                }
//                .foregroundColor(.white)
//                .frame(width: 250)
//                .padding()
//                .background(isLoading ? Color.gray : Color.red)
//                .cornerRadius(12)
//            }
//            .disabled(isLoading)
//            
//            Text("This is your last chance to change your mind")
//                .font(.caption2)
//                .foregroundColor(.gray)
//                .multilineTextAlignment(.center)
//                .padding(.bottom, 20)
//        }
//    }
//}

//// MARK: - Room Image Component
//struct DeleteRoomImageView: View {
//    let room: Room
//    
//    var body: some View {
//        Group {
//            if hasValidImageURL {
//                AsyncImage(url: URL(string: room.imageURL!)) { image in
//                    image
//                        .resizable()
//                        .scaledToFill()
//                        .frame(width: 70, height: 70)
//                        .clipShape(Circle())
//                } placeholder: {
//                    DefaultDeleteRoomIcon()
//                }
//            } else {
//                DefaultDeleteRoomIcon()
//            }
//        }
//    }
//    
//    private var hasValidImageURL: Bool {
//        if let imageURL = room.imageURL {
//            return !imageURL.isEmpty
//        }
//        return false
//    }
//}

//// MARK: - Default Room Icon
//struct DefaultDeleteRoomIcon: View {
//    var body: some View {
//        Circle()
//            .fill(Color.gray.opacity(0.3))
//            .frame(width: 70, height: 70)
//            .overlay(
//                Image(systemName: "house.fill")
//                    .foregroundColor(.white)
//                    .font(.title2)
//            )
//    }
//}

//// MARK: - Confirmation Alert
//struct DeleteConfirmationAlert: View {
//    let room: Room
//    @Binding var showAlert: Bool
//    let deleteAction: () -> Void
//    
//    var body: some View {
//        ZStack {
//            Color.black.opacity(0.7)
//                .edgesIgnoringSafeArea(.all)
//                .onTapGesture {
//                    showAlert = false
//                }
//            
//            VStack(spacing: 20) {
//                VStack(spacing: 15) {
//                    Image(systemName: "exclamationmark.triangle.fill")
//                        .font(.system(size: 50))
//                        .foregroundColor(.red)
//                    
//                    Text("Final Confirmation")
//                        .font(.title2)
//                        .fontWeight(.bold)
//                        .foregroundColor(.white)
//                    
//                    Text("Are you absolutely sure you want to delete '\(room.name)'?")
//                        .font(.headline)
//                        .foregroundColor(.white)
//                        .multilineTextAlignment(.center)
//                        .padding(.horizontal)
//                    
//                    Text("This action is PERMANENT and cannot be reversed. All data will be lost forever.")
//                        .font(.subheadline)
//                        .foregroundColor(.gray)
//                        .multilineTextAlignment(.center)
//                        .padding(.horizontal)
//                }
//                
//                HStack(spacing: 15) {
//                    Button("Cancel") {
//                        showAlert = false
//                    }
//                    .padding()
//                    .frame(maxWidth: .infinity)
//                    .background(Color.gray.opacity(0.7))
//                    .foregroundColor(.white)
//                    .cornerRadius(8)
//                    
//                    Button("DELETE FOREVER") {
//                        showAlert = false
//                        deleteAction()
//                    }
//                    .padding()
//                    .frame(maxWidth: .infinity)
//                    .background(Color.red.opacity(0.9))
//                    .foregroundColor(.white)
//                    .cornerRadius(8)
//                }
//                .padding(.horizontal)
//            }
//            .padding(25)
//            .frame(maxWidth: 350)
//            .background(Color.black.opacity(0.95))
//            .foregroundStyle(.white)
//            .cornerRadius(15)
//            .shadow(radius: 20)
//            .overlay(
//                RoundedRectangle(cornerRadius: 15)
//                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
//            )
//        }
//    }
//}

//// MARK: - Error Alert
//struct DeleteErrorAlert: View {
//    let errorMessage: String
//    @Binding var showError: Bool
//    
//    var body: some View {
//        ZStack {
//            Color.black.opacity(0.7)
//                .edgesIgnoringSafeArea(.all)
//                .onTapGesture {
//                    showError = false
//                }
//            
//            VStack(spacing: 20) {
//                VStack(spacing: 15) {
//                    Image(systemName: "xmark.circle.fill")
//                        .font(.system(size: 50))
//                        .foregroundColor(.red)
//                    
//                    Text("Error")
//                        .font(.title2)
//                        .fontWeight(.bold)
//                        .foregroundColor(.white)
//                    
//                    Text(errorMessage)
//                        .font(.subheadline)
//                        .foregroundColor(.gray)
//                        .multilineTextAlignment(.center)
//                        .padding(.horizontal)
//                }
//                
//                Button("OK") {
//                    showError = false
//                }
//                .padding()
//                .frame(maxWidth: .infinity)
//                .background(Color.accent)
//                .foregroundColor(.black)
//                .cornerRadius(8)
//                .padding(.horizontal)
//            }
//            .padding(25)
//            .frame(maxWidth: 300)
//            .background(Color.black.opacity(0.95))
//            .foregroundStyle(.white)
//            .cornerRadius(15)
//            .shadow(radius: 20)
//            .overlay(
//                RoundedRectangle(cornerRadius: 15)
//                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
//            )
//        }
//    }
//}

#Preview {
    DeleteRoomView(
        room: Room(
            id: "preview-room-id",
            name: "My Poker Room",
            code: "ABC123",
            createdAt: Date(),
            createdBy: "user123",
            imageURL: nil
        )
    ) {
        print("Room deleted in preview")
    }
}
