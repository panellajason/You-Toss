import Firebase
import SwiftUI

struct MySessionsDetailView: View {
    @StateObject private var sessionVM = SessionViewModel()

    let date: String
    let sessionId: String

    @State private var players: [PlayerSessionDetail] = []
    @State private var loading = true

    private let db = Firestore.firestore()

    var body: some View {
        Group {
            if loading {
                VStack {
                    Spacer()
                    ProgressView("Loading Session...")
                        .padding()
                    Spacer()
                }
            } else if players.isEmpty {
                Text("No players found")
                    .foregroundColor(.gray)
            } else {
                Text(date)
                    .font(.title2)
                    .fontWeight(.medium)
                    .padding()
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(players.sorted { $0.name > $1.name }) { item in
                            AmountRow(name: item.name, amount: item.net)
                        }
                    }
                    .padding()
                }

            }
        }
        .onAppear {
            fetchSession()
        }
    }

    private func fetchSession() {
        sessionVM.fetchSession(sessionId: sessionId) { result in
            loading = false
            switch result {
            case .success(let resultPlayers):
                players = resultPlayers
            case .failure(let error):
                print("Failed to fetch session:", error.localizedDescription)
            }
        }
    }
}
