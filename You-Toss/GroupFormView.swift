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
    @State private var alertMessage = ""
    @State private var showAlert = false
    
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
        .alert("Something went wrong", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }

    // MARK: - Button Logic

    private func handleButtonTap() {
        guard !groupName.isEmpty else {
            alertMessage = "Please enter a group name."
            showAlert = true
            return
        }
        guard !passcode.isEmpty else {
            alertMessage = mode == .create ? "Please enter a passcode." : "Please enter the group passcode."
            showAlert = true
            return
        }

        isLoading = true

        if mode == .create {
            guard passcode.count > 6 else {
                alertMessage = "Group passcode must be at least 6 characters long."
                showAlert = true
                isLoading = false
                return
            }
            groupVM.checkIfGroupNameExists(groupName: groupName) { exists in
                if exists {
                    alertMessage = "Group name already exists"
                    showAlert = true
                    isLoading = false
                } else {
                    groupVM.createGroup(groupName: groupName, groupPasscode: passcode) { result in
                        isLoading = false
                        switch result {
                        case .success(let groupID):
                            dismiss()
                        case .failure(let error):
                            alertMessage = "Failed to create group: \(error.localizedDescription)"
                            showAlert = true
                        }
                    }
                }
            }
        } else {
            groupVM.checkIfUserIsInGroup(groupName: groupName) { isInGroup in
                if isInGroup {
                    alertMessage = "You are already in this group."
                    showAlert = true
                } else {
                    groupVM.joinGroup(groupName: groupName, groupPasscode: passcode) { result in
                        isLoading = false
                        switch result {
                        case .success:
                            dismiss()
                        case .failure(let error):
                            alertMessage = "Failed to join group: \(error.localizedDescription)"
                            showAlert = true
                        }
                    }
                }
            }
        }
    }
}

