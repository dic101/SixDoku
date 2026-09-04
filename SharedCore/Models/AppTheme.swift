import Foundation
import SwiftUI

/// Readability-first grid themes. Selected in iOS Settings, synced to watch
/// via `UserStats.themePreference` (CloudKit private DB).
public enum AppTheme: String, CaseIterable, Codable, Sendable {
    case classic
    case midnight
    case highContrast
    case volt
    case ember
    case cobalt

    public var displayName: String {
        switch self {
        case .classic: return "Classic"
        case .midnight: return "Midnight"
        case .highContrast: return "High Contrast"
        case .volt: return "Volt"
        case .ember: return "Ember"
        case .cobalt: return "Cobalt"
        }
    }

    public var description: String {
        switch self {
        case .classic: return "Black givens, blue entries"
        case .midnight: return "Dark grid for night and sun"
        case .highContrast: return "Max contrast, color-blind safe"
        case .volt: return "Yellow tiles on black"
        case .ember: return "Red tiles on black"
        case .cobalt: return "Blue tiles on black"
        }
    }

    /// Page background behind the grid.
    public var pageBackground: Color {
        switch self {
        case .classic: return .white
        case .midnight: return Color(red: 0.05, green: 0.05, blue: 0.07)
        case .highContrast: return .white
        case .volt, .ember, .cobalt: return .black
        }
    }

    /// Background of editable (non-given) cells.
    public var cellBackground: Color {
        switch self {
        case .classic: return .white
        case .midnight: return Color(red: 0.14, green: 0.14, blue: 0.17)
        case .highContrast: return .white
        case .volt, .ember, .cobalt: return Color(red: 0.12, green: 0.12, blue: 0.13)
        }
    }

    /// Background of prepopulated (given) cells.
    public var clueBackground: Color {
        switch self {
        case .classic: return .black
        case .midnight: return .white
        case .highContrast: return .yellow
        case .volt: return .yellow
        case .ember: return Color(red: 0.85, green: 0.15, blue: 0.15)
        case .cobalt: return Color(red: 0.15, green: 0.35, blue: 1.0)
        }
    }

    /// Digit color inside given cells.
    public var clueForeground: Color {
        switch self {
        case .classic: return .white
        case .midnight: return .black
        case .highContrast: return .black
        case .volt: return .black
        case .ember: return .white
        case .cobalt: return .white
        }
    }

    /// Digit color for player entries.
    public var entryForeground: Color {
        switch self {
        case .classic: return .blue
        case .midnight: return .yellow
        case .highContrast: return .black
        case .volt, .ember, .cobalt: return .white
        }
    }

    /// Selection highlight + picker accents.
    public var accent: Color {
        switch self {
        case .classic: return .blue
        case .midnight: return .cyan
        case .highContrast: return .orange
        case .volt: return .yellow
        case .ember: return Color(red: 1.0, green: 0.3, blue: 0.2)
        case .cobalt: return .cyan
        }
    }
}
