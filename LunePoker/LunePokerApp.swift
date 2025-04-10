//
//  LunePokerApp.swift
//  LunePoker
//
//  Created by Michele Mariniello on 20/03/25.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import SDWebImageSwiftUI

@main
struct LunePokerApp: App {
    
    // Stato per tracciare se l'utente è autenticato
    @State private var isAuthenticated = false
    @State private var isInitializing = true
    @State private var showSplashGif = true
    
    // Stati per le animazioni di transizione
    @State private var splashOpacity = 1.0
    @State private var loadingOpacity = 0.0
    @State private var contentOpacity = 0.0
    
    init() {
        // Configurazione di Firebase
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                ContentView()
                    .opacity(contentOpacity)
                
                SplashScreen()
                    .opacity(loadingOpacity)
                
                Start()
                    .opacity(splashOpacity)
                    .onAppear {
                        startAppSequence()
                    }
                
                // Schermata di errore
                if !isAuthenticated && !isInitializing && !showSplashGif {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.yellow)
                        
                        Text("Unable to connect to server")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Please check your internet connection and try again.")
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button("Try again") {
                            // Riavvia la sequenza di caricamento con animazione
                            withAnimation(.easeIn(duration: 0.3)) {
                                loadingOpacity = 1.0
                                contentOpacity = 0.0
                            }
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
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.5), value: isAuthenticated)
                    .animation(.easeInOut(duration: 0.5), value: isInitializing)
                }
            }
            .preferredColorScheme(.dark)
            .onDisappear {
                FirebaseManager.shared.removeAllObservers()
            }
        }
    }
    
    // Funzione per gestire la sequenza completa di avvio con animazioni fluide
    private func startAppSequence() {
        // 1. Mostra la GIF di splash per 2.5 secondi
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
            // 2. Inizia la transizione dalla GIF alla schermata di caricamento
            withAnimation(.easeInOut(duration: 0.8)) {
                splashOpacity = 0.0
                loadingOpacity = 1.0
            }
            
            showSplashGif = false
            
            // 3. Avvia il processo di autenticazione
            authenticateUser()
        }
    }
    
    // Funzione per autenticare l'utente in modo anonimo
    private func authenticateUser() {
        FirebaseManager.shared.anonymousSignIn { success, error in
            DispatchQueue.main.async {
                isInitializing = false
                isAuthenticated = success
                
                // 4. Transizione dalla schermata di caricamento all'app o all'errore
                withAnimation(.easeInOut(duration: 0.7)) {
                    loadingOpacity = 0.0
                    if success {
                        contentOpacity = 1.0
                    }
                }
                
                if !success {
                    print("Error authenticating: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }
}
