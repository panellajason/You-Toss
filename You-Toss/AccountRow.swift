//
//  AccountRow.swift
//  You-Toss
//
//  Created by Tony Hunt on 12/31/25.
//

import SwiftUI

struct AmountRow: View {
    let name: String
    let amount: Double

    var body: some View {
        HStack {
            Text(name)
                .font(.headline)

            Spacer()

            Text(formattedAmount(amount))
                .fontWeight(.semibold)
                .foregroundColor(amount >= 0 ? .green : .red)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private func formattedAmount(_ amount: Double) -> String {
        let sign = amount >= 0 ? "$" : "-$"
        return "\(sign)\(String(format: "%.2f", abs(amount)))"
    }
}
