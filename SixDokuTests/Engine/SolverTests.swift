import Testing
@testable import SharedCore

@Suite("Solver Tests")
struct SolverTests {
    @Test func solveValidPuzzle() {
        // Simple puzzle with some clues
        let puzzle = Generator.generatePuzzle(format: .twoByThree, difficulty: .easy)
        let grid = GridState(cells: puzzle.initialClues)
        let solution = Solver.solve(grid: grid, format: puzzle.format)
        #expect(solution != nil)
        #expect(solution?.count == 36)
    }

    @Test func detectMultipleSolutions() {
        let empty = GridState()
        let solutions = Solver.findSolutions(grid: empty, format: .twoByThree, maxSolutions: 2)
        #expect(solutions.count == 2) // empty has many
    }

    @Test func unsolvablePuzzleReturnsNil() {
        // Contradiction: duplicate in row
        var cells: [Int?] = Array(repeating: nil, count: 36)
        cells[0] = 1; cells[1] = 1 // Row 0 duplicate
        let grid = GridState(cells: cells)
        let sol = Solver.solve(grid: grid, format: .twoByThree)
        #expect(sol == nil)
    }

    @Test func uniqueness() {
        let puzzle = Generator.generatePuzzle(format: .threeByTwo, difficulty: .medium)
        #expect(Solver.isUnique(grid: GridState(cells: puzzle.initialClues), format: .threeByTwo) == true)
    }
}
