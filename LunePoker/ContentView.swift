//
//  ContentView.swift
//  LunePoker
//
//  Created by Michele Mariniello on 20/03/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            MatchView()
                .tabItem {
                    Label("Matches", systemImage: "suit.spade.fill")
                }
                .tag(0)
            
            PlayerView()
                .tabItem {
                    Label("Players", systemImage: "person.3.fill")
                }
                .tag(1)
            
            StatView()
                .tabItem {
                    Label("Statistics", systemImage: "chart.bar.fill")
                }
                .tag(2)
        }
    }
}

#Preview {
    ContentView()
}
