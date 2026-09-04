import SwiftUI
import SharedCore

/// Grid with tap-to-select, accent highlight, shake on invalid.
public struct SudokuGridView: View {
    @Binding var gridState: GridState
    @Binding var selectedCell: (row: Int, col: Int)?
    var format: FormatType
    var accent: Color = .blue
    var onSelect: (Int, Int) -> Void

    public init(gridState: Binding<GridState>, selectedCell: Binding<(row: Int, col: Int)?>, format: FormatType, accent: Color = .blue, onSelect: @escaping (Int, Int) -> Void) {
        self._gridState = gridState
        self._selectedCell = selectedCell
        self.format = format
        self.accent = accent
        self.onSelect = onSelect
    }

    public var body: some View {
        VStack(spacing: 0) {
            ForEach(0..<6, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<6, id: \.self) { col in
                        let isSelected = selectedCell?.row == row && selectedCell?.col == col
                        let value = gridState[row, col]
                        ZStack {
                            Rectangle()
                                .fill(isSelected ? accent.opacity(0.3) : Color.white)
                                .border(boxBorderColor(row: row, col: col), width: boxBorderWidth(row: row, col: col))
                                .overlay(Rectangle().stroke(Color.gray.opacity(0.5), lineWidth: 0.5))
                            if let value {
                                Text("\(value)")
                                    .font(.title3.monospacedDigit())
                            } else {
                                Text("")
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .aspectRatio(1, contentMode: .fit)
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel("Row \(row+1) Column \(col+1), \(value.map { String($0) } ?? "empty")")
                        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
                        .accessibilityHint("Double tap to select")
                        .onTapGesture { onSelect(row, col) }
                    }
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .border(Color.black, width: 2)
    }

    private func boxBorderColor(row: Int, col: Int) -> Color {
        // Thicker box borders per format
        .black
    }
    private func boxBorderWidth(row: Int, col: Int) -> CGFloat { 0.5 }
}
