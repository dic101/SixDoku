import SwiftUI
import SharedCore
import SharedServices

public struct PuzzleView: View {
    @StateObject private var viewModel: PuzzleViewModel
    @StateObject private var themes = ThemeManager()
    @StateObject private var hints = HintsManager()
    @State private var hintMessage: String?
    @State private var showCelebration = false
    public init(puzzle: PuzzleDefinition) {
        _viewModel = StateObject(wrappedValue: PuzzleViewModel(puzzleDefinition: puzzle))
    }
    public init(state: PuzzleState, solution: [Int]) {
        _viewModel = StateObject(wrappedValue: PuzzleViewModel(puzzleState: state, solutionGrid: solution))
    }

    public var body: some View {
        ZStack {
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
                theme: themes.theme,
                hintsEnabled: hints.isEnabled
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
                Label("Completed", systemImage: "checkmark.seal.fill")
                    .font(.headline)
                    .foregroundStyle(themes.theme.accent)
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

            if viewModel.isCompleted && showCelebration {
                CompletionCelebrationView(accent: themes.theme.accent) {
                    showCelebration = false
                }
                .transition(.scale.combined(with: .opacity))
                .zIndex(1)
            }
        }
        .navigationTitle("\(viewModel.format.rawValue) • \(viewModel.puzzleID.prefix(4))")
        .navigationBarTitleDisplayMode(.inline)
        .tint(themes.theme.accent)
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
            themes.refreshFromLocal()
            hints.refreshFromLocal()
            await themes.refreshFromCloud()
            await hints.refreshFromCloud()
        }
        .onAppear {
            // Already-solved puzzle (e.g. resumed) still deserves the big moment.
            if viewModel.isCompleted { showCelebration = true }
        }
        .onChange(of: viewModel.isCompleted) { _, completed in
            if completed {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    showCelebration = true
                }
                announce("Puzzle completed")
            }
        }
    }

    private func announce(_ message: String) {
        AccessibilityNotification.Announcement(message).post()
    }
}

/// Full-screen, big-moment celebration shown on puzzle completion.
/// Per UIInteractionRules §4: celebratory haptic (fired in the view model)
/// + confetti animation (rendered here).
public struct CompletionCelebrationView: View {
    var accent: Color = .blue
    var onDismiss: () -> Void
    @State private var animate = false

    public init(accent: Color = .blue, onDismiss: @escaping () -> Void) {
        self.accent = accent
        self.onDismiss = onDismiss
    }

    public var body: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()

            ConfettiView()
                .ignoresSafeArea()

            VStack(spacing: 16) {
                Image(systemName: "party.popper.fill")
                    .font(.system(size: 96))
                    .foregroundStyle(accent)
                    .symbolEffect(.bounce, value: animate)
                    .scaleEffect(animate ? 1.0 : 0.5)
                    .opacity(animate ? 1 : 0)
                    .accessibilityHidden(true)

                Text("Puzzle Complete!")
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)

                Text("Brilliant solve — take a moment to enjoy it.")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Button("Keep Admiring") { onDismiss() }
                    .buttonStyle(.borderedProminent)
                    .tint(accent)
                    .padding(.top, 8)
                    .accessibilityLabel("Dismiss celebration")
            }
            .padding(32)
            .frame(maxWidth: 340)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 28))
            .scaleEffect(animate ? 1 : 0.7)
            .opacity(animate ? 1 : 0)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Puzzle completed celebration")
        .onAppear {
            withAnimation(.spring(response: 0.55, dampingFraction: 0.7)) {
                animate = true
            }
        }
    }
}

/// Lightweight confetti: ~60 rounded-rect pieces falling + rotating + fading.
private struct ConfettiView: View {
    private struct Piece: Identifiable {
        let id = UUID()
        let x: CGFloat // 0...1 horizontal fraction
        let delay: Double
        let duration: Double
        let color: Color
        let size: CGFloat
        let rotation: Double
    }

    private static let colors: [Color] =
        [.red, .orange, .yellow, .green, .blue, .purple, .pink]

    private let pieces: [Piece] = (0..<60).map { _ in
        Piece(
            x: CGFloat.random(in: 0...1),
            delay: Double.random(in: 0...0.6),
            duration: Double.random(in: 1.6...2.8),
            color: colors.randomElement() ?? .blue,
            size: CGFloat.random(in: 6...12),
            rotation: Double.random(in: -360...360)
        )
    }

    @State private var falling = false

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(pieces) { piece in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(piece.color)
                        .frame(width: piece.size, height: piece.size * 0.6)
                        .position(
                            x: piece.x * proxy.size.width,
                            y: falling ? proxy.size.height + 20 : -20
                        )
                        .rotationEffect(.degrees(falling ? piece.rotation : 0))
                        .opacity(falling ? 0 : 1)
                        .animation(
                            .easeIn(duration: piece.duration).delay(piece.delay),
                            value: falling
                        )
                }
            }
            .onAppear { falling = true }
        }
        .allowsHitTesting(false)
    }
}
