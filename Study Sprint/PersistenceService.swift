import Foundation

final class PersistenceService {
    static let shared = PersistenceService()
    private init() {}

    private let queue = DispatchQueue(label: "storage.queue", qos: .utility)

    private var url: URL {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return dir.appendingPathComponent("study_sprint.json")
    }

    struct Snapshot: Codable {
        var tags: [Tag]
        var sessions: [StudySession]
        var settings: AppSettings
        var profile: UserProfile
        var achievements: [Achievement]
    }

    func loadOrBootstrap() -> Snapshot {
        if let data = try? Data(contentsOf: url), let snap = try? JSONDecoder().decode(Snapshot.self, from: data) {
            return snap
        }
        // bootstrap defaults
        let defaultTag = Tag(name: "General", iconSystemName: "book.fill", colorHex: "6C5CE7", isDefault: true)
        let settings = AppSettings(languageCode: "en", theme: .light, textScale: 1.0, defaultFocusSec: 25*60, defaultBreakSec: 5*60)
        let profile = UserProfile(name: "Student", avatarSystemName: "person.crop.circle.fill")
        let achievements: [Achievement] = []
        return Snapshot(tags: [defaultTag], sessions: [], settings: settings, profile: profile, achievements: achievements)
    }

    func save(_ snapshot: Snapshot) {
        queue.async {
            do {
                let data = try JSONEncoder().encode(snapshot)
                try data.write(to: self.url, options: [.atomic])
            } catch {
                print("Storage save error: \(error)")
            }
        }
    }
}


