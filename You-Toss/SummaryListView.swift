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
    let mode: Mode

    let items: [SummaryItem] = []

    enum Mode {
        case groups
        case sessions

        var title: String {
            switch self {
            case .groups:
                "My Groups"
            case .sessions:
                "My Sessions"
            }
        }
    }

    var body: some View {
        Group {
            if items.isEmpty {
                // Empty State
            } else {
                VStack(spacing: 16) {

                    ForEach(items.sorted { $0.amount > $1.amount }) { item in
                        AmountRow(name: item.name, amount: item.amount)
                    }

                    Spacer()
                }
                .padding()
                .navigationTitle(mode.title)
            }
        }
        .onAppear{
            switch mode {
            case .groups:
                // create here
                print()
            case .sessions:
                // create here
                print()
            }
        }
    }
}
