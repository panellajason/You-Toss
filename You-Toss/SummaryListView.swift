//
//  MyGroupsView.swift
//  You-Toss
//
//  Created by Tony Hunt on 12/31/25.
//

import Foundation

import SwiftUI

struct SummaryItem: Identifiable {
    let id = UUID()
    let name: String
    let amount: Double
}

struct SummaryListView: View {
    let title: String
    let items: [SummaryItem]

    var body: some View {
        VStack(spacing: 16) {

            ForEach(items.sorted { $0.amount > $1.amount }) { item in
                AmountRow(name: item.name, amount: item.amount)
            }

            Spacer()
        }
        .padding()
        .navigationTitle(title)
    }
}
