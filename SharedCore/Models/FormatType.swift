import Foundation

/// Region layout for 6x6 Sudoku.
public enum FormatType: String, CaseIterable, Codable, Sendable {
    /// 2 rows x 3 columns per box (default)
    case twoByThree = "2x3"
    /// 3 rows x 2 columns per box
    case threeByTwo = "3x2"

    /// Box dimensions for this format.
    public var boxRows: Int {
        switch self {
        case .twoByThree: return 2
        case .threeByTwo: return 3
        }
    }

    public var boxCols: Int {
        switch self {
        case .twoByThree: return 3
        case .threeByTwo: return 2
        }
    }
}
