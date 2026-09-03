import SwiftUI
import SharedCore

/// Grid fills screen, compact picker pinned bottom, no scroll.
public struct WatchPuzzleView: View {
    @StateObject private var viewModel: WatchPuzzleViewModel
    public init(puzzle: PuzzleDefinition) {
        _viewModel = StateObject(wrappedValue: WatchPuzzleViewModel(puzzle: puzzle))
    }
    public var body: some View {
        VStack(spacing: 0) {
            // Grid fills screen
            VStack(spacing: 1) {
                ForEach(0..<6, id: \.self) { row in
                    HStack(spacing: 1) {
                        ForEach(0..<6, id: \.self) { col in
                            let sel = viewModel.selectedCell?.row == row && viewModel.selectedCell?.col == col
                            let val = viewModel.gridState[row, col]
                            ZStack {
                                Rectangle().fill(sel ? Color.blue.opacity(0.4) : Color.white)
                                if let val { Text("\(val)").font(.caption2) }
                            }
                            .onTapGesture { viewModel.selectedCell = (row, col) }
                        }
                    }
                }
            }
            .aspectRatio(1, contentMode: .fit)

            // Compact picker auto-dismiss after selection
            if let cell = viewModel.selectedCell {
                HStack(spacing: 2) {
                    ForEach(1...6, id: \.self) { n in
                        Button("\(n)") {
                            viewModel.applyMove(row: cell.row, col: cell.col, symbol: n)
                            viewModel.selectedCell = nil
                        }
                        .buttonStyle(.plain)
                        .font(.caption2)
                    }
                    Button("x") {
                        viewModel.applyMove(row: cell.row, col: cell.col, symbol: nil)
                        viewModel.selectedCell = nil
                    }
                }
                .padding(2)
            }

            if viewModel.isCompleted {
                Text("Done!").font(.caption).foregroundColor(.green)
            }
        }
    }
}
