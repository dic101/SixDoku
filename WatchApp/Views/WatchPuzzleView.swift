import SwiftUI
import SharedCore
import SharedServices

/// Grid fills screen; tapping an editable cell pushes a big-number picker page.
public struct WatchPuzzleView: View {
    @StateObject private var viewModel: WatchPuzzleViewModel
    @StateObject private var themes = ThemeManager(defaultTheme: .volt)
    @StateObject private var hints = HintsManager()
    public init(puzzle: PuzzleDefinition) {
        _viewModel = StateObject(wrappedValue: WatchPuzzleViewModel(puzzle: puzzle))
    }
    public var body: some View {
        let theme = themes.theme
        VStack(spacing: 0) {
            // Grid fills screen
            VStack(spacing: 1) {
                ForEach(0..<6, id: \.self) { row in
                    HStack(spacing: 1) {
                        ForEach(0..<6, id: \.self) { col in
                            let sel = viewModel.selectedCell?.row == row && viewModel.selectedCell?.col == col
                            let val = viewModel.gridState[row, col]
                            let clue = viewModel.isClue(row: row, col: col)
                            ZStack {
                                Rectangle()
                                    .fill(sel ? theme.accent.opacity(0.45) : clue ? theme.clueBackground : theme.cellBackground)
                                if let val {
                                    Text("\(val)")
                                        .font(.system(size: 17, weight: clue ? .bold : .semibold, design: .rounded))
                                        .foregroundStyle(clue ? theme.clueForeground : theme.entryForeground)
                                }
                                if sel {
                                    RoundedRectangle(cornerRadius: 2)
                                        .stroke(theme.accent, lineWidth: 2)
                                }
                            }
                            .accessibilityElement(children: .ignore)
                            .accessibilityLabel("Row \(row+1) Column \(col+1), \(val.map { String($0) } ?? "empty")")
                            .accessibilityAddTraits(sel ? [.isButton, .isSelected] : .isButton)
                            .onTapGesture { viewModel.selectCell(row: row, col: col) }
                            .padding(.trailing, colGap(col))
                        }
                    }
                    .padding(.bottom, rowGap(row))
                }
            }
            .aspectRatio(1, contentMode: .fit)

            if viewModel.isCompleted {
                VStack(spacing: 4) {
                    Image(systemName: "party.popper.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(theme.accent)
                    Text("Solved!")
                        .font(.title3.bold())
                        .foregroundColor(.green)
                }
                .padding(.top, 4)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Puzzle completed")
            } else if viewModel.selectedCell != nil {
                Text("Tap a cell to pick a number")
                    .font(.caption2).foregroundStyle(.secondary)
            }
        }
        .background(theme.pageBackground)
        .navigationDestination(isPresented: $viewModel.pickerPresented) {
            WatchNumberPickerView(viewModel: viewModel)
                .environmentObject(themes)
                .environmentObject(hints)
        }
        .task {
            themes.refreshFromLocal()
            hints.refreshFromLocal()
            await themes.refreshFromCloud()
            await hints.refreshFromCloud()
        }
    }

    /// Extra gap after each box band so 2×3 / 3×2 regions are visible.
    private func rowGap(_ row: Int) -> CGFloat {
        (row + 1) % viewModel.format.boxRows == 0 && row < 5 ? 4 : 0
    }

    private func colGap(_ col: Int) -> CGFloat {
        (col + 1) % viewModel.format.boxCols == 0 && col < 5 ? 4 : 0
    }
}
