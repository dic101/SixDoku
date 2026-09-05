import SwiftUI
import SharedCore
import SharedServices

/// Horizontal bar: 1-6 + Erase. Dim disabled numbers, haptic on tap.
///
/// Assist gating: the valid-move highlight (given-cell colors) and the
/// invalid-key disabling only apply when `hintsEnabled` is on. With hints
/// off every key looks identical so the pad never gives away the answer.
public struct NumberPadView: View {
    var gridState: GridState
    var selectedCell: (row: Int, col: Int)?
    var format: FormatType
    var theme: AppTheme = .classic
    var hintsEnabled: Bool = false
    var onSelect: (Int?) -> Void

    public init(gridState: GridState, selectedCell: (row: Int, col: Int)?, format: FormatType, theme: AppTheme = .classic, hintsEnabled: Bool = false, onSelect: @escaping (Int?) -> Void) {
        self.gridState = gridState
        self.selectedCell = selectedCell
        self.format = format
        self.theme = theme
        self.hintsEnabled = hintsEnabled
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
                        // Highlighted (hints on + valid) wears the given-cell colors.
                        // Neutral keys wear editable-cell colors; disabled keys stay gray.
                        .background(buttonBackground(for: num))
                        .foregroundColor(buttonForeground(for: num))
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
                    .foregroundStyle(theme.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .accessibilityLabel("Erase entry")
            .accessibilityHint("Clears the selected cell")
        }
        .padding()
    }

    private func isDisabled(_ num: Int) -> Bool {
        guard let cell = selectedCell else { return true }
        // With hints off nothing is pre-disabled — the pad gives away nothing.
        guard hintsEnabled else { return false }
        return !Validator.isValidMove(grid: gridState, row: cell.row, col: cell.col, symbol: num, format: format) && gridState[cell.row, cell.col] != num
    }

    /// Valid keys only light up when hints are on.
    private func isHighlighted(_ num: Int) -> Bool {
        hintsEnabled && !isDisabled(num)
    }

    private func buttonBackground(for num: Int) -> Color {
        if isDisabled(num) { return Color.gray.opacity(0.3) }
        if isHighlighted(num) { return theme.clueBackground }
        return theme.cellBackground
    }

    private func buttonForeground(for num: Int) -> Color {
        if isDisabled(num) { return .gray }
        if isHighlighted(num) { return theme.clueForeground }
        return theme.entryForeground
    }
}
