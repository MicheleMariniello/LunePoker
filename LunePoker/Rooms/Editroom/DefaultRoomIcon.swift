//
//  DefaultRoomIcon.swift
//  LunePoker
//
//  Created by Michele Mariniello on 14/06/25.
//

import SwiftUI

struct DefaultRoomIcon: View {
    var body: some View {
        Image(systemName: "house.fill")
            .font(.system(size: 40))
            .foregroundColor(.white)
    }
}

#Preview {
    DefaultRoomIcon()
}
