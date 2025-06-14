//
//  DeleteErrorAlert.swift
//  LunePoker
//
//  Created by Michele Mariniello on 14/06/25.
//

import SwiftUI

// MARK: - Error Alert
struct DeleteErrorAlert: View {
    let errorMessage: String
    @Binding var showError: Bool
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    showError = false
                }
            
            VStack(spacing: 20) {
                VStack(spacing: 15) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.red)
                    
                    Text("Error")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(errorMessage)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Button("OK") {
                    showError = false
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.accent)
                .foregroundColor(.black)
                .cornerRadius(8)
                .padding(.horizontal)
            }
            .padding(25)
            .frame(maxWidth: 300)
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
//    DeleteErrorAlert()
//}
