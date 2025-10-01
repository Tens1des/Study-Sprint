import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var app: AppState

    var body: some View {
        NavigationStack {
            List {
                ForEach(app.sessions) { s in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(dateFormatter.string(from: s.startedAt)).font(.subheadline)
                        HStack {
                            Text("Focus: \(s.focusDurationSec/60)m · Break: \(s.breakDurationSec/60)m")
                            Spacer()
                            if let ok = s.reflectionFocused {
                                Text(ok ? "Focused" : "Distracted").foregroundColor(ok ? .green : .orange)
                            }
                        }
                    }
                }
            }
            .navigationTitle("History")
            .toolbar {
                Button("Clear") { app.sessions.removeAll(); app.save() }
            }
        }
    }

    private var dateFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }
}


