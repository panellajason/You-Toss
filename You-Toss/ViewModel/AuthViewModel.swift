//
//  AuthViewModel.swift
//  You-Toss
//
//  Created by Panella, Jason on 12/31/25.
//
import FirebaseAuth
import FirebaseFirestore

@MainActor
class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var errorMessage: String?

    func signIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                return
            }

            self?.user = result?.user
        }
    }

    func signUp(email: String, password: String, username: String) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                return
            }

            guard let firebaseUser = result?.user else { return }

            self?.createUserDocument(
                uid: firebaseUser.uid,
                email: email,
                username: username,
                homeGroup: ""
            )
            
            self?.user = result?.user
        }
    }

    func signOut() throws {
        try Auth.auth().signOut()
        self.user = nil
    }
    
    func createUserDocument(
        uid: String,
        email: String,
        username: String,
        homeGroup: String
    ) {
        let db = Firestore.firestore()

        let data: [String: Any] = [
            "user_id": uid,
            "email": email,
            "username": username,
            "home_group": homeGroup
        ]

        db.collection("users").document(uid).setData(data) { error in
            if let error = error {
                print("Firestore error:", error.localizedDescription)
            }
        }
    }
    
    func getCurrentUserHomeGroup(
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "Auth", code: 401)))
            return
        }

        Firestore.firestore()
            .collection("users")
            .document(uid)
            .getDocument { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let homeGroup = snapshot?.data()?["home_group"] as? String else {
                    completion(.failure(NSError(domain: "Firestore", code: 404)))
                    return
                }

                completion(.success(homeGroup))
            }
    }
    
    func getCurrentUserUsername(
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "No current user logged in"])))
            return
        }

        Firestore.firestore()
            .collection("users")
            .document(uid)
            .getDocument { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let username = snapshot?.data()?["username"] as? String else {
                    completion(.failure(NSError(domain: "Firestore", code: 404, userInfo: [NSLocalizedDescriptionKey: "Username not found"])))
                    return
                }

                completion(.success(username))
            }
    }
    
    func updateCurrentUserHomeGroup(
        to newHomeGroup: String,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        // Get current user UID
        guard let uid = Auth.auth().currentUser?.uid else {
            completion(.failure(NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "No current user"])))
            return
        }

        // Reference to user's document
        let userDocRef = Firestore.firestore().collection("users").document(uid)

        // Update the home_group field
        userDocRef.updateData(["home_group": newHomeGroup]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

}
