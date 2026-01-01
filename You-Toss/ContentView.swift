//
//  ContentView.swift
//  You-Toss
//
//  Created by Panella, Jason on 12/31/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }

            SessionsView()
                .tabItem {
                    Image(systemName: "play.circle")
                    Text("Session")
                }

            NavigationStack {
                AccountView()
            }
            .tabItem {
                Image(systemName: "person.circle.fill")
                Text("Account")
            }
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

