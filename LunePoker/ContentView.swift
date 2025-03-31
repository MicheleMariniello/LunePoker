//
//  ContentView.swift
//  LunePoker
//
//  Created by Michele Mariniello on 20/03/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    // Accedi agli stessi AppStorage usati in MatchView
    @AppStorage("players") private var playersData: Data = Data()
    @AppStorage("matches") private var matchesData: Data = Data()
    
    // Stati per memorizzare i dati decodificati
    @State private var players: [Player] = []
    @State private var matches: [Match] = []
    
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
            
            StatView(players: players, matches: matches)
                .tabItem {
                    Label("Statistics", systemImage: "chart.bar.fill")
                }
                .tag(2)
        }
        .onAppear {
            loadData()
        }
    }
    
    // Funzione per caricare i dati da AppStorage
    private func loadData() {
        do {
            let decoder = JSONDecoder()
            players = try decoder.decode([Player].self, from: playersData)
            matches = try decoder.decode([Match].self, from: matchesData)
        } catch {
            print("Failed to load data in ContentView: \(error)")
        }
    }
}

#Preview {
    ContentView()
}
