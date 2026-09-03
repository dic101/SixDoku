import Foundation
import SharedCore
import SharedServices

@MainActor
public final class WatchHomeViewModel: ObservableObject {
    @Published public var latestPuzzle: PuzzleState?
    private let syncManager: SyncManager
    public init(syncManager: SyncManager = SyncManager()) {
        self.syncManager = syncManager
        self.latestPuzzle = syncManager.loadLatestPuzzleState()
    }
    public func newPuzzle(format: FormatType, difficulty: Difficulty) -> PuzzleDefinition {
        Generator.generatePuzzle(format: format, difficulty: difficulty)
    }
}
