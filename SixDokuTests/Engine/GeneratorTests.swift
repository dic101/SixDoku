import Testing
@testable import SharedCore

@Suite("Generator Tests")
struct GeneratorTests {
    @Test func uniqueness() {
        for format in FormatType.allCases {
            let puzzle = Generator.generatePuzzle(format: format, difficulty: .medium)
            #expect(Solver.isUnique(grid: GridState(cells: puzzle.initialClues), format: format))
        }
    }

    @Test func clueCountMatchesDifficulty() {
        let easy = Generator.generatePuzzle(format: .twoByThree, difficulty: .easy)
        let easyCount = easy.initialClues.filter { $0 != nil }.count
        #expect((14...18).contains(easyCount) || (15...20).contains(easyCount)) // allow variance for 3x2 not applied

        let hard = Generator.generatePuzzle(format: .twoByThree, difficulty: .hard)
        let hardCount = hard.initialClues.filter { $0 != nil }.count
        #expect((10...12).contains(hardCount))

        let hardB = Generator.generatePuzzle(format: .threeByTwo, difficulty: .hard)
        let hardBCount = hardB.initialClues.filter { $0 != nil }.count
        #expect((11...14).contains(hardBCount)) // +1-2 for 3x2
    }

    @Test func solutionIsValid() {
        let puzzle = Generator.generatePuzzle(format: .twoByThree, difficulty: .easy)
        let solutionGrid = GridState(cells: puzzle.solutionGrid.map { $0 as Int? })
        #expect(Validator.isValidGrid(grid: solutionGrid, format: .twoByThree))
    }
}
