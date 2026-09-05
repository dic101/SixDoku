import SwiftUI
import SharedCore
import SharedServices

public struct WatchHomeView: View {
    @StateObject private var viewModel = WatchHomeViewModel()
    @State private var pendingPuzzle: PuzzleDefinition?
    public init() {}
    public var body: some View {
        NavigationStack {
            VStack {
                // Puzzle is generated ONCE per tap (not per body evaluation),
                // otherwise the board resets on every re-render.
                Button("New 2×3") { pendingPuzzle = viewModel.newPuzzle(format: .twoByThree, difficulty: .easy) }
                Button("New 3×2") { pendingPuzzle = viewModel.newPuzzle(format: .threeByTwo, difficulty: .easy) }
            }
            .navigationTitle("6Doku")
            .navigationDestination(item: $pendingPuzzle) { puzzle in
                WatchPuzzleView(puzzle: puzzle)
            }
        }
    }
}
