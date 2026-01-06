//
//  AddBadBeats.swift
//  You-Toss
//
//  Created by Jason Panella on 12/31/25.
//
import SwiftUI

struct AddBadBeats: View {
    @StateObject private var sessionVM = SessionViewModel()

    let allGroupPlayers: [String]
    let groupName: String

    var onAddBadBeat: (BadBeat) -> Void

    @Environment(\.dismiss) var dismiss

    @State private var selectedLoser = ""
    @State private var selectedLoserHand = ""
    @State private var selectedStreet = ""
    @State private var selectedWinner = ""
    @State private var selectedWinnerHand = ""
    
    @State private var loading = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    private let hands = ["Two Pair", "Trips", "Straight", "Flush", "Full House", "Quads", "Straight Flush", "Royal Flush"]
    private let streets = ["Flop", "Turn", "River"]


    var body: some View {
        VStack {
            Text("Add Bad Beat")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

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

                if isFormValid {
                    Section {
                        Button(action: {
                            handleAddBadBeat()
                        }) {
                            if loading {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            } else {
                                Text("Add Bad Beat")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                            
                        }
                    }
                }
            }
            .onChange(of: selectedWinner) { newWinner in
                checkWinnerLoserConflict()
            }
            .onChange(of: selectedLoser) { newLoser in
                checkWinnerLoserConflict()
            }
            .alert("", isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    func handleAddBadBeat() {
        let badBeat = BadBeat(
            loser: selectedLoser,
            loserHand: selectedLoserHand,
            street: selectedStreet,
            winner: selectedWinner,
            winnerHand: selectedWinnerHand
        )
        
        loading = true
        sessionVM.addBadBeat(groupName: groupName, badBeat: badBeat) { result in
            loading = false
            switch result {
            case .success:
                print("Added bad beat")
                onAddBadBeat(badBeat)
                dismiss()
            case .failure(let error):
                alertMessage = "Failed to add bad beat: " + error.localizedDescription
                showAlert = true
            }
        }
    }
    
    func checkWinnerLoserConflict() {
        guard !selectedWinner.isEmpty && !selectedLoser.isEmpty else { return }
        
        if selectedWinner == selectedLoser {
            alertMessage = "Winner and loser cannot be the same player."
            showAlert = true
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

