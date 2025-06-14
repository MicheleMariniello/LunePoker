//
//  ContentView.swift
//  LunePoker
//
//  Created by Michele Mariniello on 20/03/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @StateObject private var roomManager = RoomManager.shared
    
    // Accedi agli stessi AppStorage usati in MatchView
    @AppStorage("players") private var playersData: Data = Data()
    @AppStorage("matches") private var matchesData: Data = Data()
    
    // Stati per memorizzare i dati decodificati
    @State private var players: [Player] = []
    @State private var matches: [Match] = []
    @State private var showRoomInfo = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header con info room
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(roomManager.currentRoom?.name ?? "Room")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    if let room = roomManager.currentRoom {
                        Text("Code: \(room.code)")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
                
                Button(action: { showRoomInfo = true }) {
                    Image(systemName: "info.circle")
                        .font(.title2)
                        .foregroundColor(.accent)
                }
            }
            .padding()
            .background(Color.black)
            
            // Tab view principale
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
            .tint(Color.accent)
        }
        .onAppear {
            // Configurazione per eliminare la barra grigia
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithOpaqueBackground()
            tabBarAppearance.backgroundColor = UIColor.black
            
            // Rimuove la linea separatrice in alto
            tabBarAppearance.shadowColor = UIColor.clear
            
            UITabBar.appearance().standardAppearance = tabBarAppearance
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            
            UITabBar.appearance().unselectedItemTintColor = UIColor.gray
            loadData()
        }
        .sheet(isPresented: $showRoomInfo) {
            RoomInfoView()
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

struct RoomInfoView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var roomManager = RoomManager.shared
    @State private var showLeaveAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 30) {
                    if let room = roomManager.currentRoom {
                        VStack(spacing: 20) {
                            // Room icon
                            Image(systemName: "house.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.accent)
                            
                            // Room info
                            VStack(spacing: 10) {
                                Text(room.name)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                VStack(spacing: 5) {
                                    Text("Room Code")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    
                                    Text(room.code)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.accent)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 10)
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(10)
                                }
                                
                                Text("Share this code with your friends to invite them!")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .padding(.top, 5)
                            }
                        }
                        
                        Spacer()
                        
                        // Leave room button
                        Button(action: { showLeaveAlert = true }) {
                            HStack {
                                Image(systemName: "arrow.left.circle.fill")
                                Text("Leave Room")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.8))
                            .cornerRadius(12)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Room Info")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.accent)
                }
            }
        }
        .alert("Leave Room", isPresented: $showLeaveAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Leave", role: .destructive) {
                roomManager.leaveRoom()
                dismiss()
            }
        } message: {
            Text("Are you sure you want to leave this room? You'll need the room code to rejoin.")
        }
    }
}
#Preview {
    ContentView()
}
