import SwiftUI

struct SummaryItem: Identifiable {
    let id = UUID()
    let name: String
    let amount: Double
}

struct SummaryListView: View {
    let mode: Mode

    @State private var items: [SummaryItem] = []
    @StateObject private var groupVM = GroupViewModel()

    enum Mode {
        case groups

        var title: String {
            switch self {
            case .groups:
                return "My Groups"
            }
        }
    }

    var body: some View {
        Group {
            if items.isEmpty {
                Text("No items to display")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(items.sorted { $0.amount > $1.amount }) { item in
                            AmountRow(name: item.name, amount: item.amount)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle(mode.title)
        .onAppear {
            switch mode {
            case .groups:
                fetchGroups()
            }
        }
    }

    // MARK: - Fetch Groups
    private func fetchGroups() {
        groupVM.getAllGroupsForUser { result in
            switch result {
            case .success(let groups):
                items = groups.map { SummaryItem(name: $0.groupName, amount: Double($0.score)) }
            case .failure(let error):
                items = []
                print("Error fetching groups: \(error.localizedDescription)")
            }
        }
    }
}

