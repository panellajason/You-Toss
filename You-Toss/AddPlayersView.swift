//
//  AddPlayersView.swift
//  You-Toss
//
//  Created by Tony Hunt on 12/31/25.
//

import SwiftUI

struct AddPlayersView: View {
    let allGroupPlayers: [String]
    var onAdd: ([String]) -> Void
    @Environment(\.dismiss) var dismiss

    @State private var selectedPlayers: [String] = []

    var body: some View {
        VStack(spacing: 16) {
            Text("Add Players")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            ScrollView {
                let columns = [GridItem(.adaptive(minimum: 100), spacing: 12)]
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(allGroupPlayers, id: \.self) { player in
                        Button(action: {
                            if selectedPlayers.contains(player) {
                                selectedPlayers.removeAll { $0 == player }
                            } else {
                                selectedPlayers.append(player)
                            }
                        }) {
                            HStack {
                                Text(player)
                                    .foregroundColor(selectedPlayers.contains(player) ? .white : .primary)
                                Image(systemName: selectedPlayers.contains(player) ? "minus.circle.fill" : "plus.circle")
                                    .foregroundColor(selectedPlayers.contains(player) ? .white : .blue)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(selectedPlayers.contains(player) ? Color.blue : Color(.systemGray6))
                            .clipShape(Capsule())
                        }
                    }
                }
                .padding()
            }

            Button(action: {
                onAdd(selectedPlayers)
                dismiss()
            }) {
                Text("Add Selected Players")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedPlayers.isEmpty ? Color.gray : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .disabled(selectedPlayers.isEmpty)
            .padding()
        }
    }
}
