//
//  DeleteWarningMessage.swift
//  LunePoker
//
//  Created by Michele Mariniello on 14/06/25.
//

import SwiftUI

// MARK: - Warning Message Component
struct DeleteWarningMessage: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("⚠️ This action cannot be undone!")
                .font(.subheadline)
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Deleting this room will permanently remove:")
                    .font(.caption)
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
                
                DeleteWarningList()
            }
            .padding()
            .background(Color.red.opacity(0.1))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.red.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

#Preview {
    DeleteWarningMessage()
}
