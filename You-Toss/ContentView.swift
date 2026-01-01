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

            SearchView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }

            ProfileView()
                .tabItem {
                    Image(systemName: "person.circle.fill")
                    Text("Profile")
                }
        }
    }
}

// MARK: - Tab Views

struct HomeView: View {
    var body: some View {
        VStack {
            Image(systemName: "sparkles")
                .font(.system(size: 48))
            Text("Home Tab")
                .font(.title)
        }
    }
}

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

