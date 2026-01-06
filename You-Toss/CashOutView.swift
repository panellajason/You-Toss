//
//  CashOutView.swift
//  You-Toss
//
//  Created by Tony Hunt on 12/31/25.
//

import SwiftUI

struct CashOutView: View {
    @StateObject private var sessionVM = SessionViewModel()

    let groupName: String
    var players: [SessionsView.Session.Player]
    var onEndSession: ([SessionsView.Session.Player]) -> Void
    @Environment(\.dismiss) var dismiss

    // State for editable cash-out amounts, default 0
    @State private var cashOutAmounts: [UUID: String] = [:]
    @State private var loading = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showConfirmEndSession = false

    private var totalBuyIns: Double {
        players.reduce(0) { $0 + $1.buyIn }
    }
    
    private var totalCashOut: Double {
        players.reduce(0) { $0 + (Double(cashOutAmounts[$1.id] ?? "0") ?? 0) }
    }
    
    private var totalDifference: Double {
        totalCashOut - totalBuyIns
    }
    
    private var differenceColor: Color {
        totalDifference < 0 ? .red : .green
    }
    
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
                            get: { cashOutAmounts[player.id] ?? "" },
                            set: { cashOutAmounts[player.id] = $0 }
                        ))
                    }
                }
                .padding()
            }

            Spacer()
            
            VStack(spacing: 4) {
                Text("Total Buy-Ins: $\(String(format: "%.2f", totalBuyIns))")
                    .font(.headline)
                    .foregroundColor(.black)
                
                Text("Total Cash Out: $\(String(format: "%.2f", totalCashOut))")
                    .font(.headline)
                    .foregroundColor(.blue)
                
                Text("Difference: $\(String(format: "%.2f", totalDifference))")
                    .font(.headline)
                    .foregroundColor(differenceColor)
                }

            Button(action: {
                showConfirmEndSession = true
            }) {
                if loading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                } else {
                    Text("End Session")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .padding()
        }
        .onAppear {
            // Initialize cashOutAmounts with 0 for all players
            for player in players {
                cashOutAmounts[player.id] = "0"
            }
        }
        .alert("Something went wrong", isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
        .alert("Confirm End Session", isPresented: $showConfirmEndSession) {
            Button("Cancel", role: .cancel) {}
            Button("End Session", role: .destructive) {
                handleEndSession()
            }
        } message: {
            Text("Are you sure you want to end the session?")
        }
    }
    
    func handleEndSession() {
        // Convert entered strings to Doubles and update players
        var updatedPlayers = players
        for i in 0..<updatedPlayers.count {
            if let value = Double(cashOutAmounts[updatedPlayers[i].id] ?? "0") {
                updatedPlayers[i].cashOut = value
            } else {
                updatedPlayers[i].cashOut = 0
            }
        }
        
        // Prepare players data for Firestore
        let playersData: [[String: Any]] = updatedPlayers.map { player in
            [
                "username": player.name,
                "buyIn": player.buyIn,
                "cashOut": player.cashOut
            ]
        }

        // End session and update players in Firestore
        loading = true
        sessionVM.endSessionWithPlayerData(groupName: groupName, players: playersData) { result in
            loading = false
            switch result {
            case .success:
                print("Session ended and players updated successfully")
                onEndSession(updatedPlayers)
                dismiss()
            case .failure(let error):
                alertMessage = "Failed to end session: " + error.localizedDescription
                showAlert = true
            }
        }

    }
}
