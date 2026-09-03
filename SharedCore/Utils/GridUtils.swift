import Foundation

/// Grid conversion utilities.
public enum GridUtils {
    /// Converts optional array to int array (0 = empty).
    public static func toIntArray(_ cells: [Int?]) -> [Int] {
        cells.map { $0 ?? 0 }
    }

    /// Converts int array (0 = empty) to optional.
    public static func toOptional(_ ints: [Int]) -> [Int?] {
        ints.map { $0 == 0 ? nil : $0 }
    }
}
