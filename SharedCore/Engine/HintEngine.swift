import Foundation

/// Hint engine — MVP returns logically deducible single forced cell if available.
public enum HintEngine {
    public struct Hint: Sendable {
        public let row: Int
        public let col: Int
        public let symbol: Int
    }

    /// Returns a hint using solution grid if available, otherwise solver logic.
    public static func hint(for grid: GridState, format: FormatType, solution: [Int]? = nil) -> Hint? {
        // Prefer solution grid if provided (still validates move is logical)
        if let solution {
            for idx in 0..<36 where grid.cells[idx] == nil {
                let row = idx / 6
                let col = idx % 6
                let symbol = solution[idx]
                // Only return if it's the valid move
                if Validator.isValidMove(grid: grid, row: row, col: col, symbol: symbol, format: format) {
                    // Check if it's forced (only one valid symbol) or at least valid
                    // MVP: return first empty that matches solution
                    return Hint(row: row, col: col, symbol: symbol)
                }
            }
            return nil
        }

        // Without solution, find first cell with single candidate
        for idx in 0..<36 where grid.cells[idx] == nil {
            let row = idx / 6
            let col = idx % 6
            var candidates: [Int] = []
            for sym in 1...6 where Validator.isValidMove(grid: grid, row: row, col: col, symbol: sym, format: format) {
                candidates.append(sym)
            }
            if candidates.count == 1, let sym = candidates.first {
                return Hint(row: row, col: col, symbol: sym)
            }
        }
        return nil
    }
}
