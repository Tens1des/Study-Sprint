//
//  ContentView.swift
//  Study Sprint
//
//  Created by Рома Котов on 01.10.2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            TimerView()
                .tabItem { Label("Timer", systemImage: "timer") }
            TagsView()
                .tabItem { Label("Subjects", systemImage: "book") }
            StatisticsView()
                .tabItem { Label("Statistics", systemImage: "chart.bar.xaxis") }
            AchievementsView()
                .tabItem { Label("Achievements", systemImage: "rosette") }
            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape") }
        }
    }
}

#Preview {
    ContentView().environmentObject(AppState())
}
