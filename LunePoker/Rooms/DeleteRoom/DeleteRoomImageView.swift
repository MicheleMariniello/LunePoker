//
//  DeleteRoomImageView.swift
//  LunePoker
//
//  Created by Michele Mariniello on 14/06/25.
//

import SwiftUI

// MARK: - Room Image Component
struct DeleteRoomImageView: View {
    let room: Room
    
    var body: some View {
        Group {
            if hasValidImageURL {
                AsyncImage(url: URL(string: room.imageURL!)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 70, height: 70)
                        .clipShape(Circle())
                } placeholder: {
                    DefaultDeleteRoomIcon()
                }
            } else {
                DefaultDeleteRoomIcon()
            }
        }
    }
    
    private var hasValidImageURL: Bool {
        if let imageURL = room.imageURL {
            return !imageURL.isEmpty
        }
        return false
    }
}

//#Preview {
//    DeleteRoomImageView()
//}
