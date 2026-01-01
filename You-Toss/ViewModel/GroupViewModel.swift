//
//  GroupViewModel.swift
//  You-Toss
//
//  Created by Panella, Jason on 12/31/25.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore
//import SwiftUICore

@MainActor
class GroupViewModel: ObservableObject {
    @StateObject private var authVM = AuthViewModel()

    func createGroup(
        groupName: String,
        groupPasscode: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "No current user logged in"])))
            return
        }
        
        let db = Firestore.firestore()
        let groupDocRef = db.collection("groups").document() // auto-generated ID
        
        let groupData: [String: Any] = [
            "group_name": groupName,
            "group_passcode": groupPasscode,
            "host": uid,
            "created_at": Timestamp(date: Date())
        ]
        
        groupDocRef.setData(groupData) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Update user's home_group
            db.collection("users").document(uid).updateData(["home_group": groupName]) { error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                // Create user_groups entry
                self.createUserGroup(groupID: groupDocRef.documentID, groupName: groupName) { result in
                    switch result {
                    case .success:
                        completion(.success(groupDocRef.documentID))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
        }
    }

    
    func joinGroup(
        groupName: String,
        groupPasscode: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "No current user logged in"])))
            return
        }
        
        let db = Firestore.firestore()
        let groupsRef = db.collection("groups")
        
        groupsRef.whereField("group_name", isEqualTo: groupName).getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let document = snapshot?.documents.first else {
                completion(.failure(NSError(domain: "Firestore", code: 404, userInfo: [NSLocalizedDescriptionKey: "Group not found"])))
                return
            }
            
            let data = document.data()
            let actualPasscode = data["group_passcode"] as? String ?? ""
            
            if actualPasscode != groupPasscode {
                completion(.failure(NSError(domain: "Auth", code: 403, userInfo: [NSLocalizedDescriptionKey: "Incorrect passcode"])))
                return
            }
            
            // Update user's home_group
            db.collection("users").document(uid).updateData(["home_group": groupName]) { error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                // Create user_groups entry
                self.createUserGroup(groupID: document.documentID, groupName: groupName) { result in
                    switch result {
                    case .success:
                        completion(.success(document.documentID))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
        }
    }


    func createUserGroup(
        groupID: String,
        groupName: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        guard let currentUser = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "No current user logged in"])))
            return
        }

        // Fetch the username first
        authVM.getCurrentUserUsername { result in
            switch result {
            case .success(let username):
                let db = Firestore.firestore()
                
                let userGroupData: [String: Any] = [
                    "group_name": groupName,
                    "score": 0,
                    "user_id": currentUser.uid,
                    "username": username
                ]
                
                // Use a fixed document ID to avoid duplicates
                let docID = "\(currentUser.uid)_\(groupID)"
                
                db.collection("user_groups").document(docID).setData(userGroupData) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        completion(.success(()))
                    }
                }
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }


    func updateUserGroupScore(
        groupName: String,
        username: String,
        newScore: Int,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        let db = Firestore.firestore()
        
        // Query the user_groups document for this username and group
        db.collection("user_groups")
            .whereField("username", isEqualTo: username)
            .whereField("group_name", isEqualTo: groupName)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let document = snapshot?.documents.first else {
                    completion(.failure(NSError(
                        domain: "Firestore",
                        code: 404,
                        userInfo: [NSLocalizedDescriptionKey: "User group not found"]
                    )))
                    return
                }
                
                // Get current score and append newScore
                let currentScore = document.data()["score"] as? Int ?? 0
                let updatedScore = currentScore + newScore
                
                // Update the score
                db.collection("user_groups").document(document.documentID)
                    .updateData(["score": updatedScore]) { error in
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            completion(.success(()))
                        }
                    }
            }
    }


    func getAllGroupsForUser(
        completion: @escaping (Result<[(groupID: String, groupName: String, score: Int)], Error>) -> Void
    ) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "No current user logged in"])))
            return
        }
        
        let db = Firestore.firestore()
        
        db.collection("user_groups")
            .whereField("user_id", isEqualTo: uid)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion(.success([])) // no groups found
                    return
                }
                
                let groups: [(groupID: String, groupName: String, score: Int)] = documents.compactMap { doc in
                    let data = doc.data()
                    guard let groupName = data["group_name"] as? String,
                          let score = data["score"] as? Int else { return nil }
                    return (groupID: doc.documentID, groupName: groupName, score: score)
                }
                
                completion(.success(groups))
            }
    }

    func getAllUsersInGroup(
        groupName: String,
        completion: @escaping (Result<[(userID: String, username: String, score: Int)], Error>) -> Void
    ) {
        let db = Firestore.firestore()
        
        db.collection("user_groups")
            .whereField("group_name", isEqualTo: groupName)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    completion(.success([])) // no users in this group
                    return
                }
                
                let users: [(userID: String, username: String, score: Int)] = documents.compactMap { doc in
                    let data = doc.data()
                    guard let userID = data["user_id"] as? String,
                          let username = data["username"] as? String,
                          let score = data["score"] as? Int else {
                        return nil
                    }
                    return (userID: userID, username: username, score: score)
                }
                
                completion(.success(users))
            }
    }

    
}
