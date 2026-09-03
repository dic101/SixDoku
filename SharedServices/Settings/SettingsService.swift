import Foundation
import SharedCore

/// Manages format preference (MVP). Theme/symbol stubs for future.
public final class SettingsService: @unchecked Sendable {
    private let defaults: UserDefaults
    private let formatKey = "sixdoku.formatPreference"

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
}
