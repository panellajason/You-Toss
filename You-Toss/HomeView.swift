//
//  HomeView.swift
//  You-Toss
//
//  Created by Tony Hunt on 12/31/25.
//

import SwiftUI
import FirebaseAuth

struct HomeView: View {

    @Binding var selectedTab: Int

    @StateObject private var authVM = AuthViewModel()
    @StateObject private var groupVM = GroupViewModel()

    @State private var selectedGroupName: String = ""
    @State private var members: [Member] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    // Dynamically loaded groups for dropdown
    @State private var allUserGroups: [(groupID: String, groupName: String, score: Double)] = []

    struct Member: Identifiable, Hashable {
        let id = UUID()
        let name: String
        let score: Double
    }

    var body: some View {
        VStack(spacing: 16) {
            if isLoading {
                VStack(spacing: 16) {
                    Spacer()

                    ProgressView("Loading...")
                        .padding()

                    Spacer()
                }
            } else {
                // Header with group name and dropdown
                HStack {
                    if !selectedGroupName.isEmpty {
                        Text(selectedGroupName)
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        // Menu to switch groups
                        Menu {
                            ForEach(allUserGroups, id: \.groupID) { group in
                                Button(action: {
                                    switchToGroup(group.groupName)
                                }) {
                                    Text(group.groupName)
                                }
                            }
                        } label: {
                            Image(systemName: "chevron.down.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                        }

                    } else {
                        VStack(spacing: 16) {
                            Spacer()

                            Text("You're not a part of any groups.")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.gray)

                            Button(action: {
                                // Switch to Account tab
                                selectedTab = 2
                            }) {
                                Text("Create or Join Group")
                                    .fontWeight(.semibold)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                            .padding(.horizontal)

                            Spacer()
                        }
                    }

                    Spacer()
                }
                
                // Error / Members
                if let error = errorMessage {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                } else {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(members.sorted { $0.score > $1.score }) { member in
                                AmountRow(name: member.name, amount: Double(member.score))
                            }
                        }
                    }
                }
            }

            Spacer()
        }
        .padding()
        .onAppear {
            loadUserGroupsAndHomeGroup()
        }
    }

    // MARK: - Load user groups and home group
    private func loadUserGroupsAndHomeGroup() {
        isLoading = true
        errorMessage = nil

        // 1️⃣ Get the current home group
        authVM.getCurrentUserHomeGroup { result in
            switch result {
            case .success(let homeGroup):
                selectedGroupName = homeGroup

                // 2️⃣ Fetch all groups the user belongs to
                groupVM.getAllGroupsForUser { groupsResult in
                    switch groupsResult {
                    case .success(let groups):
                        allUserGroups = groups
                        // 3️⃣ Load members for the current home group
                        loadMembersForGroup(homeGroup)

                    case .failure(let error):
                        isLoading = false
                        errorMessage = error.localizedDescription
                        allUserGroups = []
                        members = []
                    }
                }

            case .failure(let error):
                isLoading = false
                errorMessage = error.localizedDescription
                selectedGroupName = ""
                allUserGroups = []
                members = []
            }
        }
    }

    // MARK: - Load members for a specific group
    private func loadMembersForGroup(_ groupName: String) {
        groupVM.getAllUsersInGroup(groupName: groupName) { usersResult in
            isLoading = false
            switch usersResult {
            case .success(let users):
                members = users.map { Member(name: $0.username, score: $0.score) }
            case .failure(let error):
                members = []
                errorMessage = error.localizedDescription
            }
        }
    }

    // MARK: - Switch to a new group
    private func switchToGroup(_ newGroup: String) {
        isLoading = true
        errorMessage = nil

        authVM.updateCurrentUserHomeGroup(to: newGroup) { result in
            switch result {
            case .success():
                selectedGroupName = newGroup
                loadMembersForGroup(newGroup)

            case .failure(let error):
                isLoading = false
                errorMessage = "Failed to switch group: \(error.localizedDescription)"
            }
        }
    }
}
