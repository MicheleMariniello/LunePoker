//
//  DeleteRoomInfo.swift
//  LunePoker
//
//  Created by Michele Mariniello on 14/06/25.
//

import SwiftUI

// MARK: - Room Info Component
struct DeleteRoomInfo: View {
    let room: Room
    
    var body: some View {
        VStack(spacing: 12) {
            Text("You are about to delete:")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(spacing: 8) {
                // Room image
                DeleteRoomImageView(room: room)
                
                Text(room.name)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Code: \(room.code)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(15)
        }
    }
}

//#Preview {
//    DeleteRoomInfo()
//}
