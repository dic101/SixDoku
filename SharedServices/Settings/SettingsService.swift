import Foundation
import SharedCore

/// Manages format + theme + hints preferences. Theme/hints sync via UserStats (CloudKit).
public final class SettingsService: @unchecked Sendable {
    private let defaults: UserDefaults
    private let formatKey = "sixdoku.formatPreference"
    private let themeKey = "sixdoku.themePreference"
    private let hintsKey = "sixdoku.hintsEnabled"

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    public var formatPreference: FormatType {
        get {
            guard let raw = defaults.string(forKey: formatKey),
                  let format = FormatType(rawValue: raw) else {
                return .twoByThree
            }
            return format
        }
        set {
            defaults.set(newValue.rawValue, forKey: formatKey)
        }
    }

    public var themePreference: AppTheme {
        get { themePreference(defaultingTo: .classic) }
        set {
            defaults.set(newValue.rawValue, forKey: themeKey)
        }
    }

    /// Theme lookup with an explicit fallback. Unknown stored values (e.g. a
    /// retired theme) resolve to `defaultTheme` — watch passes a dark theme
    /// so it never falls back to Classic's white page.
    public func themePreference(defaultingTo defaultTheme: AppTheme) -> AppTheme {
        guard let raw = defaults.string(forKey: themeKey),
              let theme = AppTheme(rawValue: raw) else {
            return defaultTheme
        }
        return theme
    }

    /// Hints toggle. Defaults to off when never set.
    public var hintsEnabled: Bool {
        get {
            guard defaults.object(forKey: hintsKey) != nil else { return false }
            return defaults.bool(forKey: hintsKey)
        }
        set {
            defaults.set(newValue, forKey: hintsKey)
        }
    }
}
