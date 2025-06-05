//
//  Start.swift
//  LunePoker
//
//  Created by Michele Mariniello on 07/04/25.
//

import SwiftUI
import SDWebImageSwiftUI
import AVFoundation

struct Start: View {
    @State private var audioPlayer: AVAudioPlayer?
    
    var body: some View {
        AnimatedImage(name: "StartGif.gif")
//            .resizable()
//            .ignoresSafeArea()
            .background(Color.blackBackGround)
    }
}

#Preview {
    Start()
}
