//
//  Start.swift
//  LunePoker
//
//  Created by Michele Mariniello on 07/04/25.
//

import SwiftUI
import SDWebImageSwiftUI

struct Start: View {
    var body: some View {
        AnimatedImage(name: "StartGif.gif")
            .resizable()
            .ignoresSafeArea()
    }
}

#Preview {
    Start()
}
