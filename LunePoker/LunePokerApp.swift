//
//  LunePokerApp.swift
//  LunePoker
//
//  Created by Michele Mariniello on 20/03/25.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

@main
struct LunePokerApp: App {
    
    // Stato per tracciare se l'utente è autenticato
    @State private var isAuthenticated = false
    @State private var isInitializing = true

    
    init() {
        // Configurazione di Firebase
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .opacity(isAuthenticated && !isInitializing ? 1 : 0)
                
                if isInitializing {
                    SplashScreen()
                        .onAppear {
                            authenticateUser()
                        }
                } else if !isAuthenticated {
                    // Schermata di errore di autenticazione
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.yellow)
                        
                        Text("Impossibile connettersi al server")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Verifica la tua connessione internet e riprova.")
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button("Riprova") {
                            isInitializing = true
                            authenticateUser()
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(15)
                    .shadow(radius: 10)
                    .padding(30)
                }
            }
            .preferredColorScheme(.dark)
            .onDisappear {
                // Rimuovi tutti gli osservatori quando l'app viene chiusa
                FirebaseManager.shared.removeAllObservers()
            }
        }
    }
    
    // Funzione per autenticare l'utente in modo anonimo
    private func authenticateUser() {
        FirebaseManager.shared.anonymousSignIn { success, error in
            DispatchQueue.main.async {
                isInitializing = false
                isAuthenticated = success
                
                if !success {
                    print("Error authenticating: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }
}

// Schermata di caricamento iniziale
struct SplashScreen: View {
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                // Qui potresti mettere il logo dell'app
                Text("Lune Poker")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
                
                Text("Connessione ai server in corso...")
                    .foregroundColor(.gray)
            }
        }
    }
}
