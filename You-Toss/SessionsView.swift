//
//  SessionsView.swift
//  You-Toss
//
//  Created by Tony Hunt on 12/31/25.
//

import SwiftUI

struct SessionsView: View {
    @State private var currentGroup: String = "Trip to NYC"
    @State private var activeSession: Session? = nil
    @State private var showStartSession = false
    @State private var showEditBuyIn: Session.Player? = nil
    @State private var showAddPlayers = false
    @State private var showCashOut = false

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
            Text("Current Group: \(currentGroup)")
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
                    // Add Player button
                    Button(action: {
                        showAddPlayers = true
                    }) {
                        Text("Add Player")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }

                    // Cash Out button
                    Button(action: {
                        showCashOut = true
                    }) {
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
                Button(action: {
                    showStartSession = true
                }) {
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
        // MARK: - Sheets
        .sheet(isPresented: $showStartSession) {
            StartSessionView(
                groups: ["Trip to NYC", "Roommates", "Ski Weekend"],
                onStart: { selectedGroup, selectedPlayers in
                    activeSession = Session(
                        groupName: selectedGroup,
                        players: selectedPlayers.keys.map { playerName in
                            Session.Player(
                                name: playerName,
                                buyIn: selectedPlayers[playerName] ?? 0
                            )
                        }
                    )
                }
            )
        }
        .sheet(item: $showEditBuyIn) { player in
            EditBuyInView(player: player) { newAmount in
                if let index = activeSession?.players.firstIndex(where: { $0.id == player.id }) {
                    activeSession?.players[index].buyIn = newAmount
                }
            }
        }
        .sheet(isPresented: $showAddPlayers) {
            // Example: hardcoded group members
            let groupMembers = ["Alex", "Sam", "Jordan", "Chris", "Taylor"] // replace with real data
            let currentSessionNames = activeSession?.players.map { $0.name } ?? []

            AddPlayersView(
                allGroupPlayers: groupMembers.filter { !currentSessionNames.contains($0) }
            ) { newPlayers in
                let newSessionPlayers = newPlayers.map { Session.Player(name: $0, buyIn: 0) }
                activeSession?.players.append(contentsOf: newSessionPlayers)
            }
        }
        .sheet(isPresented: $showCashOut) {
            CashOutView(players: activeSession?.players ?? []) { updatedPlayers in
                // End session
                activeSession = nil
                // Optionally handle updatedPlayers
            }
        }
    }
}
