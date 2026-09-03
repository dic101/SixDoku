import Foundation

/// Generates valid, unique 6x6 puzzles.
public enum Generator {
    /// Generates a full valid 6x6 solution grid.
    public static func generateSolution(format: FormatType) -> [Int] {
        // Start from empty and solve with randomized search
        let empty = GridState()
        if let solution = Solver.solve(grid: empty, format: format) {
            return solution
        }
        // Fallback — should not happen
        return [
            1,2,3,4,5,6,
            4,5,6,1,2,3,
            2,3,1,5,6,4,
            5,6,4,2,3,1,
            3,1,2,6,4,5,
            6,4,5,3,1,2
        ]
    }

    /// Creates a puzzle with initial clues, solution, difficulty, unique solution.
    public static func generatePuzzle(format: FormatType, difficulty: Difficulty) -> PuzzleDefinition {
        let solution = generateSolution(format: format)
        var clues: [Int?] = solution.map { $0 }

        // Determine target clues: random within range, +1-2 for 3x2
        var targetRange = difficulty.clueRange
        if format == .threeByTwo {
            // Shift range up by 1 (per spec +1-2 clues)
            targetRange = (targetRange.lowerBound + 1)...(targetRange.upperBound + 2)
        }
        let targetClues = Int.random(in: targetRange)

        // Remove clues while preserving uniqueness
        let indices = Randomization.shuffledIndices()
        for idx in indices {
            let remaining = clues.filter { $0 != nil }.count
            if remaining <= targetClues { break }

            let saved = clues[idx]
            clues[idx] = nil
            let testGrid = GridState(cells: clues)
            if !Solver.isUnique(grid: testGrid, format: format) {
                clues[idx] = saved // revert if breaks uniqueness
            }
        }

        return PuzzleDefinition(
            puzzleID: UUID().uuidString,
            format: format,
            difficulty: difficulty,
            initialClues: clues,
            solutionGrid: solution
        )
    }

    /// Removes clues to reach target — used internally.
    public static func removeClues(solution: [Int], format: FormatType, targetClues: Int) -> [Int?] {
        var clues: [Int?] = solution.map { $0 }
        let indices = Randomization.shuffledIndices()
        for idx in indices {
            if clues.filter({ $0 != nil }).count <= targetClues { break }
            let saved = clues[idx]
            clues[idx] = nil
            if !Solver.isUnique(grid: GridState(cells: clues), format: format) {
                clues[idx] = saved
            }
        }
        return clues
    }
}
