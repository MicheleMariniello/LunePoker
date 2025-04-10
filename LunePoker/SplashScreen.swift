//
//  SplashScreen.swift
//  LunePoker
//
//  Created by Michele Mariniello on 09/04/25.
//

import SwiftUI

struct SplashScreen: View {
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                // Logo dell'app
                Text("Lune Poker")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                
                Text("Connecting to servers in progress...")
                    .foregroundColor(.gray)
            }
        }
    }
}

#Preview {
    SplashScreen()
}
