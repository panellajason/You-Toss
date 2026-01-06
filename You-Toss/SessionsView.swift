//
//  SessionsView.swift
//  You-Toss
//
//  Created by Tony Hunt on 12/31/25.
//

import SwiftUI

struct SessionsView: View {
    
    @Binding var selectedTab: Int

    @StateObject private var authVM = AuthViewModel()
    @StateObject private var groupVM = GroupViewModel()
    @StateObject private var sessionVM = SessionViewModel()

    @State private var currentGroup: String = ""
    @State private var activeSession: Session? = nil
    @State private var loading = false
    @State private var showStartSession = false
    @State private var showEditBuyIn: Session.Player? = nil
    @State private var showAddPlayers = false
    @State private var showBadBeats = false
    @State private var showCashOut = false
    @State private var showUniqueHand = false
    @State private var userHomeGroup: String = ""

    @State private var allUserGroups: [(groupID: String, groupName: String, score: Double)] = []
    @State private var currentGroupMembers: [String] = []
    
    private var totalBuyIns: Double {
        activeSession?.players.reduce(0) { $0 + $1.buyIn } ?? 0
    }

    struct Session {
        struct Player: Identifiable {
            let id = UUID()
            var name: String
            var buyIn: Double
            var cashOut: Double
        }
        let groupName: String
        var players: [Player]
        var badBeats: [BadBeat]
    }

    var body: some View {
        VStack {
            
            if (loading) {
                VStack(spacing: 16) {
                    Spacer()
                    ProgressView("Loading...")
                        .padding()
                    Spacer()
                }
            } else {
                if (userHomeGroup.isEmpty) {
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
                } else {
                    Text("Current Home Group: \(userHomeGroup.isEmpty ? "None" : userHomeGroup)")
                        .font(.title2)
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
                        
                        Text("Total Buy-Ins: $\(String(format: "%.2f", totalBuyIns))")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .padding(.horizontal)
                            .padding(.top, 8)

                        HStack(spacing: 12) {
                            Button(action: { showBadBeats = true }) {
                                Text("Add Bad Beat")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.orange)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }

                            Button(action: { showUniqueHand = true }) {
                                Text("Add Unique Hand")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.orange)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                        }
                        .padding([.top, .leading, .trailing])

                        HStack(spacing: 12) {
                            Button(action: { showAddPlayers = true }) {
                                Text("Add Player")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }

                            Button(action: { showCashOut = true }) {
                                Text("Cash Out")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                        }
                        .padding()
                    } else {
                        
                        Text("No current sessions")
                            .font(.title2)
                            .fontWeight(.medium)
                            .padding()
                        
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
            }
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
                            Session.Player(name: name, buyIn: buyIn, cashOut: 0)
                        },
                        badBeats: []
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
                sessionVM.addNewPlayers(groupName: activeSession?.groupName ?? "", newPlayers: newPlayers) { result in
                        switch result {
                        case .success:
                            // Optionally update local state to match Firestore
                            let newSessionPlayers = newPlayers.map {
                                Session.Player(name: $0, buyIn: 0, cashOut: 0)
                            }
                            activeSession?.players.append(contentsOf: newSessionPlayers)

                        case .failure(let error):
                            print("Failed to add players:", error)
                        }
                    }
            }
        }
        .sheet(isPresented: $showBadBeats) {
            let currentSessionNames = activeSession?.players.map { $0.name } ?? []

            AddBadBeats(
                allGroupPlayers: currentSessionNames,
                groupName: activeSession?.groupName ?? "None"
            ) { badBeat in
                
            }
        }
        .sheet(isPresented: $showCashOut) {
            CashOutView(groupName: activeSession?.groupName ?? "", players: activeSession?.players ?? []) { _ in
                activeSession = nil
            }
        }
        .onAppear {
            loading = true
            authVM.getCurrentUserHomeGroup(completion: { result in
                switch result {
                case .success(let homeGroup):
                    userHomeGroup = homeGroup

                case .failure:
                    // No home group found
                    break
                }
            })
            sessionVM.getActiveSessionForCurrentUser { result in
                loading = false
                switch result {
                case .success(let data):
                    guard
                        let groupName = data["group_name"] as? String,
                        let playersArray = data["players"] as? [[String: Any]],
                        let badBeatsArray = data["badBeats"] as? [[String: Any]]

                    else { return }

                    var badBeats = badBeatsArray.compactMap { dict -> BadBeat? in
                        guard
                            let loser = dict["loser"] as? String,
                            let loserHand = dict["loserHand"] as? String,
                            let street = dict["street"] as? String,
                            let winner = dict["winner"] as? String,
                            let winnerHand = dict["winnerHand"] as? String
                        else { return nil }

                        return BadBeat(loser: loser, loserHand: loserHand, street: street, winner: winner, winnerHand: winnerHand)
                    }
                    
                    let players = playersArray.compactMap { dict -> SessionsView.Session.Player? in
                        guard
                            let username = dict["username"] as? String,
                            let buyIn = dict["buyIn"] as? Double,
                            let cashOut = dict["cashOut"] as? Double
                        else { return nil }

                        return SessionsView.Session.Player(name: username, buyIn: buyIn, cashOut: cashOut)
                    }
                    
                    if (badBeats.isEmpty) {
                        badBeats = []
                    }

                    if !players.isEmpty {
                        activeSession = SessionsView.Session(groupName: groupName, players: players, badBeats: badBeats)
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
