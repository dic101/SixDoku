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

    public init(
        completedCount: Int = 0,
        formatUsage: [String: Int] = [:],
        bestTimes: [String: Int] = [:],
        streakDays: Int = 0,
        lastPlayed: Date? = nil,
        themePreference: String? = nil,
        symbolSetPreference: String? = nil
    ) {
        self.completedCount = completedCount
        self.formatUsage = formatUsage
        self.bestTimes = bestTimes
        self.streakDays = streakDays
        self.lastPlayed = lastPlayed
        self.themePreference = themePreference
        self.symbolSetPreference = symbolSetPreference
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
