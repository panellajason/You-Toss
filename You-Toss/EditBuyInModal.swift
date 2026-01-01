//
//  EditBuyInModal.swift
//  You-Toss
//
//  Created by Tony Hunt on 12/31/25.
//

import SwiftUI

struct EditBuyInView: View {
    var player: SessionsView.Session.Player
    var onSave: (Double) -> Void
    @Environment(\.dismiss) var dismiss

    @State private var amountText: String = ""

    var body: some View {
        VStack(spacing: 24) {
            Text("Edit Buy-In")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text(player.name)
                .font(.title2)

            TextField("Amount", text: $amountText)
                .keyboardType(.decimalPad)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)

            Button("Save") {
                let value = Double(amountText) ?? 0
                onSave(value)
                dismiss()
            }
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)

            Spacer()
        }
        .padding()
        .onAppear {
            amountText = String(format: "%.2f", player.buyIn)
        }
    }
}
