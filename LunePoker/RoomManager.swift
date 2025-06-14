//
//  RoomManager.swift
//  LunePoker
//
//  Created by Michele Mariniello on 14/06/25.
//

import SwiftUI
import Foundation
import FirebaseDatabase

// Struttura per rappresentare una room
struct Room: Identifiable, Codable {
    let id: String
    let name: String
    let code: String
    let createdAt: Date
    let createdBy: String
}

// Manager per gestire le operazioni delle room
class RoomManager: ObservableObject {
    static let shared = RoomManager()
    
    @Published var currentRoom: Room?
    @Published var isInRoom = false
    
    private let database = Database.database().reference()
    private var roomsRef: DatabaseReference { database.child("rooms") }
    private var roomCodesRef: DatabaseReference { database.child("roomCodes") }
    
    private init() {}
    
    // MARK: - Room Creation
    
    func createRoom(name: String, completion: @escaping (Room?, Error?) -> Void) {
        let roomId = UUID().uuidString
        let roomCode = generateRoomCode()
        
        let room = Room(
            id: roomId,
            name: name,
            code: roomCode,
            createdAt: Date(),
            createdBy: "Anonymous" // Per ora, poi potrai usare l'ID utente
        )
        
        let roomData: [String: Any] = [
            "id": room.id,
            "name": room.name,
            "code": room.code,
            "createdAt": room.createdAt.timeIntervalSince1970,
            "createdBy": room.createdBy
        ]
        
        // Salva la room
        roomsRef.child(roomId).child("info").setValue(roomData) { [weak self] error, _ in
            if let error = error {
                completion(nil, error)
                return
            }
            
            // Salva il mapping codice -> roomId
            self?.roomCodesRef.child(roomCode).setValue(roomId) { error, _ in
                if let error = error {
                    completion(nil, error)
                    return
                }
                
                // Imposta la room corrente
                DispatchQueue.main.async {
                    self?.currentRoom = room
                    self?.isInRoom = true
                    self?.saveCurrentRoomLocally()
                }
                
                completion(room, nil)
            }
        }
    }
    
    // MARK: - Room Joining
    
    func joinRoom(code: String, completion: @escaping (Room?, Error?) -> Void) {
        let trimmedCode = code.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        // Prima trova il roomId dal codice
        roomCodesRef.child(trimmedCode).observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let roomId = snapshot.value as? String else {
                completion(nil, NSError(domain: "RoomError", code: 404, userInfo: [NSLocalizedDescriptionKey: "Room not found"]))
                return
            }
            
            // Poi carica le informazioni della room
            self?.roomsRef.child(roomId).child("info").observeSingleEvent(of: .value) { snapshot in
                guard let value = snapshot.value as? [String: Any],
                      let id = value["id"] as? String,
                      let name = value["name"] as? String,
                      let code = value["code"] as? String,
                      let createdAtTimestamp = value["createdAt"] as? TimeInterval,
                      let createdBy = value["createdBy"] as? String else {
                    completion(nil, NSError(domain: "RoomError", code: 500, userInfo: [NSLocalizedDescriptionKey: "Invalid room data"]))
                    return
                }
                
                let room = Room(
                    id: id,
                    name: name,
                    code: code,
                    createdAt: Date(timeIntervalSince1970: createdAtTimestamp),
                    createdBy: createdBy
                )
                
                DispatchQueue.main.async {
                    self?.currentRoom = room
                    self?.isInRoom = true
                    self?.saveCurrentRoomLocally()
                }
                
                completion(room, nil)
            }
        }
    }
    
    // MARK: - Room Management
    
    func leaveRoom() {
        currentRoom = nil
        isInRoom = false
        clearCurrentRoomLocally()
    }
    
    func getRoomId() -> String? {
        return currentRoom?.id
    }
    
    // MARK: - Local Storage
    
    private func saveCurrentRoomLocally() {
        guard let room = currentRoom else { return }
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(room)
            UserDefaults.standard.set(data, forKey: "currentRoom")
            UserDefaults.standard.set(true, forKey: "isInRoom")
        } catch {
            print("Failed to save current room locally: \(error)")
        }
    }
    
    func loadCurrentRoomLocally() {
        guard let data = UserDefaults.standard.data(forKey: "currentRoom"),
              UserDefaults.standard.bool(forKey: "isInRoom") else {
            return
        }
        
        do {
            let decoder = JSONDecoder()
            let room = try decoder.decode(Room.self, from: data)
            currentRoom = room
            isInRoom = true
        } catch {
            print("Failed to load current room locally: \(error)")
            clearCurrentRoomLocally()
        }
    }
    
    private func clearCurrentRoomLocally() {
        UserDefaults.standard.removeObject(forKey: "currentRoom")
        UserDefaults.standard.set(false, forKey: "isInRoom")
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
    
    // MARK: - Utility
    
    private func generateRoomCode() -> String {
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<6).map { _ in letters.randomElement()! })
    }
}
