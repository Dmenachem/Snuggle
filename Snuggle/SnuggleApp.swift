//
//  SnuggleApp.swift
//  Snuggle
//
//  Created by Dor Menachem on 20/12/2024.
//

import SwiftUI

@main
struct SnuggleApp: App {
    @AppStorage("app.language") private var language = "en"
    @StateObject private var restartManager = AppRestartManager()
    
    init() {
        // Set initial language
        if let languageCode = UserDefaults.standard.string(forKey: "app.language") {
            UserDefaults.standard.set([languageCode], forKey: "AppleLanguages")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            if restartManager.needsRestart {
                Color.clear
                    .onAppear {
                        restartManager.restartApp()
                    }
            } else {
                ContentView()
                    .environment(\.layoutDirection, language == "he" ? .rightToLeft : .leftToRight)
            }
        }
    }
}

class AppRestartManager: ObservableObject {
    @Published var needsRestart = false
    
    init() {
        // Listen for restart notifications
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("RestartApp"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.needsRestart = true
        }
    }
    
    func restartApp() {
        needsRestart = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Get the current window scene
            if let windowScene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                // Get the windows in this scene
                let windows = windowScene.windows
                // Find the key window and update its root view controller
                if let window = windows.first(where: { $0.isKeyWindow }) {
                    let language = UserDefaults.standard.string(forKey: "app.language") ?? "en"
                    let contentView = ContentView()
                        .environment(\.layoutDirection, language == "he" ? .rightToLeft : .leftToRight)
                    window.rootViewController = UIHostingController(rootView: contentView)
                }
            }
        }
    }
}
