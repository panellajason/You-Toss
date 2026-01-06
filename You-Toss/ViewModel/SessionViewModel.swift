//
//  SessionViewModel.swift
//  You-Toss
//
//  Created by Panella, Jason on 12/31/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct PlayerSession: Identifiable {
    let id = UUID()
    let sessionId: String
    let date: String
    let username: String
    let buyIn: Double
    let cashOut: Double
}

struct PlayerSessionDetail: Identifiable {
    let id = UUID()
    let name: String
    let buyIn: Double
    let cashOut: Double
    var net: Double { cashOut - buyIn }
}

@MainActor
class SessionViewModel: ObservableObject {
    private var authVM = AuthViewModel()
    private var groupVM = GroupViewModel()

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
            "badBeats": [],
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
    
    func endSessionWithPlayerData(
        groupName: String,
        players: [[String: Any]] = [],
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
                    completion(.failure(NSError(
                        domain: "Firestore",
                        code: 404,
                        userInfo: [NSLocalizedDescriptionKey: "No active session found for this group"]
                    )))
                    return
                }
                
                // Update isActive to false and optionally update players
                var updateData: [String: Any] = ["isActive": false]
                if !players.isEmpty {
                    updateData["players"] = players
                }
                
                db.collection("sessions").document(document.documentID)
                    .updateData(updateData) { error in
                        if let error = error {
                            completion(.failure(error))
                            return
                        }
                        
                        // Update each player's score in user_groups
                        let group = DispatchGroup()
                        
                        for player in players {
                            guard
                                let username = player["username"] as? String,
                                let buyIn = player["buyIn"] as? Double,
                                let cashOut = player["cashOut"] as? Double
                            else { continue }
                            
                            let newScore = Double(cashOut - buyIn)
                            
                            group.enter()
                            self.groupVM.updateUserGroupScore(groupName: groupName, username: username, newScore: newScore) { _ in
                                group.leave()
                            }
                        }
                        
                        group.notify(queue: .main) {
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
    
    func addBadBeat(
        groupName: String,
        badBeat: BadBeat,
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
                    completion(.failure(
                        NSError(
                            domain: "Firestore",
                            code: 404,
                            userInfo: [NSLocalizedDescriptionKey: "No active session found for this group"]
                        )
                    ))
                    return
                }

                let sessionData = sessionDoc.data()

                // Step 2: Get existing badBeats array (or create it)
                var badBeats = sessionData["badBeats"] as? [[String: Any]] ?? []

                let badBeatDict: [String: Any] = [
                    "loser": badBeat.loser,
                    "loserHand": badBeat.loserHand,
                    "street": badBeat.street,
                    "winner": badBeat.winner,
                    "winnerHand": badBeat.winnerHand
                ]

                badBeats.append(badBeatDict)

                // Step 3: Save updated badBeats array back to Firestore
                db.collection("sessions")
                    .document(sessionDoc.documentID)
                    .updateData(["badBeats": badBeats]) { error in
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            completion(.success(()))
                        }
                    }
            }
    }

    func addNewPlayers(
        groupName: String,
        newPlayers: [String],
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
                    completion(.failure(
                        NSError(
                            domain: "Firestore",
                            code: 404,
                            userInfo: [NSLocalizedDescriptionKey: "No active session found for this group"]
                        )
                    ))
                    return
                }

                let sessionData = sessionDoc.data()

                // Step 2: Get existing players
                var players = sessionData["players"] as? [[String: Any]] ?? []

                let existingUsernames = Set(
                    players.compactMap { $0["username"] as? String }
                )

                // Step 3: Build new players (no duplicates)
                let playersToAdd: [[String: Any]] = newPlayers
                    .filter { !existingUsernames.contains($0) }
                    .map {
                        [
                            "username": $0,
                            "buyIn": 0,
                            "cashOut": 0
                        ]
                    }

                // Nothing new to add
                guard !playersToAdd.isEmpty else {
                    completion(.success(()))
                    return
                }

                // Step 4: Append + save
                players.append(contentsOf: playersToAdd)

                db.collection("sessions")
                    .document(sessionDoc.documentID)
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

    func getPlayerSessions(completion: @escaping (Result<[PlayerSession], Error>) -> Void) {
        let db = Firestore.firestore()

        // Step 1: Get current user's username
        authVM.getCurrentUserUsername { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))

            case .success(let username):
                // Step 2: Fetch all sessions
                db.collection("sessions")
                    .getDocuments { snapshot, error in
                        if let error = error {
                            completion(.failure(error))
                            return
                        }

                        guard let documents = snapshot?.documents else {
                            completion(.success([]))
                            return
                        }

                        var playerSessions: [PlayerSession] = []

                        // Step 3: Filter sessions for this user
                        for document in documents {
                            let data = document.data()
                            let sessionId = document.documentID   // ✅ capture ID

                            let date = data["createdAt"] as? String ?? "Unknown"
                            let players = data["players"] as? [[String: Any]] ?? []

                            for player in players {
                                guard
                                    let playerUsername = player["username"] as? String,
                                    playerUsername == username,
                                    let buyIn = player["buyIn"] as? Double,
                                    let cashOut = player["cashOut"] as? Double
                                else {
                                    continue
                                }

                                let session = PlayerSession(
                                    sessionId: sessionId,
                                    date: date,
                                    username: playerUsername,
                                    buyIn: buyIn,
                                    cashOut: cashOut
                                )

                                playerSessions.append(session)
                            }
                        }

                        completion(.success(playerSessions))
                    }
            }
        }
    }

    func fetchSession(
            sessionId: String,
            completion: @escaping (Result<[PlayerSessionDetail], Error>) -> Void
        ) {
            let db = Firestore.firestore()
            db.collection("sessions")
                .document(sessionId)
                .getDocument { snapshot, error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }

                    guard
                        let data = snapshot?.data(),
                        let playersData = data["players"] as? [[String: Any]]
                    else {
                        completion(.success([]))
                        return
                    }

                    let players: [PlayerSessionDetail] = playersData.compactMap { playerDict in
                        guard
                            let username = playerDict["username"] as? String,
                            let buyIn = playerDict["buyIn"] as? Double,
                            let cashOut = playerDict["cashOut"] as? Double
                        else {
                            return nil
                        }

                        return PlayerSessionDetail(
                            name: username,
                            buyIn: buyIn,
                            cashOut: cashOut
                        )
                    }

                    completion(.success(players))
                }
        }
}
