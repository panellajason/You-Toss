//
//  SessionViewModel.swift
//  You-Toss
//
//  Created by Panella, Jason on 12/31/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

@MainActor
class SessionViewModel: ObservableObject {
    private var authVM = AuthViewModel()

    func createSession(
        groupName: String,
        players: [[String: Any]] = [],
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        let db = Firestore.firestore()
        let sessionDocRef = db.collection("sessions").document() // auto-generated ID
        
        // Format the current date as a string
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E MMM dd yyyy"
        let createdAt = dateFormatter.string(from: Date())
        
        let sessionData: [String: Any] = [
            "createdAt": createdAt,
            "group_name": groupName,
            "isActive": true,
            "players": players // default empty array, can contain player maps
        ]
        
        sessionDocRef.setData(sessionData) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(sessionDocRef.documentID))
            }
        }
    }
    
    func endSession(
        groupName: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let db = Firestore.firestore()
        
        // Query the active session for the group
        db.collection("sessions")
            .whereField("group_name", isEqualTo: groupName)
            .whereField("isActive", isEqualTo: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let document = snapshot?.documents.first else {
                    completion(.failure(NSError(domain: "Firestore", code: 404, userInfo: [NSLocalizedDescriptionKey: "No active session found for this group"])))
                    return
                }
                
                // Update isActive to false
                db.collection("sessions").document(document.documentID)
                    .updateData(["isActive": false]) { error in
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            completion(.success(()))
                        }
                    }
            }
    }
    
    func getActiveSessionForCurrentUser(completion: @escaping (Result<[String: Any], Error>) -> Void) {
        let db = Firestore.firestore()
        
        // First, get the current user's home group
        authVM.getCurrentUserHomeGroup { result in
            switch result {
            case .success(let groupName):
                // Query active session for this group
                db.collection("sessions")
                    .whereField("group_name", isEqualTo: groupName)
                    .whereField("isActive", isEqualTo: true)
                    .getDocuments { snapshot, error in
                        if let error = error {
                            completion(.failure(error))
                            return
                        }
                        
                        guard let document = snapshot?.documents.first else {
                            completion(.failure(NSError(domain: "Firestore", code: 404, userInfo: [NSLocalizedDescriptionKey: "No active session found for this group"])))
                            return
                        }
                        
                        completion(.success(document.data()))
                    }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }


    func updateUserBuyIn(
        groupName: String,
        username: String,
        newBuyIn: Double,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let db = Firestore.firestore()
        
        // Step 1: Get the active session
        db.collection("sessions")
            .whereField("group_name", isEqualTo: groupName)
            .whereField("isActive", isEqualTo: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let sessionDoc = snapshot?.documents.first else {
                    completion(.failure(NSError(domain: "Firestore", code: 404, userInfo: [NSLocalizedDescriptionKey: "No active session found for this group"])))
                    return
                }
                
                let sessionData = sessionDoc.data()
                
                // Step 2: Update the player's buy-in
                var players = sessionData["players"] as? [[String: Any]] ?? []
                if let index = players.firstIndex(where: { ($0["username"] as? String) == username }) {
                    players[index]["buyIn"] = newBuyIn
                } else {
                    // If player does not exist yet, optionally add them
                    players.append([
                        "username": username,
                        "cashOut": 0,
                        "buyIn": newBuyIn
                    ])
                }
                
                // Step 3: Save updated players array back to Firestore
                db.collection("sessions").document(sessionDoc.documentID)
                    .updateData(["players": players]) { error in
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            completion(.success(()))
                        }
                    }
            }
    }

    func updateUserCashOut(
        groupName: String,
        username: String,
        newCashOut: Double,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let db = Firestore.firestore()
        
        // Step 1: Get the active session
        db.collection("sessions")
            .whereField("group_name", isEqualTo: groupName)
            .whereField("isActive", isEqualTo: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let sessionDoc = snapshot?.documents.first else {
                    completion(.failure(NSError(domain: "Firestore", code: 404, userInfo: [NSLocalizedDescriptionKey: "No active session found for this group"])))
                    return
                }
                
                var sessionData = sessionDoc.data()
                
                // Step 2: Update the player's cashOut
                var players = sessionData["players"] as? [[String: Any]] ?? []
                if let index = players.firstIndex(where: { ($0["username"] as? String) == username }) {
                    players[index]["cashOut"] = newCashOut
                } else {
                    // If player does not exist yet, optionally add them
                    players.append([
                        "username": username,
                        "cashOut": newCashOut,
                        "buyIn": 0
                    ])
                }
                
                // Step 3: Save updated players array back to Firestore
                db.collection("sessions").document(sessionDoc.documentID)
                    .updateData(["players": players]) { error in
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            completion(.success(()))
                        }
                    }
            }
    }

    func getAllSessionsForGroup(
        groupName: String,
        completion: @escaping (Result<[[String: Any]], Error>) -> Void
    ) {
        let db = Firestore.firestore()
        
        db.collection("sessions")
            .whereField("group_name", isEqualTo: groupName)
            .order(by: "createdAt", descending: true) // optional: latest sessions first
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion(.success([])) // no sessions found
                    return
                }
                
                let sessions = documents.map { doc -> [String: Any] in
                    var data = doc.data()
                    data["sessionID"] = doc.documentID // include ID for reference
                    return data
                }
                
                completion(.success(sessions))
            }
    }

    func getAllPlayersInSession(
        sessionID: String,
        completion: @escaping (Result<[[String: Any]], Error>) -> Void
    ) {
        let db = Firestore.firestore()
        
        db.collection("sessions").document(sessionID).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = snapshot?.data(),
                  let players = data["players"] as? [[String: Any]] else {
                completion(.success([])) // no players in session
                return
            }
            
            completion(.success(players))
        }
    }

    func getAllSessionsForCurrentUser(completion: @escaping (Result<[[String: Any]], Error>) -> Void) {
        // First, get the current user's username
        authVM.getCurrentUserUsername { result in
            switch result {
            case .success(let username):
                let db = Firestore.firestore()
                
                // Query sessions where players array contains this username
                db.collection("sessions")
                    .whereField("players", arrayContains: ["username": username])
                    .getDocuments { snapshot, error in
                        if let error = error {
                            completion(.failure(error))
                            return
                        }
                        
                        guard let documents = snapshot?.documents else {
                            completion(.success([]))
                            return
                        }
                        
                        let sessionsData = documents.map { $0.data() }
                        completion(.success(sessionsData))
                    }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }


}
