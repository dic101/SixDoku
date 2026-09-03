import Foundation
import Combine
import SharedCore
import SharedServices

@MainActor
public final class HomeViewModel: ObservableObject {
    @Published public var currentPuzzle: PuzzleState?
    @Published public var lastFormat: FormatType

    private let syncManager: SyncManager
    private let settings: SettingsService

    public init(syncManager: SyncManager = SyncManager(), settings: SettingsService = SettingsService()) {
        self.syncManager = syncManager
        self.settings = settings
        self.lastFormat = settings.formatPreference
        self.currentPuzzle = syncManager.loadLatestPuzzleState()
    }

    public func resumePuzzle() -> PuzzleState? {
        currentPuzzle
    }

    public func newPuzzle(format: FormatType, difficulty: Difficulty) -> PuzzleDefinition {
        let puzzle = Generator.generatePuzzle(format: format, difficulty: difficulty)
        settings.formatPreference = format
        lastFormat = format
        return puzzle
    }
}
