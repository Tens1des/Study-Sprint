import SwiftUI

struct StatisticsView: View {
    @EnvironmentObject var app: AppState
    @State private var selectedTagId: UUID? = nil

    private var totalSessions: Int { app.sessions.count }
    private var focusRate: Int {
        let answered = app.sessions.compactMap { $0.reflectionFocused }
        guard !answered.isEmpty else { return 0 }
        let positive = answered.filter { $0 }.count
        return Int(round(Double(positive) / Double(answered.count) * 100))
    }

    private var last7Days: [(day: String, count: Int)] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        return (0..<7).reversed().map { offset in
            let date = cal.date(byAdding: .day, value: -offset, to: today)!
            let count = app.sessions.filter { cal.isDate($0.startedAt, inSameDayAs: date) }.count
            return (day: shortWeekday(for: date), count: count)
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Statistics").font(.largeTitle.bold())
                Text("Track your progress").foregroundColor(.secondary)

                HStack(spacing: 16) {
                    statTile(title: "Total", value: "\(totalSessions)", color: Color.purple)
                    statTile(title: "Focus", value: "\(focusRate)%", color: Color.green)
                }

                GroupBox { daysChart }
                    .groupBoxStyle(.automatic)
                    .overlay(alignment: .topLeading) { boxHeader("Activity by day") }

                GroupBox {
                    VStack(alignment: .leading, spacing: 12) {
                        filterChips
                        sessionList
                    }
                    .padding(.top, 18)
                }
                .overlay(alignment: .topLeading) { boxHeader("Sessions") }
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
        .toolbar {
            Button("Clear") { withAnimation { app.sessions.removeAll(); app.save() } }
        }
    }

    // MARK: - Components
    private func statTile(title: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(value).font(.title.bold()).foregroundColor(.white)
            Text(title).font(.caption).foregroundColor(.white.opacity(0.9))
        }
        .frame(maxWidth: .infinity)
        .padding(18)
        .background(RoundedRectangle(cornerRadius: 20).fill(color.gradient))
        .shadow(color: color.opacity(0.25), radius: 10, x: 0, y: 8)
    }

    private var daysChart: some View {
        HStack(alignment: .bottom, spacing: 12) {
            let maxVal = max(1, last7Days.map { $0.count }.max() ?? 1)
            ForEach(Array(last7Days.enumerated()), id: \.offset) { _, item in
                VStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.accentColor.opacity(0.9))
                        .frame(width: 22, height: CGFloat(item.count) / CGFloat(maxVal) * 120)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: app.sessions.count)
                    Text(item.day).font(.caption2).foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: 160)
        .padding(.top, 20)
    }

    private var fullHistory: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(app.sessions) { s in
                HStack {
                    Circle().fill((s.reflectionFocused ?? false) ? Color.green : Color.orange).frame(width: 10, height: 10)
                    VStack(alignment: .leading) {
                        let tagName = app.tags.first(where: { $0.id == s.tagId })?.name ?? "Subject"
                        Text(tagName).font(.subheadline.weight(.semibold))
                        Text(dateTimeFormatter.string(from: s.startedAt)).font(.caption).foregroundColor(.secondary)
                    }
                    Spacer()
                    Text("\(s.focusDurationSec/60) min").foregroundColor(.secondary)
                }
                .padding(12)
                .background(RoundedRectangle(cornerRadius: 14).fill(Color.white))
            }
        }
        .padding(.top, 8)
    }

    private func boxHeader(_ title: String) -> some View {
        Text(title).font(.headline).padding(.horizontal, 12).padding(.top, 10)
    }

    private func shortWeekday(for date: Date) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "E"
        return String(f.string(from: date).prefix(2))
    }

    private var dateTimeFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f
    }

    // MARK: - Sessions + Filter
    private var filteredSessions: [StudySession] {
        guard let tagId = selectedTagId else { return app.sessions }
        return app.sessions.filter { $0.tagId == tagId }
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                chip(title: "All", isSelected: selectedTagId == nil) { selectedTagId = nil }
                ForEach(app.tags) { tag in
                    chip(title: tag.name, isSelected: selectedTagId == tag.id) { selectedTagId = tag.id }
                }
            }
            .padding(.horizontal, 4)
        }
    }

    private func chip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(RoundedRectangle(cornerRadius: 14).fill(isSelected ? Color.accentColor.opacity(0.15) : Color.white))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(isSelected ? Color.accentColor : Color.gray.opacity(0.2)))
        }
        .foregroundColor(isSelected ? .accentColor : .primary)
    }

    private var sessionList: some View {
        VStack(spacing: 8) {
            if filteredSessions.isEmpty {
                Text("No history")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 24)
            } else {
                ForEach(filteredSessions) { s in
                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(dateTimeFormatter.string(from: s.startedAt)).font(.subheadline)
                            let tagName = app.tags.first(where: { $0.id == s.tagId })?.name ?? "Subject"
                            Text(tagName).font(.caption).foregroundColor(.secondary)
                        }
                        Spacer()
                        Text("\(s.focusDurationSec/60) min").font(.subheadline).foregroundColor(.primary)
                    }
                    .padding(12)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
                }
            }
        }
    }
}


