//
//  FirebaseManager.swift
//  LunePoker
//
//  Created by Michele Mariniello on 05/04/25.
import SwiftUI
import Foundation
import FirebaseCore
import FirebaseDatabase
import FirebaseAuth

class FirebaseManager {
    static let shared = FirebaseManager()
    
    private let database = Database.database().reference()
    private var matchesRef: DatabaseReference { database.child("matches") }
    private var playersRef: DatabaseReference { database.child("players") }
    
    private init() {
        // Private initializer to ensure singleton
    }
    
    // MARK: - Authentication
    
    func anonymousSignIn(completion: @escaping (Bool, Error?) -> Void) {
        print("Tentativo di accesso anonimo...")
        Auth.auth().signInAnonymously { authResult, error in
            if let error = error {
                print("Error signing in anonymously: \(error.localizedDescription)")
                print("Error code: \(String(describing: (error as NSError).code))")
                print("Error domain: \(String(describing: (error as NSError).domain))")
                completion(false, error)
                return
            }

            print("User signed in anonymously with UID: \(authResult?.user.uid ?? "unknown")")
            completion(true, nil)
        }
    }
    
    // MARK: - Players Methods
    
    func savePlayers(_ players: [Player], completion: @escaping (Error?) -> Void) {
        // Converti array in dizionario con ID come chiavi
        var playersDict = [String: Any]()
        
        for player in players {
            let playerDict: [String: Any] = [
                "id": player.id.uuidString,
                "name": player.name,
                "nickname": player.nickname,
                "description": player.description,
                "SelectedCard1": player.SelectedCard1,
                "SelectedCard2": player.SelectedCard2
            ]
            
            playersDict[player.id.uuidString] = playerDict
        }
        
        playersRef.setValue(playersDict) { error, _ in
            completion(error)
        }
    }
    
    func fetchPlayers(completion: @escaping ([Player]?, Error?) -> Void) {
        playersRef.observeSingleEvent(of: .value) { snapshot, _ in
            guard let value = snapshot.value as? [String: [String: Any]] else {
                completion([], nil)  // No data yet
                return
            }
            
            var players = [Player]()
            
            for (_, playerData) in value {
                if let idString = playerData["id"] as? String,
                   let id = UUID(uuidString: idString),
                   let name = playerData["name"] as? String,
                   let nickname = playerData["nickname"] as? String,
                   let description = playerData["description"] as? String,
                   let card1 = playerData["SelectedCard1"] as? String,
                   let card2 = playerData["SelectedCard2"] as? String {
                    
                    let player = Player(
                        id: id,
                        name: name,
                        nickname: nickname,
                        description: description,
                        SelectedCard1: card1,
                        SelectedCard2: card2
                    )
                    
                    players.append(player)
                }
            }
            
            completion(players, nil)
        }
    }
    
    func observePlayers(completion: @escaping ([Player]?) -> Void) {
        print("Setting up players observer")
        playersRef.observe(.value) { snapshot in
            guard let value = snapshot.value as? [String: [String: Any]] else {
                print("No players data available or invalid format")
                completion([])  // No data or deleted
                return
            }
            
            var players = [Player]()
            
            for (_, playerData) in value {
                if let idString = playerData["id"] as? String,
                   let id = UUID(uuidString: idString),
                   let name = playerData["name"] as? String,
                   let nickname = playerData["nickname"] as? String,
                   let description = playerData["description"] as? String,
                   let card1 = playerData["SelectedCard1"] as? String,
                   let card2 = playerData["SelectedCard2"] as? String {
                    
                    let player = Player(
                        id: id,
                        name: name,
                        nickname: nickname,
                        description: description,
                        SelectedCard1: card1,
                        SelectedCard2: card2
                    )
                    
                    players.append(player)
                }
            }
            print("Processed \(players.count) players")
            completion(players)
        }
    }
    
    // MARK: - Matches Methods
    
