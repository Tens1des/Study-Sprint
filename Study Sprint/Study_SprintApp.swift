//
//  Study_SprintApp.swift
//  Study Sprint
//
//  Created by Рома Котов on 01.10.2025.
//

import SwiftUI

@main
struct Study_SprintApp: App {
    @StateObject private var appState = AppState()
    var body: some Scene {
        WindowGroup {
            let sizeCategory: ContentSizeCategory = appState.settings.textScale > 1.2 ? .accessibilityExtraExtraExtraLarge : .large
            ContentView()
                .environmentObject(appState)
                .environment(\.sizeCategory, sizeCategory)
                .preferredColorScheme(appState.settings.theme == .dark ? .dark : .light)
        }
    }
}
