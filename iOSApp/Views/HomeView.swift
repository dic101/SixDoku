import SwiftUI
import SharedCore

public struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var selectedFormat: FormatType = .twoByThree
    @State private var path: [String] = []

    public init() {}
    public var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if let puzzle = viewModel.currentPuzzle {
                    Text("Continue \(puzzle.format.rawValue)")
                    NavigationLink("Resume", value: puzzle.puzzleID)
                }
                FormatSelectorView(selection: $selectedFormat)
                    .padding(.horizontal)
                NavigationLink("New Easy Puzzle") {
                    PuzzleHostView(format: selectedFormat, difficulty: .easy)
                }
                NavigationLink("New Medium Puzzle") {
                    PuzzleHostView(format: selectedFormat, difficulty: .medium)
                }
                NavigationLink("New Hard Puzzle") {
                    PuzzleHostView(format: selectedFormat, difficulty: .hard)
                }
                NavigationLink("Library") { LibraryView() }
                NavigationLink("Stats") { StatsView() }
                NavigationLink("Settings") { SettingsView() }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .navigationTitle("6Doku")
        }
        .tint(.blue)
    }
}

private struct PuzzleHostView: View {
    var format: FormatType
    var difficulty: Difficulty
    @State private var puzzle: PuzzleDefinition?
    var body: some View {
        Group {
            if let puzzle {
                PuzzleView(puzzle: puzzle)
            } else {
                ProgressView().onAppear { puzzle = Generator.generatePuzzle(format: format, difficulty: difficulty) }
            }
        }
    }
}
