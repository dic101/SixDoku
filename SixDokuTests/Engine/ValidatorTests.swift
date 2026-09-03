import Testing
@testable import SharedCore

@Suite("Validator Tests")
struct ValidatorTests {
    @Test func rowColumnBox() {
        var cells: [Int?] = Array(repeating: nil, count: 36)
        cells[0] = 1 // (0,0)
        let grid = GridState(cells: cells)
        // Duplicate in row should be invalid
        #expect(Validator.isValidMove(grid: grid, row: 0, col: 1, symbol: 1, format: .twoByThree) == false)
        // Valid symbol
        #expect(Validator.isValidMove(grid: grid, row: 0, col: 1, symbol: 2, format: .twoByThree) == true)
        // Box check 2x3: (0,0) box includes (1,2) but not (2,0)? Wait box 0 is rows 0-1 cols 0-2
        #expect(Validator.isValidMove(grid: grid, row: 1, col: 1, symbol: 1, format: .twoByThree) == false)
        #expect(Validator.isValidMove(grid: grid, row: 2, col: 3, symbol: 1, format: .twoByThree) == true)
    }

    @Test func boxMapping3x2() {
        // 3x2 format box mapping
        #expect(BoxMapping.boxIndex(for: .threeByTwo, row: 0, col: 0) == 0)
        #expect(BoxMapping.boxIndex(for: .threeByTwo, row: 0, col: 2) == 1)
        #expect(BoxMapping.boxIndex(for: .threeByTwo, row: 3, col: 0) == 3)
        // Invalid move in same 3x2 box
        var cells: [Int?] = Array(repeating: nil, count: 36)
        cells[0] = 5 // (0,0) box 0
        let grid = GridState(cells: cells)
        #expect(Validator.isValidMove(grid: grid, row: 1, col: 1, symbol: 5, format: .threeByTwo) == false)
    }

    @Test func isCompleteAndSolved() {
        let empty = GridState()
        #expect(Validator.isComplete(grid: empty) == false)
        let fullGrid = GridState(cells: Array(repeating: 1, count: 36) as [Int?])
        #expect(Validator.isComplete(grid: fullGrid) == true)
    }
}
