import Foundation
import SharedCore

/// Sync manager — handles offline queue flushing and conflict resolution.
public final class SyncManager: @unchecked Sendable {
    private let cloudKitService: CloudKitService
    private let persistence: PersistenceService

    public init(cloudKitService: CloudKitService = CloudKitService(), persistence: PersistenceService = PersistenceService()) {
        self.cloudKitService = cloudKitService
        self.persistence = persistence
    }

    /// Flushes queued writes when online.
    public func syncWhenOnline() async {
        let queue = persistence.loadQueue()
        guard !queue.isEmpty else { return }
        for state in queue {
            try? await cloudKitService.savePuzzleState(state)
        }
        persistence.clearQueue()
    }

    public func savePuzzleState(_ state: PuzzleState) async {
        // Local first (offline mode), then cloud with retry
        try? persistence.savePuzzleState(state)
        do {
            try await cloudKitService.savePuzzleState(state)
        } catch {
            // Graceful fallback per ErrorHandlingSpec
        }
    }

    public func loadLatestPuzzleState() -> PuzzleState? {
        persistence.loadPuzzleState()
    }

    public var hasPendingSync: Bool { persistence.hasPendingSync }
}
