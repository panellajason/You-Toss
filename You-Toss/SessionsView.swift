//
//  SessionsView.swift
//  You-Toss
//
//  Created by Tony Hunt on 12/31/25.
//

import SwiftUI

struct SessionsView: View {
    @StateObject private var groupVM = GroupViewModel()
    @StateObject private var sessionVM = SessionViewModel()

    @State private var currentGroup: String = ""
    @State private var activeSession: Session? = nil
    @State private var showStartSession = false
    @State private var showEditBuyIn: Session.Player? = nil
    @State private var showAddPlayers = false
    @State private var showCashOut = false

    @State private var allUserGroups: [(groupID: String, groupName: String, score: Int)] = []
    @State private var currentGroupMembers: [String] = []

    struct Session {
        struct Player: Identifiable {
            let id = UUID()
            var name: String
            var buyIn: Double
        }
        let groupName: String
        var players: [Player]
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("Current Group: \(currentGroup.isEmpty ? "None" : currentGroup)")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            if let session = activeSession {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(session.players) { player in
                            HStack {
                                Text(player.name)
                                    .font(.headline)
                                Spacer()
                                Text("$\(String(format: "%.2f", player.buyIn))")
                                    .foregroundColor(.green)
                                Button(action: {
                                    showEditBuyIn = player
                                }) {
                                    Image(systemName: "pencil")
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                }

                HStack(spacing: 12) {
                    Button(action: { showAddPlayers = true }) {
                        Text("Add Player")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }

                    Button(action: { showCashOut = true }) {
                        Text("Cash Out")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
                .padding()
            } else {
                Button(action: { showStartSession = true }) {
                    Text("Start a Session")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding()
            }

            Spacer()
        }
        // MARK: - onChange: Fetch group members when currentGroup changes
        .onChange(of: currentGroup) { newGroup in
            guard !newGroup.isEmpty else { return }
            groupVM.getAllUsersInGroup(groupName: newGroup) { result in
                switch result {
                case .success(let users):
                    currentGroupMembers = users.map { $0.username }
                case .failure(let error):
                    currentGroupMembers = []
                    print("Error fetching group members: \(error.localizedDescription)")
                }
            }
            // Reset active session players
//            activeSession = Session(groupName: newGroup, players: [])
        }
        // MARK: - Sheets
        .sheet(isPresented: $showStartSession, onDismiss: { allUserGroups = [] }) {
            // Fetch all groups first
            groupVM.getAllGroupsForUser { result in
                switch result {
                case .success(let groups):
                    allUserGroups = groups
                case .failure(let error):
                    allUserGroups = []
                    print("Error fetching groups: \(error.localizedDescription)")
                }
            }

            return StartSessionView(
                groups: allUserGroups.map { $0.groupName },
                onStart: { selectedGroup, selectedPlayers in
                    currentGroup = selectedGroup
                    // Map selectedPlayers dictionary to Session.Player array
                    activeSession = Session(
                        groupName: selectedGroup,
                        players: selectedPlayers.map { name, buyIn in
                            Session.Player(name: name, buyIn: buyIn)
                        }
                    )
                }
            )

        }
        .sheet(item: $showEditBuyIn) { player in
            EditBuyInView(player: player) { newAmount in
                if let index = activeSession?.players.firstIndex(where: { $0.id == player.id }) {
                    activeSession?.players[index].buyIn = newAmount
                    // Update Firestore
                    sessionVM.updateUserBuyIn(
                        groupName: activeSession!.groupName,
                        username: player.name,
                        newBuyIn: newAmount
                    ) { result in
                        switch result {
                        case .success:
                            print("Buy-in updated successfully in Firestore")
                        case .failure(let error):
                            print("Failed to update buy-in:", error.localizedDescription)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showAddPlayers) {
            // Only show players not already in the session
            let currentSessionNames = activeSession?.players.map { $0.name } ?? []
            AddPlayersView(
                allGroupPlayers: currentGroupMembers.filter { !currentSessionNames.contains($0) }
            ) { newPlayers in
                let newSessionPlayers = newPlayers.map { Session.Player(name: $0, buyIn: 0) }
                activeSession?.players.append(contentsOf: newSessionPlayers)
            }
        }
        .sheet(isPresented: $showCashOut) {
            CashOutView(players: activeSession?.players ?? []) { updatedPlayers in
                
                activeSession = nil
            }
        }
        .onAppear {
            sessionVM.getActiveSessionForCurrentUser { result in
                switch result {
                case .success(let data):
                    guard
                        let groupName = data["group_name"] as? String,
                        let playersArray = data["players"] as? [[String: Any]]
                    else { return }

                    let players = playersArray.compactMap { dict -> SessionsView.Session.Player? in
                        guard
                            let username = dict["username"] as? String,
                            let buyIn = dict["buyIn"] as? Double
                        else { return nil }

                        return SessionsView.Session.Player(name: username, buyIn: buyIn)
                    }

                    if !players.isEmpty {
                        activeSession = SessionsView.Session(groupName: groupName, players: players)
                        currentGroup = groupName
                    }

                case .failure:
                    // No active session found, keep activeSession nil
                    break
                }
            }
        }

    }
}
