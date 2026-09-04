import SwiftUI
import SharedCore
import SharedServices

/// Full-page number picker with large rows — auto-returns after each pick.
public struct WatchNumberPickerView: View {
    @ObservedObject var viewModel: WatchPuzzleViewModel
    @EnvironmentObject private var themes: ThemeManager
    @Environment(\.dismiss) private var dismiss

    public init(viewModel: WatchPuzzleViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        let theme = themes.theme
        ScrollView {
            VStack(spacing: 6) {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 6) {
                    ForEach(1...6, id: \.self) { n in
                        let allowed = viewModel.isValidMove(n)
                        let current = viewModel.selectedValue() == n
                        Button {
                            if let cell = viewModel.selectedCell {
                                viewModel.applyMove(row: cell.row, col: cell.col, symbol: n)
                            }
                            dismiss()
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(current ? theme.accent : theme.accent.opacity(0.15))
                                    .frame(minHeight: 52)
                                HStack(spacing: 2) {
                                    Text("\(n)")
                                        .font(.title3)
                                        .foregroundStyle(current ? theme.pageBackground : .primary)
                                    if current {
                                        Image(systemName: "checkmark")
                                            .font(.caption2)
                                            .foregroundStyle(theme.pageBackground)
                                    } else if !allowed {
                                        Image(systemName: "slash.circle")
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                        .buttonStyle(.plain)
                        .disabled(!allowed && !current)
                        .opacity(!allowed && !current ? 0.4 : 1)
                        .accessibilityLabel("Place \(n)")
                    }
                }
                Button(role: .destructive) {
                    if let cell = viewModel.selectedCell {
                        viewModel.applyMove(row: cell.row, col: cell.col, symbol: nil)
                    }
                    dismiss()
                } label: {
                    Label("Erase", systemImage: "xmark")
                        .font(.callout)
                        .frame(maxWidth: .infinity, minHeight: 40)
                }
                .buttonStyle(.plain)
                .background(Color.red.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .accessibilityLabel("Erase entry")
            }
            .padding(.horizontal, 2)
        }
        .navigationTitle(title)
    }

    private var title: String {
        guard let cell = viewModel.selectedCell else { return "Pick" }
        return "R\(cell.row + 1) · C\(cell.col + 1)"
    }
}
