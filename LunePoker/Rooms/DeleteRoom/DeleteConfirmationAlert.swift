//
//  DeleteConfirmationAlert.swift
//  LunePoker
//
//  Created by Michele Mariniello on 14/06/25.
//

import SwiftUI

// MARK: - Confirmation Alert
struct DeleteConfirmationAlert: View {
    let room: Room
    @Binding var showAlert: Bool
    let deleteAction: () -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    showAlert = false
                }
            
            VStack(spacing: 20) {
                VStack(spacing: 15) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.red)
                    
                    Text("Final Confirmation")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Are you absolutely sure you want to delete '\(room.name)'?")
                        .font(.headline)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Text("This action is PERMANENT and cannot be reversed. All data will be lost forever.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                HStack(spacing: 15) {
                    Button("Cancel") {
                        showAlert = false
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    
                    Button("Delete") {
                        showAlert = false
                        deleteAction()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red.opacity(0.9))
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding(.horizontal)
            }
            .padding(25)
            .frame(maxWidth: 350)
            .background(Color.black.opacity(0.95))
            .foregroundStyle(.white)
            .cornerRadius(15)
            .shadow(radius: 20)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

//#Preview {
//    DeleteConfirmationAlert()
//}
