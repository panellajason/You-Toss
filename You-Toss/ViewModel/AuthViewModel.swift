//
//  AuthViewModel.swift
//  You-Toss
//
//  Created by Panella, Jason on 12/31/25.
//
import FirebaseAuth

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

    func signUp(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                self?.errorMessage = error.localizedDescription
                return
            }

            self?.user = result?.user
        }
    }

    func signOut() throws {
        try Auth.auth().signOut()
        self.user = nil
    }
}
