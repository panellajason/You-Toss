//
//  AddBadBeats.swift
//  You-Toss
//
//  Created by Jason Panella on 12/31/25.
//
import SwiftUI

struct AddBadBeats: View {
    let allGroupPlayers: [String]
    let groupName: String

    var onAddBadBeat: (BadBeat) -> Void

    @Environment(\.dismiss) var dismiss

    @State private var selectedWinner = ""
    @State private var selectedHand = ""
    @State private var selectedLoser = ""

    private let hands = ["Triples", "Straight", "Full House"]

    var body: some View {
        NavigationStack {
            Form {

                Section("Select Winner") {
                    Picker("Winner", selection: $selectedWinner) {
                        Text("Select a Player").tag("")
                        ForEach(allGroupPlayers, id: \.self) {
                            Text($0).tag($0)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section("Select Hand") {
                    Picker("Hand", selection: $selectedHand) {
                        Text("Select a Hand").tag("")
                        ForEach(hands, id: \.self) {
                            Text($0).tag($0)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section("Select Loser") {
                    Picker("Loser", selection: $selectedLoser) {
                        Text("Select a Player").tag("")
                        ForEach(allGroupPlayers, id: \.self) {
                            Text($0).tag($0)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section {
                    Button("Add Bad Beat") {
                        let badBeat = BadBeat(
                            winner: selectedWinner,
                            hand: selectedHand,
                            loser: selectedLoser
                        )
                        onAddBadBeat(badBeat)
                        dismiss()
                    }
                    .disabled(!isFormValid)
                }
            }
            .navigationTitle("Add Bad Beat")
        }
    }

    private var isFormValid: Bool {
        !selectedWinner.isEmpty &&
        !selectedHand.isEmpty &&
        !selectedLoser.isEmpty &&
        selectedWinner != selectedLoser
    }
}

struct BadBeat {
    let winner: String
    let hand: String
    let loser: String

    func toDictionary() -> [String: String] {
        [
            "winner": winner,
            "hand": hand,
            "loser": loser
        ]
    }
}

