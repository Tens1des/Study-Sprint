import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject var app: AppState

    var progresses: [AchievementProgress] {
        AchievementsEngine.evaluate(for: app)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Achievements").font(.largeTitle.bold())
                Text("Your learning milestones").foregroundColor(.secondary)

                ForEach(progresses) { p in
                    HStack(alignment: .center, spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 18)
                                .fill(LinearGradient(colors: gradient(for: p.id), startPoint: .topLeading, endPoint: .bottomTrailing))
                            Image(systemName: p.icon)
                                .foregroundColor(.white)
                                .font(.title2)
                        }
                        .frame(width: 68, height: 68)
                        .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.white.opacity(0.15)))

                        VStack(alignment: .leading, spacing: 6) {
                            Text(p.title).font(.headline)
                            Text(p.description).font(.caption).foregroundColor(.secondary)
                            if let _ = p.unlockedAt {
                                Label("Unlocked", systemImage: "checkmark.seal.fill")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            } else {
                                ProgressView(value: Double(p.current), total: Double(p.target))
                                Text("\(p.current)/\(p.target)").font(.caption).foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                        Image(systemName: "chevron.right").foregroundColor(.secondary)
                    }
                    .padding(16)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 22).fill(Color(UIColor.secondarySystemBackground))
                            if p.unlockedAt != nil {
                                RoundedRectangle(cornerRadius: 22).stroke(LinearGradient(colors: gradient(for: p.id), startPoint: .leading, endPoint: .trailing), lineWidth: 1.5)
                            }
                        }
                    )
                    .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 6)
                }
            }
            .padding(20)
        }
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - Styling helpers
extension AchievementsView {
    func gradient(for id: String) -> [Color] {
        switch id {
        case AchievementId.firstSession.rawValue: return [.orange, .yellow]
        case AchievementId.fiveSessions.rawValue: return [.pink, .orange]
        case AchievementId.tenPositiveReflections.rawValue: return [.green, .mint]
        case AchievementId.sevenDayStreak.rawValue: return [.purple, .blue]
        case AchievementId.twentySessionStreak.rawValue: return [.indigo, .blue]
        case AchievementId.mathGenius.rawValue: return [.teal, .blue]
        case AchievementId.languageTraveler.rawValue: return [.cyan, .green]
        case AchievementId.customizedDurations.rawValue: return [.brown, .orange]
        case AchievementId.themeChanged.rawValue: return [.purple, .pink]
        case AchievementId.threeTagsUsed.rawValue: return [.mint, .teal]
        case AchievementId.weeklyProgress25.rawValue: return [.blue, .indigo]
        case AchievementId.thirtyReflections.rawValue: return [.pink, .purple]
        case AchievementId.breakMaster.rawValue: return [.yellow, .orange]
        case AchievementId.profileSet.rawValue: return [.gray, .blue]
        case AchievementId.hundredSessions.rawValue: return [.black, .gray]
        default: return [.blue, .purple]
        }
    }
}


