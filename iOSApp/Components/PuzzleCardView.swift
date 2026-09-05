import SwiftUI
import SharedCore

public struct PuzzleCardView: View {
    var puzzle: PuzzleDefinition
    var isCompleted: Bool = false
    public init(puzzle: PuzzleDefinition, isCompleted: Bool = false) {
        self.puzzle = puzzle
        self.isCompleted = isCompleted
    }
    public var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(puzzle.format.rawValue).font(.caption)
                Text(puzzle.difficulty.rawValue.capitalized).font(.headline)
                Text("\(puzzle.initialClues.filter { $0 != nil }.count) clues").font(.caption2)
            }
            Spacer()
            if isCompleted {
                Label("Completed", systemImage: "checkmark.seal.fill")
                    .font(.caption.bold())
                    .foregroundStyle(.green)
                    .labelStyle(.iconOnly)
                    .accessibilityLabel("Completed")
            }
        }
        .padding(8)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color.gray.opacity(0.1)))
    }
}
