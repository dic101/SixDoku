import Testing
@testable import SharedCore

@Suite("BoxMapping Tests")
struct BoxMappingTests {
    @Test func twoByThreeMapping() {
        // Band 0: rows 0-1
        #expect(BoxMapping.boxIndex(for: .twoByThree, row: 0, col: 0) == 0)
        #expect(BoxMapping.boxIndex(for: .twoByThree, row: 0, col: 3) == 1)
        #expect(BoxMapping.boxIndex(for: .twoByThree, row: 1, col: 2) == 0)
        #expect(BoxMapping.boxIndex(for: .twoByThree, row: 2, col: 0) == 2)
        #expect(BoxMapping.boxIndex(for: .twoByThree, row: 5, col: 5) == 5)
    }

    @Test func threeByTwoMapping() {
        #expect(BoxMapping.boxIndex(for: .threeByTwo, row: 0, col: 0) == 0)
        #expect(BoxMapping.boxIndex(for: .threeByTwo, row: 0, col: 4) == 2)
        #expect(BoxMapping.boxIndex(for: .threeByTwo, row: 3, col: 0) == 3)
        #expect(BoxMapping.boxIndex(for: .threeByTwo, row: 5, col: 5) == 5)
    }
}
