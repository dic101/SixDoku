import Foundation

/// Static puzzle definition from catalog.
public struct PuzzleDefinition: Codable, Equatable, Hashable, Sendable, Identifiable {
    public let puzzleID: String
    public let format: FormatType
    public let difficulty: Difficulty
    public let initialClues: [Int?]
    public let solutionGrid: [Int]

    public var id: String { puzzleID }

    public init(
        puzzleID: String,
        format: FormatType,
        difficulty: Difficulty,
        initialClues: [Int?],
        solutionGrid: [Int]
    ) {
        self.puzzleID = puzzleID
        self.format = format
        self.difficulty = difficulty
        self.initialClues = initialClues
        self.solutionGrid = solutionGrid
    }

    /// Initial clues as GridState.
    public var initialGrid: GridState {
        GridState(cells: initialClues)
    }
}
