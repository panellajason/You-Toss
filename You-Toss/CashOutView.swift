//
//  CashOutView.swift
//  You-Toss
//
//  Created by Tony Hunt on 12/31/25.
//

import SwiftUI

struct CashOutView: View {
    var players: [SessionsView.Session.Player]
    var onEndSession: ([SessionsView.Session.Player]) -> Void
    @Environment(\.dismiss) var dismiss

    // State for editable cash-out amounts, default 0
    @State private var cashOutAmounts: [UUID: String] = [:]

    var body: some View {
        VStack(spacing: 16) {
            Text("Cash Out")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(players) { player in
                        AmountRowEditable(name: player.name, amountText: Binding(
                            get: { cashOutAmounts[player.id] ?? "0.00" },
                            set: { cashOutAmounts[player.id] = $0 }
                        ))
                    }
                }
                .padding()
            }

            Spacer()

            Button(action: {
                // Convert entered strings to Doubles and update players
                var updatedPlayers = players
                for i in 0..<updatedPlayers.count {
                    if let value = Double(cashOutAmounts[updatedPlayers[i].id] ?? "") {
                        updatedPlayers[i].buyIn = value
                    } else {
                        updatedPlayers[i].buyIn = 0
                    }
                }

                onEndSession(updatedPlayers)
                dismiss()
            }) {
                Text("End Session")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding()
        }
        .onAppear {
            // Initialize cashOutAmounts with 0 for all players
            for player in players {
                cashOutAmounts[player.id] = "0.00"
            }
        }
    }
}
