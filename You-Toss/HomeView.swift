//
//  HomeView.swift
//  You-Toss
//
//  Created by Tony Hunt on 12/31/25.
//

import SwiftUI

struct HomeView: View {

    // MARK: - Mock Data

    @State private var selectedGroup: Group = .mockGroups.first!

    struct Group: Identifiable, Hashable {
        let id = UUID()
        let name: String
        let members: [Member]

        static let mockGroups: [Group] = [
            Group(
                name: "Trip to NYC",
                members: [
                    Member(name: "Alex", amount: 42.50),
                    Member(name: "Sam", amount: -15.00),
                    Member(name: "Jordan", amount: 8.75)
                ]
            ),
            Group(
                name: "Roommates",
                members: [
                    Member(name: "Chris", amount: 120.00),
                    Member(name: "Taylor", amount: -60.25)
                ]
            )
        ]
    }

    struct Member: Identifiable, Hashable {
        let id = UUID()
        let name: String
        let amount: Double
    }

    // MARK: - View

    var body: some View {
        VStack(spacing: 24) {

            // Header with group selector
            HStack {
                Text(selectedGroup.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Menu {
                    ForEach(Group.mockGroups) { group in
                        Button(group.name) {
                            selectedGroup = group
                        }
                    }
                } label: {
                    Image(systemName: "chevron.down.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.blue)
                }

                Spacer()
            }

            // Members list
            VStack(spacing: 12) {
                ForEach(selectedGroup.members.sorted { $0.amount > $1.amount }) { member in
                    MemberRow(member: member)
                }
            }

            Spacer()
        }
        .padding()
    }
}

// MARK: - Member Row

struct MemberRow: View {
    let member: HomeView.Member

    var body: some View {
        HStack {
            Text(member.name)
                .font(.headline)

            Spacer()

            Text(formattedAmount(member.amount))
                .fontWeight(.semibold)
                .foregroundColor(member.amount >= 0 ? .green : .red)
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

// MARK: - Preview

#Preview {
    HomeView()
}
