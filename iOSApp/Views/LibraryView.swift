import SwiftUI
import SharedCore

public struct LibraryView: View {
    @StateObject private var viewModel = LibraryViewModel()
    public init() {}
    public var body: some View {
        List {
            Picker("Format", selection: $viewModel.selectedFormat) {
                Text("All").tag(nil as FormatType?)
                Text("2×3").tag(FormatType.twoByThree as FormatType?)
                Text("3×2").tag(FormatType.threeByTwo as FormatType?)
            }
            Picker("Difficulty", selection: $viewModel.selectedDifficulty) {
                Text("All").tag(nil as Difficulty?)
                Text("Easy").tag(Difficulty.easy as Difficulty?)
                Text("Medium").tag(Difficulty.medium as Difficulty?)
                Text("Hard").tag(Difficulty.hard as Difficulty?)
            }
            ForEach(viewModel.filtered, id: \.puzzleID) { puzzle in
                NavigationLink(destination: PuzzleView(puzzle: puzzle)) {
                    PuzzleCardView(puzzle: puzzle, isCompleted: viewModel.isCompleted(puzzle))
                }
            }
        }
        .navigationTitle("Library")
        .onAppear {
            if viewModel.puzzles.isEmpty { viewModel.loadCatalog() }
            viewModel.refreshCompleted()
        }
    }
}
