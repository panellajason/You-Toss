//
//  UserListener.swift
//  You-Toss
//
//  Created by Panella, Jason on 12/31/25.
//
import FirebaseAuth

@MainActor
class UserListener: ObservableObject {
    @Published var user: User?

    init() {
        Auth.auth().addStateDidChangeListener { _, user in
            self.user = user
        }
    }
}