    func saveMatches(_ matches: [Match], completion: @escaping (Error?) -> Void) {
        // Converti array in dizionario con ID come chiavi
        var matchesDict = [String: Any]()
        
        for match in matches {
            var participantsArray = [[String: Any]]()
            for participant in match.participants {
                participantsArray.append([
                    "playerID": participant.playerID.uuidString,
                    "entryFee": participant.entryFee
                ])
            }
            
            var winnersArray = [[String: Any]]()
            for winner in match.winners {
                winnersArray.append([
                    "playerID": winner.playerID.uuidString,
                    "position": winner.position,
                    "amount": winner.amount
                ])
            }
            
            let matchDict: [String: Any] = [
                "id": match.id.uuidString,
                "date": match.date.timeIntervalSince1970,
                "participants": participantsArray,
                "totalPrize": match.totalPrize,
                "winners": winnersArray
            ]
            
            matchesDict[match.id.uuidString] = matchDict
        }
        
        matchesRef.setValue(matchesDict) { error, _ in
            completion(error)
        }
    }
    
    func fetchMatches(completion: @escaping ([Match]?, Error?) -> Void) {
        matchesRef.observeSingleEvent(of: .value) { snapshot, _ in
            guard let value = snapshot.value as? [String: [String: Any]] else {
                completion([], nil)  // No data yet
                return
            }
            
            var matches = [Match]()
            
            for (_, matchData) in value {
                if let idString = matchData["id"] as? String,
                   let id = UUID(uuidString: idString),
                   let dateTimestamp = matchData["date"] as? TimeInterval,
                   let totalPrize = matchData["totalPrize"] as? Double,
                   let participantsData = matchData["participants"] as? [[String: Any]],
                   let winnersData = matchData["winners"] as? [[String: Any]] {
                    
                    let date = Date(timeIntervalSince1970: dateTimestamp)
                    
                    var participants = [Participant]()
                    for participantDict in participantsData {
                        if let playerIDString = participantDict["playerID"] as? String,
                           let playerID = UUID(uuidString: playerIDString),
                           let entryFee = participantDict["entryFee"] as? Double {
                            participants.append(Participant(playerID: playerID, entryFee: entryFee))
                        }
                    }
                    
                    var winners = [Winner]()
                    for winnerDict in winnersData {
                        if let playerIDString = winnerDict["playerID"] as? String,
                           let playerID = UUID(uuidString: playerIDString),
                           let position = winnerDict["position"] as? Int,
                           let amount = winnerDict["amount"] as? Double {
                            winners.append(Winner(playerID: playerID, position: position, amount: amount))
                        }
                    }
                    
                    let match = Match(
                        id: id,
                        date: date,
                        participants: participants,
                        totalPrize: totalPrize,
                        winners: winners
                    )
                    
                    matches.append(match)
                }
            }
            
            completion(matches, nil)
        }
    }
    
    func observeMatches(completion: @escaping ([Match]?) -> Void) {
        matchesRef.observe(.value) { snapshot in
            guard let value = snapshot.value as? [String: [String: Any]] else {
                completion([])  // No data or deleted
                return
            }
            
            var matches = [Match]()
            
            for (_, matchData) in value {
                if let idString = matchData["id"] as? String,
                   let id = UUID(uuidString: idString),
                   let dateTimestamp = matchData["date"] as? TimeInterval,
                   let totalPrize = matchData["totalPrize"] as? Double,
                   let participantsData = matchData["participants"] as? [[String: Any]],
                   let winnersData = matchData["winners"] as? [[String: Any]] {
                    
                    let date = Date(timeIntervalSince1970: dateTimestamp)
                    
                    var participants = [Participant]()
                    for participantDict in participantsData {
                        if let playerIDString = participantDict["playerID"] as? String,
                           let playerID = UUID(uuidString: playerIDString),
                           let entryFee = participantDict["entryFee"] as? Double {
                            participants.append(Participant(playerID: playerID, entryFee: entryFee))
                        }
                    }
                    
                    var winners = [Winner]()
                    for winnerDict in winnersData {
                        if let playerIDString = winnerDict["playerID"] as? String,
                           let playerID = UUID(uuidString: playerIDString),
                           let position = winnerDict["position"] as? Int,
                           let amount = winnerDict["amount"] as? Double {
                            winners.append(Winner(playerID: playerID, position: position, amount: amount))
                        }
                    }
                    
                    let match = Match(
                        id: id,
                        date: date,
                        participants: participants,
                        totalPrize: totalPrize,
                        winners: winners
                    )
                    
                    matches.append(match)
                }
            }
            
            completion(matches)
        }
    }
    
    // MARK: - Cleanup
    
    func removeAllObservers() {
        playersRef.removeAllObservers()
        matchesRef.removeAllObservers()
    }
}
