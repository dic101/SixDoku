import Foundation
import Combine
import SharedCore
import SharedServices

/// PuzzleViewModel per ViewModelContracts.md
@MainActor
public final class PuzzleViewModel: ObservableObject {
    @Published public var gridState: GridState
    @Published public var selectedCell: (row: Int, col: Int)?
    @Published public var isCompleted: Bool = false
    @Published public var format: FormatType
    @Published public var puzzleID: String
    @Published public var syncStatus: String? // "Sync delayed" per ErrorHandlingSpec

    private var initialClues: [Int?]
    private var solutionGrid: [Int]
    private let syncManager: SyncManager
    private let settings: SettingsService

    public init(
        puzzleDefinition: PuzzleDefinition,
        syncManager: SyncManager = SyncManager(),
        settings: SettingsService = SettingsService()
    ) {
        self.puzzleID = puzzleDefinition.puzzleID
        self.format = puzzleDefinition.format
        self.initialClues = puzzleDefinition.initialClues
        self.solutionGrid = puzzleDefinition.solutionGrid
        self.gridState = GridState(cells: puzzleDefinition.initialClues)
        self.syncManager = syncManager
        self.settings = settings
    }

    public init(
        puzzleState: PuzzleState,
        solutionGrid: [Int],
        syncManager: SyncManager = SyncManager(),
        settings: SettingsService = SettingsService()
    ) {
        self.puzzleID = puzzleState.puzzleID
        self.format = puzzleState.format
        self.initialClues = puzzleState.initialClues
        self.solutionGrid = solutionGrid
        self.gridState = puzzleState.gridState
        self.syncManager = syncManager
        self.settings = settings
        self.isCompleted = puzzleState.isCompleted
    }

    /// Applies move with validation, haptics, stats, sync.
    public func applyMove(row: Int, col: Int, symbol: Int?) {
        guard !isClue(row: row, col: col) else { return }
        if let symbol {
            guard validateMove(row: row, col: col, symbol: symbol) else {
                HapticsService.error()
                return
            }
            gridState[row, col] = symbol
            HapticsService.lightTap()
        } else {
            gridState[row, col] = nil // Erase
        }
        checkCompletion()
        saveState()
    }

    public func validateMove(row: Int, col: Int, symbol: Int) -> Bool {
        Validator.isValidMove(grid: gridState, row: row, col: col, symbol: symbol, format: format)
    }

    /// Returns and applies a hint when hints are enabled, otherwise nil.
    /// Respects `SettingsService.hintsEnabled` (synced via iCloud).
    /// Each applied hint increments `UserStats.hintsUsed` per HintSystemSpec.
    @discardableResult
    public func requestHint() -> HintEngine.Hint? {
        guard settings.hintsEnabled else { return nil }
        guard let hint = HintEngine.hint(for: gridState, format: format, solution: solutionGrid) else {
            return nil
        }
        selectedCell = (hint.row, hint.col)
        applyMove(row: hint.row, col: hint.col, symbol: hint.symbol)
        StatsViewModel().recordHintUsage()
        return hint
    }

    public func checkCompletion() {
        guard Validator.isComplete(grid: gridState) else { return }
        if Validator.isSolved(grid: gridState, solution: solutionGrid) {
            isCompleted = true
            HapticsService.success()
            // Update UserStats per ViewModelContracts.md StatsViewModel
            let statsService = StatsViewModel()
            // Infer difficulty from clue count
            let clues = initialClues.filter { $0 != nil }.count
            let difficulty: Difficulty = clues >= 14 ? .easy : clues >= 12 ? .medium : .hard
            statsService.recordCompletion(format: format, difficulty: difficulty)
        }
    }

    public func saveState() {
        let state = PuzzleState(
            puzzleID: puzzleID,
            format: format,
            gridState: gridState,
            initialClues: initialClues,
            isCompleted: isCompleted,
            lastUpdated: Date()
        )
        Task {
            await syncManager.savePuzzleState(state)
            // Check queue for banner
            if syncManager.hasPendingSync {
                await MainActor.run { self.syncStatus = "Sync delayed" }
                try? await Task.sleep(nanoseconds: 3_000_000_000)
                await MainActor.run { self.syncStatus = nil }
            }
        }
    }

    public func loadState() -> PuzzleState? {
        syncManager.loadLatestPuzzleState()
    }

    public func isClue(row: Int, col: Int) -> Bool {
        guard row >= 0, row < 6, col >= 0, col < 6 else { return true }
        return initialClues[row * 6 + col] != nil
    }
}
