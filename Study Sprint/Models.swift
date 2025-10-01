import Foundation
import SwiftUI

enum Theme: String, Codable, CaseIterable, Identifiable {
    case light
    case dark
    var id: String { rawValue }
}

struct Tag: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var iconSystemName: String
    var colorHex: String
    var isDefault: Bool = false
    var preferredFocusSec: Int? = nil
    var preferredBreakSec: Int? = nil
}

enum SessionPhase: String, Codable {
    case focus
    case breakTime
}

struct StudySession: Identifiable, Codable {
    var id: UUID = UUID()
    var tagId: UUID?
    var startedAt: Date
    var focusDurationSec: Int
    var breakDurationSec: Int
    var phaseCompleted: SessionPhase
    var reflectionFocused: Bool?
}

struct UserProfile: Codable {
    var name: String
    var avatarSystemName: String
}

struct AppSettings: Codable {
    var languageCode: String
    var theme: Theme
    var textScale: Double
    var defaultFocusSec: Int
    var defaultBreakSec: Int
}

struct Achievement: Identifiable, Codable {
    var id: String
    var title: String
    var description: String
    var unlockedAt: Date?
}

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        guard Scanner(string: hexSanitized).scanHexInt64(&int) else { return nil }
        let a, r, g, b: UInt64
        switch hexSanitized.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        self = Color(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}


