//
//  AmountRowEditable.swift
//  You-Toss
//
//  Created by Tony Hunt on 12/31/25.
//

import SwiftUI

struct AmountRowEditable: View {
    let name: String
    @Binding var amountText: String

    var body: some View {
        HStack {
            Text(name)
                .font(.headline)
            Spacer()
            TextField(
                "$0.00",
                text: $amountText
            )
            .keyboardType(.decimalPad)
            .multilineTextAlignment(.trailing)
            .frame(width: 80)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
