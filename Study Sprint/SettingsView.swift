import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var app: AppState
    @State private var showingAvatarSheet = false
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(.systemBackground), Color(.systemGroupedBackground)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Settings").font(.largeTitle.bold())
                    Text("Personalize the app").foregroundColor(.secondary)
                    
                    // Profile card
                    VStack(spacing: 12) {
                        Button(action: { showingAvatarSheet = true }) {
                            Image(systemName: app.profile.avatarSystemName)
                                .font(.system(size: 56))
                                .foregroundColor(.white)
                                .frame(width: 96, height: 96)
                                .background(Circle().fill(LinearGradient(colors: [.purple, .blue], startPoint: .topLeading, endPoint: .bottomTrailing)))
                        }
                        TextField("Name", text: Binding(
                            get: { app.profile.name },
                            set: { app.profile.name = $0; app.save() }
                        ))
                        .multilineTextAlignment(.center)
                        .textFieldStyle(.roundedBorder)
                        .frame(maxWidth: 240)
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity)
                .background(RoundedRectangle(cornerRadius: 22).fill(Color(UIColor.secondarySystemBackground)))
                    .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 6)
                    
                    // Theme
                    GroupBox {
                        VStack(alignment: .leading, spacing: 14) {
                            HStack(spacing: 8) {
                                Image(systemName: "paintbrush.pointed.fill").foregroundColor(.purple)
                                Text("Theme").font(.headline)
                            }
                            HStack(spacing: 12) {
                                themeChip(.light, title: "Light", icon: "sun.max")
                                themeChip(.dark, title: "Dark", icon: "moon")
                            }
                        }
                    }
                    
                    // Text size
                    GroupBox {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 8) {
                                Image(systemName: "textformat.size").foregroundColor(.blue)
                                Text("Text size").font(.headline)
                            }
                            HStack {
                                Text("A").font(.caption)
                                Slider(value: Binding(get: { app.settings.textScale }, set: { app.settings.textScale = $0; app.save() }), in: 0.8...1.4)
                                Text("A").font(.title3)
                            }
                        }
                    }
                    
                    // Durations
                    GroupBox {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(spacing: 8) {
                                Image(systemName: "timer").foregroundColor(.orange)
                                Text("Session durations").font(.headline)
                            }
                            Stepper(value: Binding(get: { app.settings.defaultFocusSec/60 }, set: { app.settings.defaultFocusSec = $0*60; app.save() }), in: 5...120, step: 5) {
                                Text("Focus: \(app.settings.defaultFocusSec/60) min")
                            }
                            Stepper(value: Binding(get: { app.settings.defaultBreakSec/60 }, set: { app.settings.defaultBreakSec = $0*60; app.save() }), in: 1...60, step: 1) {
                                Text("Break: \(app.settings.defaultBreakSec/60) min")
                            }
                        }
                    }
                    // end last GroupBox
                }
                .padding(20)
            }
            .background(Color(.systemGroupedBackground))
            .sheet(isPresented: $showingAvatarSheet) { AvatarPicker(selected: $app.profile.avatarSystemName) }
        }
        // end body content
    }
    
        private func themeChip(_ theme: Theme, title: String, icon: String) -> some View {
            Button(action: { app.settings.theme = theme; app.save() }) {
                HStack(spacing: 8) {
                    Image(systemName: icon)
                    Text(title)
                }
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(
                    Group {
                        if app.settings.theme == theme {
                            LinearGradient(colors: [.purple.opacity(0.2), .blue.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                        } else {
                        RoundedRectangle(cornerRadius: 14).fill(Color(UIColor.secondarySystemBackground))
                        }
                    }
                )
            .overlay(RoundedRectangle(cornerRadius: 14).stroke(app.settings.theme == theme ? Color.accentColor : Color(UIColor.separator), lineWidth: 1))
            }
            .foregroundColor(app.settings.theme == theme ? .accentColor : .primary)
        }
    }

