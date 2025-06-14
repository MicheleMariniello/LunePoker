//
//  DeleteButtonSection.swift
//  LunePoker
//
//  Created by Michele Mariniello on 14/06/25.
//

import SwiftUI

// MARK: - Delete Button Section
struct DeleteButtonSection: View {
    let isLoading: Bool
    @Binding var showFinalAlert: Bool
    
    var body: some View {
        VStack(spacing: 10) {
            Button(action: { showFinalAlert = true }) {
                HStack {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "trash.fill")
                            .font(.title3)
                    }
                    Text(isLoading ? "Deleting..." : "Delete Room Forever")
                        .font(.subheadline)
                        .fontWeight(.bold)
                }
                .foregroundColor(.white)
                .frame(width: 250)
                .padding()
                .background(isLoading ? Color.gray : Color.red)
                .cornerRadius(12)
            }
            .disabled(isLoading)
            
            Text("This is your last chance to change your mind")
                .font(.caption2)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.bottom, 20)
        }
    }
}

//#Preview {
//    DeleteButtonSection()
//}
