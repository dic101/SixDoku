import SwiftUI
import SharedCore

public struct PuzzleCardView: View {
    var puzzle: PuzzleDefinition
    public init(puzzle: PuzzleDefinition) { self.puzzle = puzzle }
    public var body: some View {
        VStack(alignment: .leading) {
            Text(puzzle.format.rawValue).font(.caption)
            Text(puzzle.difficulty.rawValue.capitalized).font(.headline)
            Text("\(puzzle.initialClues.filter { $0 != nil }.count) clues").font(.caption2)
        }
        .padding(8)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color.gray.opacity(0.1)))
    }
}
