import Foundation
import SharedCore
import SharedServices

@MainActor
public final class WatchPuzzleViewModel: ObservableObject {
    @Published public var gridState: GridState
    @Published public var selectedCell: (row: Int, col: Int)?
    @Published public var isCompleted = false
    @Published public var format: FormatType
    private var initialClues: [Int?]
    private var solutionGrid: [Int]
    private let syncManager: SyncManager

    public init(puzzle: PuzzleDefinition, syncManager: SyncManager = SyncManager()) {
        self.format = puzzle.format
        self.initialClues = puzzle.initialClues
        self.solutionGrid = puzzle.solutionGrid
        self.gridState = GridState(cells: puzzle.initialClues)
        self.syncManager = syncManager
    }

    public func applyMove(row: Int, col: Int, symbol: Int?) {
        guard initialClues[row*6+col] == nil else { return }
        if let symbol {
            guard Validator.isValidMove(grid: gridState, row: row, col: col, symbol: symbol, format: format) else {
                // watchOS subtle haptic
                return
            }
            gridState[row, col] = symbol
        } else {
            gridState[row, col] = nil
        }
        if Validator.isComplete(grid: gridState) && Validator.isSolved(grid: gridState, solution: solutionGrid) {
            isCompleted = true
        }
        saveState()
    }

    private func saveState() {
        let state = PuzzleState(puzzleID: UUID().uuidString, format: format, gridState: gridState, initialClues: initialClues, isCompleted: isCompleted, lastUpdated: Date())
        Task { await syncManager.savePuzzleState(state) }
    }
}
