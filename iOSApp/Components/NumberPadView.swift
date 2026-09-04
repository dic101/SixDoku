import SwiftUI
import SharedCore
import SharedServices

/// Horizontal bar: 1-6 + Erase. Dim disabled numbers, haptic on tap.
public struct NumberPadView: View {
    var gridState: GridState
    var selectedCell: (row: Int, col: Int)?
    var format: FormatType
    var theme: AppTheme = .classic
    var onSelect: (Int?) -> Void

    public init(gridState: GridState, selectedCell: (row: Int, col: Int)?, format: FormatType, theme: AppTheme = .classic, onSelect: @escaping (Int?) -> Void) {
        self.gridState = gridState
        self.selectedCell = selectedCell
        self.format = format
        self.theme = theme
        self.onSelect = onSelect
    }

    public var body: some View {
        HStack(spacing: 8) {
            ForEach(1...6, id: \.self) { num in
                Button(action: {
                    HapticsService.lightTap()
                    onSelect(num)
                }) {
                    Text("\(num)")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(isDisabled(num) ? Color.gray.opacity(0.3) : theme.accent.opacity(0.2))
                        .foregroundColor(isDisabled(num) ? .gray : .primary)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .disabled(isDisabled(num))
                .accessibilityLabel("Place \(num)")
                .accessibilityHint(isDisabled(num) ? "Not allowed in selected cell" : "Places \(num) in selected cell")
            }
            Button(action: {
                HapticsService.lightTap()
                onSelect(nil)
            }) {
                Image(systemName: "delete.left")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.red.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .accessibilityLabel("Erase entry")
            .accessibilityHint("Clears the selected cell")
        }
        .padding()
    }

    private func isDisabled(_ num: Int) -> Bool {
        guard let cell = selectedCell else { return true }
        return !Validator.isValidMove(grid: gridState, row: cell.row, col: cell.col, symbol: num, format: format) && gridState[cell.row, cell.col] != num
    }
}
