import Testing
@testable import SharedCore
import CloudKit
@testable import SharedServices

@Suite("SeedCatalog Tests")
struct SeedCatalogTests {
    @Test func stableIDsAndCounts() {
        let catalog = SeedCatalog.generate(perBucket: 2)
        #expect(catalog.count == 2 * 3 * 2)
        let ids = catalog.map(\.puzzleID)
        #expect(Set(ids).count == ids.count)
        #expect(ids.contains("sixdoku-2x3-easy-001"))
        #expect(ids.contains("sixdoku-3x2-hard-002"))
    }

    @Test func puzzlesAreUniqueAndValid() {
        let catalog = SeedCatalog.generate(perBucket: 1)
        #expect(SeedCatalog.validate(catalog))
    }

    @Test func encodeCatalogRecord() {
        let puzzle = Generator.generatePuzzle(format: .twoByThree, difficulty: .easy)
        let stable = PuzzleDefinition(
            puzzleID: "sixdoku-2x3-easy-001",
            format: puzzle.format, difficulty: puzzle.difficulty,
            initialClues: puzzle.initialClues, solutionGrid: puzzle.solutionGrid
        )
        let record = CloudKitService.encodeCatalog(stable)
        #expect(record.recordType == "PuzzleCatalog")
        #expect(record.recordID.recordName == "sixdoku-2x3-easy-001")
        #expect(record["format"] as? String == "2x3")
    }
}
