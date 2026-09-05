import Foundation
import SharedCore

/// Local persistence via UserDefaults/AppStorage. Offline queue for CloudKit.
public final class PersistenceService: @unchecked Sendable {
    private let userDefaults: UserDefaults
    private let puzzleStateKey = "sixdoku.puzzleState"
    private let statsKey = "sixdoku.userStats"
    private let queueKey = "sixdoku.cloudQueue"
    private let catalogKey = "sixdoku.catalogCache"
    private let catalogDateKey = "sixdoku.catalogCacheDate"
    private let completedIDsKey = "sixdoku.completedPuzzleIDs"

    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    // MARK: - PuzzleState

    /// Saves puzzle state locally.
    public func savePuzzleState(_ state: PuzzleState) throws {
        let data = try JSONEncoder().encode(state)
        userDefaults.set(data, forKey: puzzleStateKey)
    }

    /// Loads latest puzzle state.
    public func loadPuzzleState() -> PuzzleState? {
        guard let data = userDefaults.data(forKey: puzzleStateKey) else { return nil }
        return try? JSONDecoder().decode(PuzzleState.self, from: data)
    }

    // MARK: - UserStats

    public func saveUserStats(_ stats: UserStats) throws {
        let data = try JSONEncoder().encode(stats)
        userDefaults.set(data, forKey: statsKey)
    }

    public func loadUserStats() -> UserStats? {
        guard let data = userDefaults.data(forKey: statsKey) else { return nil }
        return try? JSONDecoder().decode(UserStats.self, from: data)
    }

    // MARK: - Catalog Cache

    public func saveCatalogCache(_ puzzles: [PuzzleDefinition]) throws {
        let data = try JSONEncoder().encode(puzzles)
        userDefaults.set(data, forKey: catalogKey)
        userDefaults.set(Date(), forKey: catalogDateKey)
    }

    public func loadCatalogCache() -> [PuzzleDefinition]? {
        guard let data = userDefaults.data(forKey: catalogKey) else { return nil }
        return try? JSONDecoder().decode([PuzzleDefinition].self, from: data)
    }

    /// Whether cache is stale (>24h).
    public func isCatalogStale() -> Bool {
        guard let date = userDefaults.object(forKey: catalogDateKey) as? Date else { return true }
        return Date().timeIntervalSince(date) > 24 * 3600
    }

    // MARK: - Queue for offline CloudKit writes

    public func queueForSync(_ state: PuzzleState) {
        var queue = loadQueue()
        queue.append(state)
        if let data = try? JSONEncoder().encode(queue) {
            userDefaults.set(data, forKey: queueKey)
        }
    }

    public func loadQueue() -> [PuzzleState] {
        guard let data = userDefaults.data(forKey: queueKey) else { return [] }
        return (try? JSONDecoder().decode([PuzzleState].self, from: data)) ?? []
    }

    public func clearQueue() {
        userDefaults.removeObject(forKey: queueKey)
    }

    public var hasPendingSync: Bool { !loadQueue().isEmpty }

    // MARK: - Completed puzzle IDs (Library markers)

    /// Records a puzzle as completed (idempotent set).
    public func markPuzzleCompleted(_ puzzleID: String) {
        var ids = loadCompletedIDs()
        ids.insert(puzzleID)
        if let data = try? JSONEncoder().encode(Array(ids)) {
            userDefaults.set(data, forKey: completedIDsKey)
        }
    }

    public func isPuzzleCompleted(_ puzzleID: String) -> Bool {
        loadCompletedIDs().contains(puzzleID)
    }

    public func loadCompletedIDs() -> Set<String> {
        // Merge explicit set + latest state + queued states so markers
        // survive even if the set write was missed on an older build.
        var ids = Set<String>()
        if let data = userDefaults.data(forKey: completedIDsKey),
           let stored = try? JSONDecoder().decode([String].self, from: data) {
            ids.formUnion(stored)
        }
        if let latest = loadPuzzleState(), latest.isCompleted {
            ids.insert(latest.puzzleID)
        }
        for queued in loadQueue() where queued.isCompleted {
            ids.insert(queued.puzzleID)
        }
        return ids
    }
}
