//
//  SessionListener.swift
//  You-Toss
//
//  Created by Panella, Jason on 12/31/25.
//
import FirebaseFirestore

class SessionListener {
    static let shared = SessionListener()
        
        private var sessionListener: ListenerRegistration?
        private(set) var currentSession: [String: Any]?
        
        private init() {}
        
        // MARK: - Real-time listener
        func listenToSession(sessionID: String, onUpdate: @escaping ([String: Any]?) -> Void) {
            sessionListener?.remove()
            
            let db = Firestore.firestore()
            sessionListener = db.collection("sessions").document(sessionID)
                .addSnapshotListener { [weak self] snapshot, error in
                    if let error = error {
                        print("Error listening to session:", error.localizedDescription)
                        onUpdate(nil)
                        return
                    }
                    
                    guard let data = snapshot?.data() else {
                        self?.currentSession = nil
                        onUpdate(nil)
                        return
                    }
                    
                    self?.currentSession = data
                    onUpdate(data)
                }
        }
        
        func removeListener() {
            sessionListener?.remove()
            sessionListener = nil
            currentSession = nil
        }
        
        // MARK: - Convenience getters
        var players: [[String: Any]] {
            return currentSession?["players"] as? [[String: Any]] ?? []
        }
        
        var isActive: Bool {
            return currentSession?["isActive"] as? Bool ?? false
        }
        
        var groupName: String? {
            return currentSession?["group_name"] as? String
        }
        
        var createdAt: String? {
            return currentSession?["createdAt"] as? String
        }
        
        /// Get a specific player by username
        func player(username: String) -> [String: Any]? {
            return players.first { ($0["username"] as? String) == username }
        }
        
        /// Get a player's buy-in
        func currentBuyIn(username: String) -> Int {
            return player(username: username)?["currentBuyIn"] as? Int ?? 0
        }
        
        /// Get a player's cashOut
        func cashOut(username: String) -> Int {
            return player(username: username)?["cashOut"] as? Int ?? 0
        }
}

