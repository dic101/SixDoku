import SwiftUI
import SharedCore

public struct WatchHomeView: View {
    @StateObject private var viewModel = WatchHomeViewModel()
    public init() {}
    public var body: some View {
        NavigationStack {
            VStack {
                NavigationLink("New 2×3") { WatchPuzzleView(puzzle: viewModel.newPuzzle(format: .twoByThree, difficulty: .easy)) }
                NavigationLink("New 3×2") { WatchPuzzleView(puzzle: viewModel.newPuzzle(format: .threeByTwo, difficulty: .easy)) }
                NavigationLink("Format") { WatchFormatSelectorView() }
            }
            .navigationTitle("SixDoku")
        }
    }
}
