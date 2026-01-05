import SwiftUI

struct MySession: Identifiable {
    let id = UUID()
    let date: String
    let amount: Double
    let sessionId: String
}

struct MySessionsView: View {

    @State private var items: [MySession] = []
    @StateObject private var sessionVM = SessionViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                if items.isEmpty {
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
            DispatchQueue.main.async {
                switch result {
                case .success(let sessions):
                    items = sessions.compactMap { session in
                        MySession(
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

}

