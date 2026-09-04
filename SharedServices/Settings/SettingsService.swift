import Foundation
import SharedCore

/// Manages format + theme preferences. Theme syncs via UserStats (CloudKit).
public final class SettingsService: @unchecked Sendable {
    private let defaults: UserDefaults
    private let formatKey = "sixdoku.formatPreference"
    private let themeKey = "sixdoku.themePreference"

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
        get {
            guard let raw = defaults.string(forKey: themeKey),
                  let theme = AppTheme(rawValue: raw) else {
                return .classic
            }
            return theme
        }
        set {
            defaults.set(newValue.rawValue, forKey: themeKey)
        }
    }
}
