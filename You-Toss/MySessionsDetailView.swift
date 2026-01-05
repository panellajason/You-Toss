import Firebase
import SwiftUI

struct SessionPlayer: Identifiable {
    let id = UUID()
    let name: String
    let buyIn: Double
    let cashOut: Double
    var net: Double { cashOut - buyIn }
}

struct MySessionsDetailView: View {
    let date: String
    let sessionId: String

    @State private var players: [SessionPlayer] = []
    @State private var loading = true

    private let db = Firestore.firestore()

    var body: some View {
        Group {
            if loading {
                ProgressView("Loading Session...")
            } else if players.isEmpty {
                Text("No players found")
                    .foregroundColor(.gray)
            } else {
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
        .navigationTitle(date)
        .onAppear {
            fetchSession()
        }
    }

    private func fetchSession() {
        db.collection("sessions")
            .document(sessionId)
            .getDocument { snapshot, error in
                DispatchQueue.main.async {
                    loading = false

                    guard
                        let data = snapshot?.data(),
                        let playersData = data["players"] as? [[String: Any]]
                    else {
                        return
                    }

                    players = playersData.compactMap {
                        guard
                            let username = $0["username"] as? String,
                            let buyIn = $0["buyIn"] as? Double,
                            let cashOut = $0["cashOut"] as? Double
                        else {
                            return nil
                        }

                        return SessionPlayer(
                            name: username,
                            buyIn: buyIn,
                            cashOut: cashOut
                        )
                    }
                }
            }
    }
}
