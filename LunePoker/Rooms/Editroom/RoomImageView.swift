//
//  RoomImageView.swift
//  LunePoker
//
//  Created by Michele Mariniello on 14/06/25.
//

import SwiftUI

// MARK: - Room Image Components
struct RoomImageView: View {
    let roomImage: UIImage?
    let imageURL: String?
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: 120, height: 120)
                .overlay(
                    Circle()
                        .stroke(Color.accent, lineWidth: 2)
                )
            
            // Content based on available image
            if let roomImage = roomImage {
                Image(uiImage: roomImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
            } else if let imageURL = imageURL, !imageURL.isEmpty {
                AsyncImageView(imageURL: imageURL)
            } else {
                DefaultRoomIcon()
            }
        }
    }
}

//#Preview {
//    RoomImageView()
//}
