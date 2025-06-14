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
    
    // Riferimenti dinamici basati sulla room corrente
    private var matchesRef: DatabaseReference {
        guard let roomId = RoomManager.shared.getRoomId() else {
            fatalError("No room selected. Cannot access matches.")
        }
        return database.child("rooms").child(roomId).child("matches")
    }
    
    private var playersRef: DatabaseReference {
        guard let roomId = RoomManager.shared.getRoomId() else {
            fatalError("No room selected. Cannot access players.")
        }
        return database.child("rooms").child(roomId).child("players")
    }
    
    // Proprietà per current room ID (per evitare di chiamare RoomManager ripetutamente)
    var currentRoomId: String? {
        return RoomManager.shared.getRoomId()
    }
    
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
    
    // MARK: - Room Safety Check
    
    private func checkRoomAvailability() -> Bool {
        return RoomManager.shared.getRoomId() != nil
    }
    
    // MARK: - Players Methods
    
    func savePlayers(_ players: [Player], completion: @escaping (Error?) -> Void) {
        guard checkRoomAvailability() else {
            completion(NSError(domain: "FirebaseManager", code: 1001, userInfo: [NSLocalizedDescriptionKey: "No room selected"]))
            return
        }
        
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
        guard checkRoomAvailability() else {
            completion(nil, NSError(domain: "FirebaseManager", code: 1001, userInfo: [NSLocalizedDescriptionKey: "No room selected"]))
            return
        }
        
        playersRef.observeSingleEvent(of: .value) { snapshot, _ in
            guard let value = snapshot.value as? [String: [String: Any]] else {
                completion([], nil)
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
        guard checkRoomAvailability() else {
            print("No room selected for observing players")
            completion([])
            return
        }
        
        print("Setting up players observer for room: \(RoomManager.shared.getRoomId() ?? "unknown")")
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
        guard checkRoomAvailability() else {
            completion(NSError(domain: "FirebaseManager", code: 1001, userInfo: [NSLocalizedDescriptionKey: "No room selected"]))
            return
        }
        
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
        guard checkRoomAvailability() else {
            completion(nil, NSError(domain: "FirebaseManager", code: 1001, userInfo: [NSLocalizedDescriptionKey: "No room selected"]))
            return
        }
        
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
        guard checkRoomAvailability() else {
            print("No room selected for observing matches")
            completion([])
            return
        }
        
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
    
    // MARK: - Statistics
    
    // Le statistiche vengono calcolate dinamicamente dai dati esistenti
    // Non c'è bisogno di salvarle separatamente, dato che sono derivate
    
    func fetchStatisticsData(completion: @escaping ([Player], [Match], Error?) -> Void) {
        guard let currentRoomId = currentRoomId else {
            completion([], [], NSError(domain: "FirebaseManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "No current room"]))
            return
        }
        
        let group = DispatchGroup()
        var players: [Player] = []
        var matches: [Match] = []
        var fetchError: Error?
        
        // Fetch players
        group.enter()
        fetchPlayers { fetchedPlayers, error in
            if let error = error {
                fetchError = error
            } else if let fetchedPlayers = fetchedPlayers {
                players = fetchedPlayers
            }
            group.leave()
        }
        
        // Fetch matches
        group.enter()
        fetchMatches { fetchedMatches, error in
            if let error = error {
                fetchError = error
            } else if let fetchedMatches = fetchedMatches {
                matches = fetchedMatches
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            completion(players, matches, fetchError)
        }
    }
    
    // MARK: - Room Management
    
    func fetchAllRooms(completion: @escaping ([Room]) -> Void) {
        database.child("rooms").observeSingleEvent(of: .value) { snapshot in
            var rooms: [Room] = []
            
            guard let roomsData = snapshot.value as? [String: [String: Any]] else {
                completion([])
                return
            }
            
            for (roomId, roomData) in roomsData {
                if let infoData = roomData["info"] as? [String: Any],
                   let id = infoData["id"] as? String,
                   let name = infoData["name"] as? String,
                   let code = infoData["code"] as? String,
                   let createdAtTimestamp = infoData["createdAt"] as? TimeInterval,
                   let createdBy = infoData["createdBy"] as? String {
                    
                    let room = Room(
                        id: id,
                        name: name,
                        code: code,
                        createdAt: Date(timeIntervalSince1970: createdAtTimestamp),
                        createdBy: createdBy
                    )
                    rooms.append(room)
                }
            }
            
            // Ordina per data di creazione (più recenti prima)
            rooms.sort { $0.createdAt > $1.createdAt }
            completion(rooms)
        }
    }
    
    func deleteRoom(_ room: Room, completion: @escaping (Error?) -> Void) {
        let group = DispatchGroup()
        var deleteError: Error?
        
        // Elimina la room
        group.enter()
        database.child("rooms").child(room.id).removeValue { error, _ in
            if let error = error {
                deleteError = error
            }
            group.leave()
        }
        
        // Elimina il codice di mapping
        group.enter()
        database.child("roomCodes").child(room.code).removeValue { error, _ in
            if let error = error {
                deleteError = error
            }
            group.leave()
        }
        
        group.notify(queue: .main) {
            completion(deleteError)
        }
    }
    
    // MARK: - Cleanup
    
    func removeAllObservers() {
        // Rimuovi gli observer solo se c'è una room attiva
        if checkRoomAvailability() {
            playersRef.removeAllObservers()
            matchesRef.removeAllObservers()
        }
    }
    
    // MARK: - Utility
    
    private func generateRoomCode() -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<6).map { _ in letters.randomElement()! })
    }
}
