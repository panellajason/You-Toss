//
//  AccountView.swift
//  You-Toss
//
//  Created by Tony Hunt on 12/31/25.
//

import SwiftUI

struct AccountView: View {

    @StateObject private var authVM = AuthViewModel()

    // Placeholder for now
    let email: String = "user@email.com"

    var body: some View {
        VStack(spacing: 32) {

            // Email header
            VStack(spacing: 8) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.blue)

                Text(email)
                    .font(.headline)
                    .foregroundColor(.primary)
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
