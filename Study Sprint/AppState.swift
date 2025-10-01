import Foundation
import Combine

final class AppState: ObservableObject {
    @Published var tags: [Tag]
    @Published var sessions: [StudySession]
    @Published var settings: AppSettings
    @Published var profile: UserProfile
    @Published var achievements: [Achievement]

    private let storage = PersistenceService.shared

    init() {
        let snap = storage.loadOrBootstrap()
        self.tags = snap.tags
        self.sessions = snap.sessions
        self.settings = snap.settings
        self.profile = snap.profile
        self.achievements = snap.achievements
    }

    func save() {
        let snap = PersistenceService.Snapshot(tags: tags, sessions: sessions, settings: settings, profile: profile, achievements: achievements)
        storage.save(snap)
    }
}


