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

    @State private var selectedLoser = ""
    @State private var selectedLoserHand = ""
    @State private var selectedStreet = ""
    @State private var selectedWinner = ""
    @State private var selectedWinnerHand = ""

    private let hands = ["Two Pair", "Trips", "Straight", "Flush", "Full House", "Quads", "Straight Flush", "Royal Flush"]
    private let streets = ["Flop", "Turn", "River"]


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

                Section("Select Winner's Hand") {
                    Picker("Hand", selection: $selectedWinnerHand) {
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
                
                Section("Select Loser's Hand") {
                    Picker("Hand", selection: $selectedLoserHand) {
                        Text("Select a Hand").tag("")
                        ForEach(hands, id: \.self) {
                            Text($0).tag($0)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section("Select Street") {
                    Picker("Hand", selection: $selectedStreet) {
                        Text("Select Street").tag("")
                        ForEach(streets, id: \.self) {
                            Text($0).tag($0)
                        }
                    }
                    .pickerStyle(.menu)
                }

                
                Section {
                    Button("Add Bad Beat") {
                        let badBeat = BadBeat(
                            loser: selectedLoser,
                            loserHand: selectedLoserHand,
                            street: selectedStreet,
                            winner: selectedWinner,
                            winnerHand: selectedWinnerHand
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
        !selectedLoser.isEmpty &&
        !selectedLoserHand.isEmpty &&
        !selectedStreet.isEmpty &&
        !selectedWinner.isEmpty &&
        !selectedWinnerHand.isEmpty &&
        selectedWinner != selectedLoser
    }
}

struct BadBeat {
    let loser: String
    let loserHand: String
    let street: String
    let winner: String
    let winnerHand: String

    func toDictionary() -> [String: String] {
        [
            "loser": loser,
            "loserHand": loserHand,
            "street": street,
            "winner": winner,
            "winnerHand": winnerHand
        ]
    }
}

