import Foundation

/// User stats per `CloudKitSchema.md.md:25` private DB `UserStats`.
public struct UserStats: Codable, Equatable, Sendable {
    public var completedCount: Int
    public var formatUsage: [String: Int] // FormatType.rawValue -> count
    public var bestTimes: [String: Int] // e.g., "2x3_easy" -> seconds
    public var streakDays: Int
    public var lastPlayed: Date?
    public var themePreference: String?
    public var symbolSetPreference: String?
    /// Nil (missing on old records) means disabled.
    public var hintsEnabled: Bool?
    /// Lifetime hints consumed. Nil (missing on old records) means zero —
    /// kept optional (like `hintsEnabled`) because this toolchain's synthesized
    /// `Decodable` throws `keyNotFound` on missing non-optional keys, which
    /// would wipe pre-existing cached stats on first launch after update.
    public var hintsUsed: Int?

    public init(
        completedCount: Int = 0,
        formatUsage: [String: Int] = [:],
        bestTimes: [String: Int] = [:],
        streakDays: Int = 0,
        lastPlayed: Date? = nil,
        themePreference: String? = nil,
        symbolSetPreference: String? = nil,
        hintsEnabled: Bool? = nil,
        hintsUsed: Int? = nil
    ) {
        self.completedCount = completedCount
        self.formatUsage = formatUsage
        self.bestTimes = bestTimes
        self.streakDays = streakDays
        self.lastPlayed = lastPlayed
        self.themePreference = themePreference
        self.symbolSetPreference = symbolSetPreference
        self.hintsEnabled = hintsEnabled
        self.hintsUsed = hintsUsed
    }

    /// Effective hints flag — old stats without the key default to disabled.
    public var hintsOn: Bool { hintsEnabled ?? false }

    /// Effective hints count — old stats without the key default to zero.
    public var totalHintsUsed: Int { hintsUsed ?? 0 }

    public mutating func recordHintUsed() {
        hintsUsed = totalHintsUsed + 1
    }

    public mutating func recordCompletion(format: FormatType, difficulty: Difficulty, seconds: Int? = nil) {
        completedCount += 1
        formatUsage[format.rawValue, default: 0] += 1
        // Streak logic per DailyPuzzleSystem could be added later
        lastPlayed = Date()
        if let seconds {
            let key = "\(format.rawValue)_\(difficulty.rawValue)"
            if let existing = bestTimes[key] {
                bestTimes[key] = min(existing, seconds)
            } else {
                bestTimes[key] = seconds
            }
        }
    }
}
