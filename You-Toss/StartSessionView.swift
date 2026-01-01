//
//  StartSessionView.swift
//  You-Toss
//
//  Created by Tony Hunt on 12/31/25.
//

import SwiftUI

struct StartSessionView: View {
    let groups: [String]
    var onStart: (String, [String: Double]) -> Void

    @Environment(\.dismiss) var dismiss

    @State private var selectedGroup: String = ""
    @State private var allPlayers: [String] = []
    @State private var selectedPlayers: [String: Double] = [:] // name → buy-in

    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Select Group
                Section("Select Group") {
                    Picker("Group", selection: $selectedGroup) {
                        Text("Select a Group").tag("")
                        ForEach(groups, id: \.self) { group in
                            Text(group).tag(group)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: selectedGroup) { newGroup in
                        // Mock players per group
                        switch newGroup {
                        case "Trip to NYC":
                            allPlayers = ["Alex", "Sam", "Jordan"]
                        case "Roommates":
                            allPlayers = ["Chris", "Taylor"]
                        case "Ski Weekend":
                            allPlayers = ["Morgan", "Jamie", "Riley"]
                        default:
                            allPlayers = []
                        }
                        selectedPlayers.removeAll()
                    }
                }

                // MARK: - Select Players (Capsule UI)
                if !allPlayers.isEmpty {
                    Section("Select Players") {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(allPlayers, id: \.self) { player in
                                    Button(action: {
                                        if selectedPlayers.keys.contains(player) {
                                            selectedPlayers.removeValue(forKey: player)
                                        } else {
                                            selectedPlayers[player] = 0
                                        }
                                    }) {
                                        HStack {
                                            Text(player)
                                                .foregroundColor(selectedPlayers.keys.contains(player) ? .white : .primary)

                                            Image(systemName: selectedPlayers.keys.contains(player) ? "minus.circle.fill" : "plus.circle")
                                                .foregroundColor(selectedPlayers.keys.contains(player) ? .white : .blue)
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(selectedPlayers.keys.contains(player) ? Color.blue : Color(.systemGray6))
                                        .clipShape(Capsule())
                                    }
                                }
                            }
                        }
                    }
                }

                // MARK: - Set Player Buy-In
                if !selectedPlayers.isEmpty {
                    Section("Set Player Buy-In") {
                        ForEach(selectedPlayers.keys.sorted(), id: \.self) { player in
                            HStack {
                                Text(player)
                                Spacer()
                                TextField("Amount", value: Binding(
                                    get: { selectedPlayers[player] ?? 0 },
                                    set: { selectedPlayers[player] = $0 }
                                ), format: .number)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)
                            }
                        }
                    }
                }

                // MARK: - Submit Button
                Section {
                    Button("Start Session") {
                        onStart(selectedGroup, selectedPlayers)
                        dismiss()
                    }
                    .disabled(selectedGroup.isEmpty || selectedPlayers.isEmpty)
                }
            }
            .navigationTitle("Start Session")
        }
    }
}
