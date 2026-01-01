//
//  ContentView.swift
//  You-Toss
//
//  Created by Panella, Jason on 12/31/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(selectedTab: $selectedTab)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)

            SessionsView()
                .tabItem {
                    Image(systemName: "play.circle")
                    Text("Session")
                }
                .tag(1)

            NavigationStack {
                AccountView()
            }
            .tabItem {
                Image(systemName: "person.circle.fill")
                Text("Account")
            }
            .tag(2)
        }
    }
}

// MARK: - Tab Views

struct SearchView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .font(.system(size: 48))
            Text("Search Tab")
                .font(.title)
        }
    }
}

struct ProfileView: View {
    var body: some View {
        VStack {
            Image(systemName: "star.circle")
                .font(.system(size: 48))
            Text("Profile Tab")
                .font(.title)
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
}

