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

    struct Member: Identifiable, Hashable {
        let id = UUID()
        let name: String
        let score: Int
    }

    // MARK: - View

    var body: some View {
        VStack(spacing: 24) {

            // Header with group name
            HStack {
                if !selectedGroupName.isEmpty {
                    Text(selectedGroupName)
                        .font(.largeTitle)
                        .fontWeight(.bold)
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

            // Loading / Error / Members
            if isLoading {
                ProgressView("Loading...")
                    .padding()
            } else if let error = errorMessage {
                Text("Error: \(error)")
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
            } else {
                VStack(spacing: 12) {
                    ForEach(members.sorted { $0.score > $1.score }) { member in
                        AmountRow(name: member.name, amount: Double(member.score))
                    }
                }
            }

            Spacer()
        }
        .padding()
        .onAppear {
            loadCurrentUserGroup()
        }
    }

    // MARK: - Load Data

    private func loadCurrentUserGroup() {
        isLoading = true
        errorMessage = nil

        authVM.getCurrentUserHomeGroup { result in
            switch result {
            case .success(let homeGroup):
                selectedGroupName = homeGroup

                // Fetch all users in this group
                groupVM.getAllUsersInGroup(groupName: homeGroup) { usersResult in
                    isLoading = false
                    switch usersResult {
                    case .success(let users):
                        members = users.map { Member(name: $0.username, score: $0.score) }
                    case .failure(let error):
                        errorMessage = error.localizedDescription
                        members = []
                    }
                }

            case .failure(let error):
                isLoading = false
                errorMessage = error.localizedDescription
                selectedGroupName = ""
                members = []
            }
        }
    }
}
