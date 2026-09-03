import SwiftUI
import SharedCore
import SharedServices

public struct PuzzleView: View {
    @StateObject private var viewModel: PuzzleViewModel
    public init(puzzle: PuzzleDefinition) {
        _viewModel = StateObject(wrappedValue: PuzzleViewModel(puzzleDefinition: puzzle))
    }
    public init(state: PuzzleState, solution: [Int]) {
        _viewModel = StateObject(wrappedValue: PuzzleViewModel(puzzleState: state, solutionGrid: solution))
    }

    public var body: some View {
        VStack {
            SyncStatusBanner(message: viewModel.syncStatus)
                .animation(.easeInOut, value: viewModel.syncStatus)
            SudokuGridView(gridState: $viewModel.gridState, selectedCell: $viewModel.selectedCell, format: viewModel.format) { row, col in
                viewModel.selectedCell = (row, col)
            }
            .padding()

            NumberPadView(gridState: viewModel.gridState, selectedCell: viewModel.selectedCell, format: viewModel.format) { symbol in
                guard let cell = viewModel.selectedCell else { return }
                viewModel.applyMove(row: cell.row, col: cell.col, symbol: symbol)
            }

            if viewModel.isCompleted {
                Text("Completed! 🎉")
                    .font(.title2)
                    .transition(.scale)
            }
        }
        .navigationTitle("\(viewModel.format.rawValue) • \(viewModel.puzzleID.prefix(4))")
        .navigationBarTitleDisplayMode(.inline)
    }
}
