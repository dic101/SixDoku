import Foundation

/// Puzzle difficulty tier.
public enum Difficulty: String, CaseIterable, Codable, Sendable {
    case easy
    case medium
    case hard

    /// Target clue count range for the difficulty.
    /// Format B (3x2) requires +1-2 clues — handled in Generator.
    public var clueRange: ClosedRange<Int> {
        switch self {
        case .easy: return 14...18
        case .medium: return 12...14
        case .hard: return 10...12
        }
    }
}
