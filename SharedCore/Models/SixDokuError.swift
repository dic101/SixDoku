import Foundation

/// Domain errors for SixDoku.
public enum SixDokuError: Error, LocalizedError, Equatable, Sendable {
    case invalidGrid
    case unsolvablePuzzle
    case nonUniquePuzzle
    case invalidMove
    case clueCellBlocked
    case cloudKitUnavailable
    case cloudKitPermissionDenied
    case cloudKitConflict
    case cloudKitSerializationFailed
    case networkUnavailable

    public var errorDescription: String? {
        switch self {
        case .invalidGrid: return "Invalid grid state."
        case .unsolvablePuzzle: return "Puzzle has no solution."
        case .nonUniquePuzzle: return "Puzzle does not have a unique solution."
        case .invalidMove: return "Move violates Sudoku constraints."
        case .clueCellBlocked: return "Cannot modify clue cells."
        case .cloudKitUnavailable: return "CloudKit unavailable."
        case .cloudKitPermissionDenied: return "CloudKit permission denied."
        case .cloudKitConflict: return "Record conflict."
        case .cloudKitSerializationFailed: return "Serialization failed."
        case .networkUnavailable: return "Network unavailable."
        }
    }
}
