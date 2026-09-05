import Foundation
import SharedCore
import SharedServices

@MainActor
public final class WatchPuzzleViewModel: ObservableObject {
    @Published public var gridState: GridState
    @Published public var selectedCell: (row: Int, col: Int)?
    @Published public var pickerPresented = false
    @Published public var isCompleted = false
    @Published public var format: FormatType
    private var puzzleID: String
    private var initialClues: [Int?]
    private var solutionGrid: [Int]
    private let syncManager: SyncManager

    public init(puzzle: PuzzleDefinition, syncManager: SyncManager = SyncManager()) {
        self.puzzleID = puzzle.puzzleID
        self.format = puzzle.format
        self.initialClues = puzzle.initialClues
        self.solutionGrid = puzzle.solutionGrid
        self.gridState = GridState(cells: puzzle.initialClues)
        self.syncManager = syncManager
    }

    /// Tap a cell: highlight it; open the number picker only for editable cells.
    public func selectCell(row: Int, col: Int) {
        selectedCell = (row, col)
        pickerPresented = initialClues[row * 6 + col] == nil
    }

    public func isClue(row: Int, col: Int) -> Bool {
        initialClues[row * 6 + col] != nil
    }

    public func selectedValue() -> Int? {
        guard let cell = selectedCell else { return nil }
        return gridState[cell.row, cell.col]
    }

    public func isValidMove(_ symbol: Int) -> Bool {
        guard let cell = selectedCell else { return false }
        if gridState[cell.row, cell.col] == symbol { return true }
        return Validator.isValidMove(grid: gridState, row: cell.row, col: cell.col, symbol: symbol, format: format)
    }

    /// Applies a move, returning false when a placed symbol is invalid.
    /// Callers use the result for feedback (e.g. picker stays open + haptic).
    @discardableResult
    public func applyMove(row: Int, col: Int, symbol: Int?) -> Bool {
        guard initialClues[row*6+col] == nil else { return false }
        if let symbol {
            guard Validator.isValidMove(grid: gridState, row: row, col: col, symbol: symbol, format: format) else {
                HapticsService.error()
                return false
            }
            gridState[row, col] = symbol
        } else {
            gridState[row, col] = nil
        }
        if Validator.isComplete(grid: gridState) && Validator.isSolved(grid: gridState, solution: solutionGrid) {
            isCompleted = true
            PersistenceService().markPuzzleCompleted(puzzleID)
        }
        saveState()
        return true
    }

    private func saveState() {
        let state = PuzzleState(puzzleID: puzzleID, format: format, gridState: gridState, initialClues: initialClues, isCompleted: isCompleted, lastUpdated: Date())
        Task { await syncManager.savePuzzleState(state) }
    }
}
