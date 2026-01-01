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
    @StateObject private var sessionVM = SessionViewModel()

    enum Mode {
        case groups
        case sessions

        var title: String {
            switch self {
            case .groups:
                return "My Groups"
            case .sessions:
                return "My Sessions"
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
            case .sessions:
                fetchSessions()
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

    // MARK: - Fetch Sessions
    private func fetchSessions() {
        sessionVM.getAllSessionsForCurrentUser { result in
            switch result {
            case .success(let sessionsArray):
                // Map each session dictionary to SummaryItem
                items = sessionsArray.compactMap { sessionDict in
                    guard let sessionName = sessionDict["session_name"] as? String,
                          let players = sessionDict["players"] as? [[String: Any]] else {
                        return nil
                    }

                    // Calculate total amount (sum of player buyIns)
                    let totalAmount = players.reduce(0.0) { sum, playerDict in
                        if let buyIn = playerDict["buyIn"] as? Double {
                            return sum + buyIn
                        } else if let buyInInt = playerDict["buyIn"] as? Int {
                            return sum + Double(buyInInt)
                        }
                        return sum
                    }

                    return SummaryItem(name: sessionName, amount: totalAmount)
                }

            case .failure(let error):
                items = []
                print("Error fetching sessions: \(error.localizedDescription)")
            }
        }
    }
}
