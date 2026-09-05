import SwiftUI
import SharedCore
import SharedServices

public struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @StateObject private var themes = ThemeManager()
    @State private var selectedFormat: FormatType = .twoByThree
    @State private var path: [String] = []

    public init() {}
    public var body: some View {
        NavigationStack(path: $path) {
            List {
                if let puzzle = viewModel.currentPuzzle, !puzzle.isCompleted {
                    Section {
                        NavigationLink(value: puzzle.puzzleID) {
                            HStack {
                                Image(systemName: "play.circle.fill")
                                    .font(.title2)
                                    .foregroundStyle(themes.theme.accent)
                                VStack(alignment: .leading) {
                                    Text("Resume \(puzzle.format.rawValue)")
                                        .font(.headline)
                                    Text("Last played \(relative(puzzle.lastUpdated))")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .accessibilityLabel("Resume \(puzzle.format.rawValue) puzzle")
                    } header: {
                        Text("Continue")
                    }
                }
                Section {
                    FormatSelectorView(selection: $selectedFormat)
                        .listRowSeparator(.hidden)
                    ForEach(Difficulty.allCases, id: \.self) { difficulty in
                        NavigationLink {
                            PuzzleHostView(format: selectedFormat, difficulty: difficulty)
                        } label: {
                            HStack {
                                Image(systemName: icon(for: difficulty))
                                    .font(.title3)
                                    .foregroundStyle(themes.theme.accent)
                                    .frame(width: 28)
                                VStack(alignment: .leading) {
                                    Text(difficulty.rawValue.capitalized)
                                        .font(.headline)
                                    Text("\(difficulty.clueRange.lowerBound)–\(difficulty.clueRange.upperBound) givens · \(flavor(for: difficulty))")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .accessibilityLabel("New \(difficulty.rawValue) \(selectedFormat.rawValue) puzzle")
                    }
                } header: {
                    Text("New Game")
                } footer: {
                    Text("Format and difficulty apply to generated puzzles. Library puzzles are fixed.")
                }
                Section {
                    rowLink(title: "Library", subtitle: "Hand-picked seed collection", icon: "books.vertical") { LibraryView() }
                    rowLink(title: "Stats", subtitle: "Completions, streaks, best times", icon: "chart.bar") { StatsView() }
                    rowLink(title: "Settings", subtitle: "Format, hints, grid theme", icon: "gearshape") { SettingsView() }
                } header: {
                    Text("More")
                }
            }
            .navigationTitle("6Doku")
            .navigationDestination(for: String.self) { puzzleID in
                ResumeHostView(puzzleID: puzzleID)
            }
            .onAppear {
                viewModel.refresh()
                selectedFormat = viewModel.lastFormat
                themes.refreshFromLocal()
                Task { await themes.refreshFromCloud() }
            }
        }
        .tint(themes.theme.accent)
    }

    private func rowLink<Destination: View>(title: String, subtitle: String, icon: String, @ViewBuilder destination: () -> Destination) -> some View {
        NavigationLink {
            destination()
        } label: {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(themes.theme.accent)
                    .frame(width: 28)
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.headline)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func icon(for difficulty: Difficulty) -> String {
        switch difficulty {
        case .easy: return "leaf"
        case .medium: return "bolt"
        case .hard: return "flame"
        }
    }

    private func flavor(for difficulty: Difficulty) -> String {
        switch difficulty {
        case .easy: return "relaxed start"
        case .medium: return "balanced"
        case .hard: return "sparse grid"
        }
    }

    private func relative(_ date: Date) -> String {
        RelativeDateTimeFormatter().localizedString(for: date, relativeTo: Date())
    }
}

private struct ResumeHostView: View {
    var puzzleID: String
    @State private var state: PuzzleState?
    @State private var solution: [Int]?
    @State private var loaded = false
    var body: some View {
        Group {
            if let state, let solution {
                PuzzleView(state: state, solution: solution)
            } else if loaded {
                Text("Saved puzzle is no longer solvable.")
                    .foregroundStyle(.secondary)
            } else {
                ProgressView()
            }
        }
        .onAppear {
            guard !loaded else { return }
            loaded = true
            // Re-derive the solution from the initial clues (all shipped
            // puzzles have unique solutions, so this matches the original).
            if let saved = PersistenceService().loadPuzzleState(),
               saved.puzzleID == puzzleID,
               let solved = Solver.solve(grid: GridState(cells: saved.initialClues), format: saved.format) {
                state = saved
                solution = solved
            }
        }
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
