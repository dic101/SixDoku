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
}
