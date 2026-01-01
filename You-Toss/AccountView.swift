//
//  AccountView.swift
//  You-Toss
//
//  Created by Tony Hunt on 12/31/25.
//

import FirebaseAuth
import SwiftUI

struct AccountView: View {

    @StateObject private var authVM = AuthViewModel()

    @State private var email: String = "Loading..."
    @State private var username: String = "Loading..."

    var body: some View {
        VStack(spacing: 32) {

            // Email & username header
            VStack(spacing: 8) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.blue)

                Text(email)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(username)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            // Main actions
            VStack(spacing: 16) {
                NavigationLink {
                    GroupFormView(mode: .create)
                } label: {
                    AccountButton(
                        title: "Create Group",
                        systemImage: "plus.circle"
                    )
                }

                NavigationLink {
                    GroupFormView(mode: .join)
                } label: {
                    AccountButton(
                        title: "Join Group",
                        systemImage: "person.2.badge.plus"
                    )
                }

                NavigationLink {
                    SummaryListView(mode: .groups)
                } label: {
                    AccountButton(title: "My Groups", systemImage: "person.3")
                }

                NavigationLink {
                    SummaryListView(mode: .sessions)
                } label: {
                    AccountButton(title: "My Sessions", systemImage: "calendar")
                }
            }

            // Sign out section
            VStack {
                Divider()
                    .padding(.vertical)

                Button(action: {
                    do {
                        try authVM.signOut()
                    } catch {
                        print(error.localizedDescription)
                    }
                }) {
                    Text("Sign Out")
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }
            }

            Spacer()
        }
        .padding()
        .onAppear {
            // Load email
            if let currentEmail = Auth.auth().currentUser?.email {
                self.email = currentEmail
            } else {
                self.email = "Unknown Email"
            }

            // Load username
            authVM.getCurrentUserUsername { result in
                switch result {
                case .success(let name):
                    self.username = name
                case .failure(_):
                    self.username = "Unknown Username"
                }
            }
        }
    }
}



// MARK: - Reusable Button

struct AccountButton: View {
    let title: String
    let systemImage: String

    var body: some View {
        HStack {
            Image(systemName: systemImage)
            Text(title)
                .fontWeight(.medium)
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .foregroundColor(.primary)
    }
}


// MARK: - Preview

#Preview {
    NavigationStack {
        AccountView()
    }
}
