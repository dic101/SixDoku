import Foundation
import SharedCore
import SharedServices

@MainActor
public final class StatsViewModel: ObservableObject {
    @Published public var completedCount: Int = 0
    @Published public var formatUsage: [FormatType: Int] = [:]
    @Published public var streakDays: Int = 0
    @Published public var lastPlayed: Date?
    @Published public var hintsUsed: Int = 0
    @Published public var isSyncing = false

    private let cloudKitService: CloudKitService
    private let persistence: PersistenceService
    private var userStats: UserStats = UserStats()

    public init(cloudKitService: CloudKitService = CloudKitService(), persistence: PersistenceService = PersistenceService()) {
        self.cloudKitService = cloudKitService
        self.persistence = persistence
    }

    public func load() {
        isSyncing = true
        Task {
            if let local = persistence.loadUserStats() {
                apply(local)
            }
            do {
                if let remote = try await cloudKitService.fetchUserStats() {
                    // Timestamp merge: prefer remote if newer
                    let merged = merge(local: persistence.loadUserStats(), remote: remote)
                    try? persistence.saveUserStats(merged)
                    apply(merged)
                }
            } catch {
                // Offline: keep local
            }
            isSyncing = false
        }
    }

    public func recordCompletion(format: FormatType, difficulty: Difficulty, seconds: Int? = nil) {
        // Check streak: if lastPlayed was yesterday increment, else reset if missed per DailyPuzzleSystem
        var newStats = userStats
        let now = Date()
        if let last = userStats.lastPlayed, Calendar.current.isDate(last, inSameDayAs: now) {
            // same day, keep streak
        } else if let last = userStats.lastPlayed, Calendar.current.date(byAdding: .day, value: 1, to: last).map({ Calendar.current.isDate($0, inSameDayAs: now) }) == true {
            newStats.streakDays += 1
        } else if userStats.lastPlayed == nil {
            newStats.streakDays = 1
        } else {
            // Missed a day
            newStats.streakDays = 1
        }
        newStats.recordCompletion(format: format, difficulty: difficulty, seconds: seconds)
        userStats = newStats
        try? persistence.saveUserStats(newStats)
        apply(newStats)
        Task { try? await cloudKitService.saveUserStats(newStats) }
    }

    public func recordHintUsage() {
        // Load-modify-save against persistence (not the in-memory copy, which
        // may be stale if load() was never called on this instance).
        var newStats = persistence.loadUserStats() ?? userStats
        newStats.recordHintUsed()
        userStats = newStats
        try? persistence.saveUserStats(newStats)
        apply(newStats)
        Task { try? await cloudKitService.saveUserStats(newStats) }
    }

    private func apply(_ stats: UserStats) {
        userStats = stats
        completedCount = stats.completedCount
        // Map string keys to FormatType
        var mapped: [FormatType: Int] = [:]
        for (k, v) in stats.formatUsage { if let f = FormatType(rawValue: k) { mapped[f] = v } }
        formatUsage = mapped
        streakDays = stats.streakDays
        lastPlayed = stats.lastPlayed
        hintsUsed = stats.totalHintsUsed
    }

    private func merge(local: UserStats?, remote: UserStats) -> UserStats {
        guard let local else { return remote }
        // Prefer remote if lastPlayed newer
        if let rDate = remote.lastPlayed, let lDate = local.lastPlayed, rDate > lDate {
            return remote
        }
        if local.lastPlayed == nil { return remote }
        if remote.lastPlayed == nil { return local }
        return (remote.lastPlayed ?? .distantPast) > (local.lastPlayed ?? .distantPast) ? remote : local
    }
}
