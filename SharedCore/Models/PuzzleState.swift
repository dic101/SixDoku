import Foundation

/// User's active puzzle.
public struct PuzzleState: Codable, Equatable, Sendable, Identifiable {
    public var puzzleID: String
    public var format: FormatType
    public var gridState: GridState
    public var initialClues: [Int?]
    public var isCompleted: Bool
    public var lastUpdated: Date

    public var id: String { puzzleID }

    public init(
        puzzleID: String,
        format: FormatType,
        gridState: GridState,
        initialClues: [Int?],
        isCompleted: Bool = false,
        lastUpdated: Date = Date()
    ) {
        self.puzzleID = puzzleID
        self.format = format
        self.gridState = gridState
        self.initialClues = initialClues
        self.isCompleted = isCompleted
        self.lastUpdated = lastUpdated
    }

    /// Whether cell is a fixed clue (cannot be erased).
    public func isClue(row: Int, col: Int) -> Bool {
        guard row >= 0, row < 6, col >= 0, col < 6 else { return false }
        return initialClues[row * 6 + col] != nil
    }
}
