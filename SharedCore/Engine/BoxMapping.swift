import Foundation

/// Box mapping for 6x6 formats.
public enum BoxMapping {
    /// Returns box index 0-5 for a given cell.
    public static func boxIndex(for format: FormatType, row: Int, col: Int) -> Int {
        switch format {
        case .twoByThree:
            // 2 rows x 3 cols: 3 boxes across (col/3) per band, 3 bands (row/2)
            // Boxes: 0,1 on top band, 2,3 middle, 4,5 bottom
            let band = row / 2
            let stack = col / 3
            return band * 2 + stack
        case .threeByTwo:
            // 3 rows x 2 cols: 3 stacks (col/2) per band, 2 bands (row/3)
            // Boxes: 0,1,2 top, 3,4,5 bottom
            let band = row / 3
            let stack = col / 2
            return band * 3 + stack
        }
    }

    /// All cells belonging to a box.
    public static func cells(for format: FormatType, box: Int) -> [(row: Int, col: Int)] {
        var result: [(Int, Int)] = []
        for r in 0..<6 {
            for c in 0..<6 where boxIndex(for: format, row: r, col: c) == box {
                result.append((r, c))
            }
        }
        return result
    }
}
