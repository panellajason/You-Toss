//
//  GroupFormView.swift
//  You-Toss
//
//  Created by Tony Hunt on 12/31/25.
//

import SwiftUI
import FirebaseAuth

struct GroupFormView: View {
    
    @StateObject private var groupVM = GroupViewModel()

    enum Mode {
        case create
        case join
    }

    let mode: Mode

    @State private var groupName = ""
    @State private var passcode = ""
    @State private var isLoading = false
    @State private var alertMessage: String?
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 24) {

            // Title
            Text(mode == .create ? "Create Group" : "Join Group")
                .font(.largeTitle)
                .fontWeight(.bold)

            // Group name
            TextField("Group name", text: $groupName)
                .textInputAutocapitalization(.words)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)

            // Password / Passcode
            SecureField(
                mode == .create ? "Password" : "Group passcode",
                text: $passcode
            )
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)

            // Primary button
            Button(action: {
                handleButtonTap()
            }) {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                } else {
                    Text(mode == .create ? "Create" : "Join")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }

            Spacer()
        }
        .padding()
    }

    // MARK: - Button Logic

    private func handleButtonTap() {
        guard !groupName.isEmpty else {
            alertMessage = "Please enter a group name."
            return
        }
        guard !passcode.isEmpty else {
            alertMessage = mode == .create ? "Please enter a password." : "Please enter the group passcode."
            return
        }

        isLoading = true

        if mode == .create {
            groupVM.createGroup(groupName: groupName, groupPasscode: passcode) { result in
                isLoading = false
                switch result {
                case .success(let groupID):
                    // Optional: createUserGroup entry for this user
                    groupVM.createUserGroup(groupID: groupID, groupName: groupName) { _ in }
                    alertMessage = "Group created successfully!"
                    dismiss()
                case .failure(let error):
                    alertMessage = "Failed to create group: \(error.localizedDescription)"
                }
            }
        } else {
            groupVM.joinGroup(groupName: groupName, groupPasscode: passcode) { result in
                isLoading = false
                switch result {
                case .success:
                    alertMessage = "Joined group successfully!"
                    dismiss()
                case .failure(let error):
                    alertMessage = "Failed to join group: \(error.localizedDescription)"
                }
            }
        }
    }
}

