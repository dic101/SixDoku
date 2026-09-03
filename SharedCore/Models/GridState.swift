import Foundation

/// Current puzzle grid. 36 entries, nil = empty. Row-major order.
public struct GridState: Codable, Equatable, Sendable {
    public var cells: [Int?]

    /// Creates an empty grid or with provided cells.
    /// - Parameter cells: 36 entries. Defaults to empty.
    public init(cells: [Int?] = Array(repeating: nil, count: 36)) {
        guard cells.count == 36 else {
            self.cells = Array(repeating: nil, count: 36)
            return
        }
        self.cells = cells
    }

    /// Convenience from non-optional array (0 = empty).
    public init(from ints: [Int]) {
        guard ints.count == 36 else {
            self.cells = Array(repeating: nil, count: 36)
            return
        }
        self.cells = ints.map { $0 == 0 ? nil : $0 }
    }

    /// Row-major subscript.
    public subscript(row: Int, col: Int) -> Int? {
        get {
            guard row >= 0, row < 6, col >= 0, col < 6 else { return nil }
            return cells[row * 6 + col]
        }
        set {
            guard row >= 0, row < 6, col >= 0, col < 6 else { return }
            cells[row * 6 + col] = newValue
        }
    }

    /// Returns true if no cells are empty.
    public var isFull: Bool {
        !cells.contains(where: { $0 == nil })
    }

    /// Number of filled cells (clues).
    public var clueCount: Int {
        cells.filter { $0 != nil }.count
    }

    /// Non-optional representation (0 for empty) for CloudKit/storage.
    public var asIntArray: [Int] {
        cells.map { $0 ?? 0 }
    }
}
