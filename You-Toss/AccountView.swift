//
//  AccountView.swift
//  You-Toss
//
//  Created by Tony Hunt on 12/31/25.
//

import SwiftUI

struct AccountView: View {

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
                AccountButton(
                    title: "Create Group",
                    systemImage: "plus.circle"
                )

                AccountButton(
                    title: "Join Group",
                    systemImage: "person.2.badge.plus"
                )

                AccountButton(
                    title: "My Groups",
                    systemImage: "person.3"
                )

                AccountButton(
                    title: "My Sessions",
                    systemImage: "calendar"
                )
            }

            // Sign out section
            VStack {
                Divider()
                    .padding(.vertical)

                Button(action: {
                    // Sign out later
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
        Button(action: {
            // Action later
        }) {
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
        }
        .foregroundColor(.primary)
    }
}

// MARK: - Preview

#Preview {
    AccountView()
}
