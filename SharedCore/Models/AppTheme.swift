import Foundation
import SwiftUI

/// Readability-first grid themes. Selected in iOS Settings, synced to watch
/// via `UserStats.themePreference` (CloudKit private DB).
public enum AppTheme: String, CaseIterable, Codable, Sendable {
    case classic
    case volt
    case ember
    case cobalt

    public var displayName: String {
        switch self {
        case .classic: return "Classic"
        case .volt: return "Volt"
        case .ember: return "Ember"
        case .cobalt: return "Cobalt"
        }
    }

    public var description: String {
        switch self {
        case .classic: return "Black givens, blue entries"
        case .volt: return "Yellow tiles on black"
        case .ember: return "Red tiles on black"
        case .cobalt: return "Blue tiles on black"
        }
    }

    /// Page background behind the grid.
    public var pageBackground: Color {
        switch self {
        case .classic: return .white
        case .volt, .ember, .cobalt: return .black
        }
    }

    /// Background of editable (non-given) cells.
    public var cellBackground: Color {
        switch self {
        case .classic: return .white
        case .volt, .ember, .cobalt: return Color(red: 0.12, green: 0.12, blue: 0.13)
        }
    }

    /// Background of prepopulated (given) cells.
    public var clueBackground: Color {
        switch self {
        case .classic: return .black
        case .volt: return .yellow
        case .ember: return Color(red: 0.85, green: 0.15, blue: 0.15)
        case .cobalt: return Color(red: 0.15, green: 0.35, blue: 1.0)
        }
    }

    /// Digit color inside given cells.
    public var clueForeground: Color {
        switch self {
        case .classic: return .white
        case .volt: return .black
        case .ember: return .white
        case .cobalt: return .white
        }
    }

    /// Digit color for player entries.
    public var entryForeground: Color {
        switch self {
        case .classic: return .blue
        case .volt, .ember, .cobalt: return .white
        }
    }

    /// Selection highlight + picker accents.
    public var accent: Color {
        switch self {
        case .classic: return .blue
        case .volt: return .yellow
        case .ember: return Color(red: 1.0, green: 0.3, blue: 0.2)
        case .cobalt: return .cyan
        }
    }
}
