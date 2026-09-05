import SwiftUI
import SharedCore
import SharedServices

public struct PuzzleView: View {
    @StateObject private var viewModel: PuzzleViewModel
    @StateObject private var themes = ThemeManager()
    @StateObject private var hints = HintsManager()
    @State private var hintMessage: String?
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
            SudokuGridView(
                gridState: $viewModel.gridState,
                selectedCell: $viewModel.selectedCell,
                format: viewModel.format,
                accent: themes.theme.accent,
                theme: themes.theme,
                isClue: { viewModel.isClue(row: $0, col: $1) }
            ) { row, col in
                viewModel.selectedCell = (row, col)
            }
            .padding()

            NumberPadView(
                gridState: viewModel.gridState,
                selectedCell: viewModel.selectedCell,
                format: viewModel.format,
                theme: themes.theme
            ) { symbol in
                guard let cell = viewModel.selectedCell else { return }
                viewModel.applyMove(row: cell.row, col: cell.col, symbol: symbol)
                if let symbol {
                    announce("Placed \(symbol) in Row \(cell.row+1) Column \(cell.col+1)")
                } else {
                    announce("Cleared Row \(cell.row+1) Column \(cell.col+1)")
                }
            }

            if viewModel.isCompleted {
                Text("Completed! 🎉")
                    .font(.title2)
                    .transition(.scale)
                    .accessibilityLabel("Puzzle completed")
                    .onAppear { announce("Puzzle completed") }
            } else if let hintMessage {
                Text(hintMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .transition(.opacity)
            }
        }
        .background(themes.theme.pageBackground)
        .navigationTitle("\(viewModel.format.rawValue) • \(viewModel.puzzleID.prefix(4))")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if hints.isEnabled {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        if let hint = viewModel.requestHint() {
                            hintMessage = nil
                            announce("Hint placed \(hint.symbol) in Row \(hint.row+1) Column \(hint.col+1)")
                        } else {
                            hintMessage = "No hints available"
                            announce("No hints available")
                        }
                    } label: {
                        Image(systemName: "lightbulb")
                    }
                    .accessibilityLabel("Get hint")
                    .accessibilityHint("Fills a logically deducible cell")
                }
            }
        }
        .task {
            await themes.refreshFromCloud()
            await hints.refreshFromCloud()
        }
    }

    private func announce(_ message: String) {
        AccessibilityNotification.Announcement(message).post()
    }
}
