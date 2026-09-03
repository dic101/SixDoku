import Foundation

/// Backtracking solver with uniqueness support.
public enum Solver {
    /// Finds a single valid solution. Returns nil if unsolvable.
    public static func solve(grid: GridState, format: FormatType) -> [Int]? {
        let solutions = findSolutions(grid: grid, format: format, maxSolutions: 1)
        return solutions.first
    }

    /// Returns true if puzzle has exactly one solution.
    public static func isUnique(grid: GridState, format: FormatType) -> Bool {
        findSolutions(grid: grid, format: format, maxSolutions: 2).count == 1
    }

    /// Returns up to maxSolutions solutions.
    public static func findSolutions(
        grid: GridState,
        format: FormatType,
        maxSolutions: Int
    ) -> [[Int]] {
        // Early exit if initial grid already invalid (e.g., duplicate in row/col/box)
        guard Validator.isValidGrid(grid: grid, format: format) else { return [] }
        var solutions: [[Int]] = []
        var working = grid.cells
        backtrack(cells: &working, format: format, solutions: &solutions, maxSolutions: maxSolutions)
        return solutions
    }

    // MARK: - Backtracking

    private static func backtrack(
        cells: inout [Int?],
        format: FormatType,
        solutions: inout [[Int]],
        maxSolutions: Int
    ) {
        if solutions.count >= maxSolutions { return }

        guard let idx = nextEmptyIndex(cells: cells) else {
            // No empty cells — found solution
            let solved = cells.map { $0 ?? 0 }
            // Validate full grid before counting
            let grid = GridState(cells: cells)
            guard Validator.isValidGrid(grid: grid, format: format) else { return }
            solutions.append(solved)
            return
        }

        let row = idx / 6
        let col = idx % 6
        let grid = GridState(cells: cells)

        for symbol in Randomization.shuffledSymbols() {
            if Validator.isValidMove(grid: grid, row: row, col: col, symbol: symbol, format: format) {
                cells[idx] = symbol
                backtrack(cells: &cells, format: format, solutions: &solutions, maxSolutions: maxSolutions)
                if solutions.count >= maxSolutions {
                    // Early exit optimization still needs to unwind, but we can stop exploring
                    cells[idx] = nil
                    return
                }
                cells[idx] = nil
            }
        }
    }

    private static func nextEmptyIndex(cells: [Int?]) -> Int? {
        // Simple: first empty. Could optimize with MRV heuristic.
        cells.firstIndex(where: { $0 == nil })
    }
}
