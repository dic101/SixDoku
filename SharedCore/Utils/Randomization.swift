import Foundation

/// Randomization helpers.
public enum Randomization {
    /// Shuffled symbols 1-6.
    public static func shuffledSymbols() -> [Int] {
        Array(1...6).shuffled()
    }

    /// Shuffled cell indices 0-35.
    public static func shuffledIndices() -> [Int] {
        Array(0..<36).shuffled()
    }
}
