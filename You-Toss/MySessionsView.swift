import SwiftUI

struct SessionItems: Identifiable {
    let id = UUID()
    let date: String
    let amount: Double
    let sessionId: String
}

struct MySessionsView: View {
    @StateObject private var sessionVM = SessionViewModel()

    @State private var items: [SessionItems] = []
    @State private var loading = true

    var body: some View {
        NavigationStack {
            Group {
                if loading {
                    VStack {
                        Spacer()
                        ProgressView("Loading My Sessions...")
                            .padding()
                        Spacer()
                    }
                } else if items.isEmpty {
                    Text("No items to display")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(items) { item in
                                NavigationLink(
                                    destination: MySessionsDetailView(date: item.date, sessionId: item.sessionId)
                                ) {
                                    AmountRow(name: item.date, amount: item.amount)
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("My Sessions")
            .onAppear {
                fetchSessions()
            }
        }
    }

    // MARK: - Fetch Sessions
    private func fetchSessions() {
        sessionVM.getPlayerSessions { result in
            loading = false
            switch result {
            case .success(let sessions):
                items = sessions.compactMap { session in
                    SessionItems(
                        date: session.date,
                        amount: session.cashOut - session.buyIn,
                        sessionId: session.sessionId
                    )
                }

            case .failure(let error):
                items = []
                print("Error fetching sessions: \(error.localizedDescription)")
            }
        }
    }

}

