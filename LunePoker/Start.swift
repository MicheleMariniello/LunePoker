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
            .resizable()
            .ignoresSafeArea()
            .onAppear {
                playSplashScreenSound()
            }
    }

    private func playSplashScreenSound() {
        guard let soundURL = Bundle.main.url(forResource: "Start_Sound", withExtension: "mp3") else {
            print("Error: Could not find sound file.")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.play()
        } catch {
            print("Error playing sound: \(error.localizedDescription)")
        }
    }
}

#Preview {
    Start()
}
