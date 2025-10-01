import Foundation

struct AchievementProgress: Identifiable {
    let id: String
    let title: String
    let description: String
    let icon: String
    let target: Int
    let current: Int
    let unlockedAt: Date?
}

enum AchievementId: String, CaseIterable {
    case firstSession
    case fiveSessions
    case tenPositiveReflections
    case sevenDayStreak
    case twentySessionStreak
    case mathGenius
    case languageTraveler
    case customizedDurations
    case themeChanged
    case threeTagsUsed
    case weeklyProgress25
    case thirtyReflections
    case breakMaster
    case profileSet
    case hundredSessions
}

struct AchievementsEngine {
    static func catalog() -> [AchievementId: (title: String, description: String, icon: String, target: Int)] {
        return [
            .firstSession: ("First step", "Complete your first study session.", "star.fill", 1),
            .fiveSessions: ("Productivity start", "Finish 5 study sessions.", "target", 5),
            .tenPositiveReflections: ("Focus master", "Answer 'Yes' 10 times.", "bolt.fill", 10),
            .sevenDayStreak: ("First week", "Study 7 days in a row.", "calendar", 7),
            .twentySessionStreak: ("Marathon", "Finish 20 sessions in a row.", "figure.run", 20),
            .mathGenius: ("Math genius", "Complete 10 sessions for Math.", "function", 10),
            .languageTraveler: ("Language traveler", "10 sessions for English or other language.", "globe", 10),
            .customizedDurations: ("Flexible learner", "Customize focus/break durations.", "slider.horizontal.3", 1),
            .themeChanged: ("Color tuner", "Change the app theme once.", "paintpalette.fill", 1),
            .threeTagsUsed: ("True explorer", "Use at least 3 different subjects.", "magnifyingglass", 3),
            .weeklyProgress25: ("Weekly progress", "25 sessions in a week.", "chart.bar.fill", 25),
            .thirtyReflections: ("Mini-reflectionist", "Answer reflection 30 times.", "brain.head.profile", 30),
            .breakMaster: ("Break master", "Finish 10 full cycles with a break.", "timer", 10),
            .profileSet: ("Personal profile", "Set your name or avatar.", "person.crop.circle", 1),
            .hundredSessions: ("Long-term progress", "Complete 100 sessions.", "infinity", 100)
        ]
    }

    static func evaluate(for app: AppState) -> [AchievementProgress] {
        let cat = catalog()
        let total = app.sessions.count
        let positive = app.sessions.compactMap { $0.reflectionFocused }.filter { $0 }.count
        let answered = app.sessions.compactMap { $0.reflectionFocused }.count
        let byTag = Dictionary(grouping: app.sessions, by: { $0.tagId ?? UUID() }).mapValues { $0.count }
        let distinctTagsUsed = app.sessions.compactMap { $0.tagId }.uniqued().count

        // day streak
        let streakDays = longestDailyStreak(app.sessions)

        // session streak (within 2h gaps)
        let sessionStreak = longestSessionStreak(app.sessions)

        // math / language names
        let mathTagIds = app.tags.filter { $0.name.lowercased().contains("math") }.map { $0.id }
        let languageTagIds = app.tags.filter { $0.name.lowercased().contains("english") || $0.name.lowercased().contains("language") }.map { $0.id }
        let mathCount = app.sessions.filter { s in mathTagIds.contains(where: { $0 == s.tagId }) }.count
        let languageCount = app.sessions.filter { s in languageTagIds.contains(where: { $0 == s.tagId }) }.count

        // weekly progress
        let cal = Calendar.current
        let weekAgo = cal.date(byAdding: .day, value: -7, to: Date())!
        let weekCount = app.sessions.filter { $0.startedAt >= weekAgo }.count

        // cycles with break
        let breakCycles = app.sessions.filter { $0.breakDurationSec > 0 }.count

        // customized durations
        let customized = app.settings.defaultFocusSec != 25*60 || app.settings.defaultBreakSec != 5*60 || app.tags.contains { $0.preferredFocusSec != nil || $0.preferredBreakSec != nil }

        // theme change
        let themeChanged = app.settings.theme != .light

        let profileSet = app.profile.name != "Student"

        var values: [AchievementId: Int] = [:]
        values[.firstSession] = total
        values[.fiveSessions] = total
        values[.tenPositiveReflections] = positive
        values[.sevenDayStreak] = streakDays
        values[.twentySessionStreak] = sessionStreak
        values[.mathGenius] = mathCount
        values[.languageTraveler] = languageCount
        values[.customizedDurations] = customized ? 1 : 0
        values[.themeChanged] = themeChanged ? 1 : 0
        values[.threeTagsUsed] = distinctTagsUsed
        values[.weeklyProgress25] = weekCount
        values[.thirtyReflections] = answered
        values[.breakMaster] = breakCycles
        values[.profileSet] = profileSet ? 1 : 0
        values[.hundredSessions] = total

        return AchievementId.allCases.map { id in
            let meta = cat[id]!
            let current = values[id] ?? 0
            let unlocked = current >= meta.target
            let unlockedDate = app.achievements.first(where: { $0.id == id.rawValue })?.unlockedAt
            return AchievementProgress(id: id.rawValue, title: meta.title, description: meta.description, icon: meta.icon, target: meta.target, current: min(current, meta.target), unlockedAt: unlocked ? (unlockedDate ?? Date()) : nil)
        }
    }

    private static func longestDailyStreak(_ sessions: [StudySession]) -> Int {
        let cal = Calendar.current
        let days = Set(sessions.map { cal.startOfDay(for: $0.startedAt) })
        let sorted = days.sorted()
        var best = 0, cur = 0
        var prev: Date?
        for day in sorted {
            if let p = prev, let nextDay = cal.date(byAdding: .day, value: 1, to: p), cal.isDate(day, inSameDayAs: nextDay) {
                cur += 1
            } else { cur = 1 }
            best = max(best, cur)
            prev = day
        }
        return best
    }

    private static func longestSessionStreak(_ sessions: [StudySession]) -> Int {
        let sorted = sessions.sorted { $0.startedAt < $1.startedAt }
        var best = 0, cur = 0
        var prev: Date?
        for s in sorted {
            if let p = prev, s.startedAt.timeIntervalSince(p) <= 2 * 60 * 60 { // within 2 hours
                cur += 1
            } else { cur = 1 }
            best = max(best, cur)
            prev = s.startedAt
        }
        return best
    }
}

extension Array where Element: Hashable {
    func uniqued() -> [Element] {
        var s: Set<Element> = []
        return filter { s.insert($0).inserted }
    }
}


