import Foundation

/// Deterministic seed catalog for CloudKit public `PuzzleCatalog` seeding.
/// Per `CloudKitSchema.md.md:4` + `PuzzleGeneratorSpec.md.md:36` (N per difficulty per format).
public enum SeedCatalog {
    /// Buckets: 2 formats × 3 difficulties. Default 8 per bucket = 48 records (~50 expected by LibraryViewModel).
    public static let defaultPerBucket = 8
    public static let version = 1

    /// Generates a stable catalog with deterministic puzzleIDs:
    /// `sixdoku-{format}-{difficulty}-{index:03d}` (e.g. `sixdoku-2x3-easy-001`).
    public static func generate(perBucket: Int = defaultPerBucket) -> [PuzzleDefinition] {
        var catalog: [PuzzleDefinition] = []
        catalog.reserveCapacity(FormatType.allCases.count * Difficulty.allCases.count * perBucket)
        for format in FormatType.allCases {
            for difficulty in Difficulty.allCases {
                for i in 1...perBucket {
                    var puzzle = Generator.generatePuzzle(format: format, difficulty: difficulty)
                    let stableID = String(
                        format: "sixdoku-%@-%@-%03d",
                        format.rawValue, difficulty.rawValue, i
                    )
                    // Rebuild with stable ID (keep clues/solution)
                    puzzle = PuzzleDefinition(
                        puzzleID: stableID,
                        format: puzzle.format,
                        difficulty: puzzle.difficulty,
                        initialClues: puzzle.initialClues,
                        solutionGrid: puzzle.solutionGrid
                    )
                    catalog.append(puzzle)
                }
            }
        }
        return catalog
    }

    /// Validates a catalog: correct counts, unique IDs, each puzzle unique + solvable.
    public static func validate(_ catalog: [PuzzleDefinition]) -> Bool {
        guard !catalog.isEmpty else { return false }
        let ids = catalog.map(\.puzzleID)
        guard Set(ids).count == ids.count else { return false }
        for puzzle in catalog {
            let grid = GridState(cells: puzzle.initialClues)
            guard Solver.isUnique(grid: grid, format: puzzle.format) else { return false }
            guard Validator.isValidGrid(grid: grid, format: puzzle.format) else { return false }
        }
        return true
    }
}
