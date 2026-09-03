import Foundation

/// Validates moves and completion per Sudoku constraints.
public enum Validator {
    /// Checks row, column, and box constraints.
    public static func isValidMove(
        grid: GridState,
        row: Int,
        col: Int,
        symbol: Int,
        format: FormatType
    ) -> Bool {
        guard row >= 0, row < 6, col >= 0, col < 6 else { return false }
        guard symbol >= 1, symbol <= 6 else { return false }

        // Row check
        for c in 0..<6 where c != col {
            if grid[row, c] == symbol { return false }
        }
        // Column check
        for r in 0..<6 where r != row {
            if grid[r, col] == symbol { return false }
        }
        // Box check
        let targetBox = BoxMapping.boxIndex(for: format, row: row, col: col)
        for r in 0..<6 {
            for c in 0..<6 {
                guard !(r == row && c == col) else { continue }
                if BoxMapping.boxIndex(for: format, row: r, col: c) == targetBox,
                   grid[r, c] == symbol {
                    return false
                }
            }
        }
        return true
    }

    /// Returns true if no cells are empty.
    public static func isComplete(grid: GridState) -> Bool {
        grid.isFull
    }

    /// Checks if grid matches solution.
    public static func isSolved(grid: GridState, solution: [Int]) -> Bool {
        guard solution.count == 36 else { return false }
        for i in 0..<36 {
            guard let val = grid.cells[i], val == solution[i] else { return false }
        }
        return true
    }

    /// Validates that a filled grid obeys all constraints.
    public static func isValidGrid(grid: GridState, format: FormatType) -> Bool {
        for r in 0..<6 {
            for c in 0..<6 {
                guard let symbol = grid[r, c] else { continue }
                // Temporarily clear cell to avoid self-collision
                var copy = grid
                copy[r, c] = nil
                if !isValidMove(grid: copy, row: r, col: c, symbol: symbol, format: format) {
                    return false
                }
            }
        }
        return true
    }
}
