//
//  DefaultDeleteRoomIcon.swift
//  LunePoker
//
//  Created by Michele Mariniello on 14/06/25.
//

import SwiftUI

// MARK: - Default Room Icon
struct DefaultDeleteRoomIcon: View {
    var body: some View {
        Circle()
            .fill(Color.gray.opacity(0.3))
            .frame(width: 70, height: 70)
            .overlay(
                Image(systemName: "house.fill")
                    .foregroundColor(.white)
                    .font(.title2)
            )
    }
}

#Preview {
    DefaultDeleteRoomIcon()
}
