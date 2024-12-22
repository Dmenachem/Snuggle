//
//  ContentView.swift
//  Snuggle
//
//  Created by Dor Menachem on 20/12/2024.
//

import SwiftUI
import Foundation

struct ContentView: View {
    @StateObject private var babyTracker = BabyTracker()
    @StateObject private var themeManager = ThemeManager()
    @AppStorage("app.language") private var language = "en"
    @State private var shouldRestart = false
    
    var body: some View {
        TabView {
            NavigationStack {
                TrackingView()
                    .navigationTitle("Snuggle")
            }
            .tabItem {
                Image(systemName: "plus.circle.fill")
                Text("tab.track".localized)
            }
            
            NavigationStack {
                EngagementView()
                    .navigationTitle("Achievements")
            }
            .tabItem {
                Image(systemName: "trophy.fill")
                Text("tab.achievements".localized)
            }
            
            NavigationStack {
                HistoryView()
                    .navigationTitle("tab.history".localized)
            }
            .tabItem {
                Image(systemName: "chart.xyaxis.line")
                Text("tab.history".localized)
            }
            
            NavigationStack {
                ProfileView()
                    .navigationTitle("tab.profile".localized)
            }
            .tabItem {
                Image(systemName: "person.fill")
                Text("tab.profile".localized)
            }
        }
        .environmentObject(babyTracker)
        .environmentObject(themeManager)
        .preferredColorScheme(themeManager.colorScheme)
        .onAppear {
            babyTracker.trackAppOpen() // Track app opens for streaks
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("RestartApp"))) { _ in
            shouldRestart = true
        }
        .fullScreenCover(isPresented: $shouldRestart) {
            ContentView()
        }
    }
}

#Preview {
    ContentView()
}
