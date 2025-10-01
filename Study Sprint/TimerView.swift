import SwiftUI

struct TimerView: View {
    @EnvironmentObject var app: AppState
    @State private var isRunning = false
    @State private var isFocusPhase = true
    @State private var remaining: Int = 0
    @State private var selectedTagId: UUID?
    @State private var showReflection = false

    private var activeTag: Tag? {
        if let id = selectedTagId { return app.tags.first(where: { $0.id == id }) }
        return app.tags.first(where: { $0.isDefault })
    }
    private var total: Int {
        if isFocusPhase {
            return activeTag?.preferredFocusSec ?? app.settings.defaultFocusSec
        } else {
            return activeTag?.preferredBreakSec ?? app.settings.defaultBreakSec
        }
    }
    private var progress: Double { total == 0 ? 0 : 1 - Double(remaining) / Double(total) }

    var body: some View {
        ZStack {
            Color(.systemGroupedBackground).ignoresSafeArea()
            VStack(spacing: 28) {
                headerTagPill
                    .padding(.top, 8)

                ZStack {
                    Circle()
                        .stroke(Color.black.opacity(0.06), lineWidth: 16)
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(isFocusPhase ? Color.accentColor : .green, style: StrokeStyle(lineWidth: 16, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.25), value: progress)
                    VStack(spacing: 8) {
                        Text(timeString(remaining))
                            .font(.system(size: 52, weight: .bold))
                            .foregroundColor(Color.primary.opacity(0.9))
                        Text(isFocusPhase ? "focus on study" : "break time")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(height: 300)

                HStack(spacing: 16) {
                    Button(action: toggle) {
                        HStack(spacing: 10) {
                            Image(systemName: isRunning ? "pause.fill" : "play.fill")
                            Text(isRunning ? "Pause" : "Start")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(colors: [Color.purple, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing)
                                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        )
                        .shadow(color: Color.purple.opacity(0.35), radius: 14, x: 0, y: 10)
                    }

                    Button(action: { resetPhase(focus: isFocusPhase) }) {
                        Image(systemName: "arrow.clockwise")
                            .font(.title3)
                            .foregroundColor(.primary)
                            .frame(width: 64, height: 64)
                            .background(RoundedRectangle(cornerRadius: 18).fill(Color.white))
                            .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 6)
                    }
                }
                .padding(.bottom, 12)
            }
            .padding(.horizontal, 20)
        }
        .onAppear { resetPhase(focus: true) }
        .onChange(of: selectedTagId) { _ in
            // reset remaining according to newly selected subject and current phase
            resetPhase(focus: isFocusPhase)
        }
        .onChange(of: app.tags) { _ in
            // keep in sync if tags updated (e.g., preferred durations changed)
            resetPhase(focus: isFocusPhase)
        }
        .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
            guard isRunning, remaining > 0 else { return }
            remaining -= 1
            if remaining == 0 { phaseCompleted() }
        }
        .sheet(isPresented: $showReflection) {
            ReflectionSheet { focused in
                saveSession(reflection: focused)
                // start break automatically
                resetPhase(focus: false)
                isRunning = true
            }
        }
    }

    private var headerTagPill: some View {
        let tag = app.tags.first(where: { $0.id == (selectedTagId ?? app.tags.first(where: { $0.isDefault })?.id) })
        return Menu {
            ForEach(app.tags) { t in
                Button(t.name) { selectedTagId = t.id }
            }
        } label: {
            HStack(alignment: .center, spacing: 10) {
                Image(systemName: "books.vertical.fill").foregroundColor(.accentColor)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Study session").font(.caption).foregroundColor(.secondary)
                    Text(tag?.name ?? "Tag").font(.headline.weight(.semibold)).foregroundColor(.primary)
                }
                Spacer(minLength: 6)
                Image(systemName: "chevron.down").foregroundColor(.secondary)
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(Color(UIColor.secondarySystemBackground))
                    .shadow(color: Color.black.opacity(0.06), radius: 12, x: 0, y: 6)
            )
        }
    }

    private func toggle() { isRunning.toggle() }

    private func resetPhase(focus: Bool) {
        isFocusPhase = focus
        remaining = focus ? (activeTag?.preferredFocusSec ?? app.settings.defaultFocusSec) : (activeTag?.preferredBreakSec ?? app.settings.defaultBreakSec)
    }

    private func phaseCompleted() {
        if isFocusPhase {
            showReflection = true
        } else {
            // break finished → go to focus
            resetPhase(focus: true)
            isRunning = false
        }
    }

    private func saveSession(reflection: Bool) {
        let session = StudySession(
            tagId: selectedTagId ?? app.tags.first(where: { $0.isDefault })?.id,
            startedAt: Date(),
            focusDurationSec: activeTag?.preferredFocusSec ?? app.settings.defaultFocusSec,
            breakDurationSec: activeTag?.preferredBreakSec ?? app.settings.defaultBreakSec,
            phaseCompleted: .focus,
            reflectionFocused: reflection
        )
        app.sessions.insert(session, at: 0)
        app.save()
    }

    private func timeString(_ seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}

struct ReflectionSheet: View {
    var onAnswer: (Bool) -> Void
    var body: some View {
        VStack(spacing: 20) {
            Text("Were you focused?")
                .font(.title2.bold())
            HStack(spacing: 16) {
                Button { onAnswer(true) } label: {
                    Text("Yes").frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                Button { onAnswer(false) } label: {
                    Text("No").frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal)
        }
        .presentationDetents([.height(220)])
        .padding()
    }
}


