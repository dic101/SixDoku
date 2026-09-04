import Testing
import CloudKit
@testable import SharedCore
@testable import SharedServices

@Suite("UserStats Sync Tests")
struct UserStatsSyncTests {
    @Test func dictionaryRoundTrip() {
        let stats = UserStats(
            completedCount: 7,
            formatUsage: ["2x3": 5, "3x2": 2],
            bestTimes: ["2x3_easy": 120, "3x2_hard": 300],
            streakDays: 3,
            lastPlayed: Date(timeIntervalSince1970: 1_000_000),
            themePreference: "dark",
            symbolSetPreference: "classic"
        )
        let record = CKRecord(recordType: "UserStats", recordID: CKRecord.ID(recordName: "UserStats_current"))
        CloudKitService.applyStats(stats, to: record)
        guard let decoded = CloudKitService.decodeStats(from: record) else {
            Issue.record("decodeStats returned nil")
            return
        }
        #expect(decoded == stats)
    }

    @Test func emptyDictionariesRoundTrip() {
        let stats = UserStats()
        let record = CKRecord(recordType: "UserStats", recordID: CKRecord.ID(recordName: "UserStats_current"))
        CloudKitService.applyStats(stats, to: record)
        guard let decoded = CloudKitService.decodeStats(from: record) else {
            Issue.record("decodeStats returned nil")
            return
        }
        #expect(decoded.formatUsage.isEmpty)
        #expect(decoded.bestTimes.isEmpty)
        #expect(decoded.completedCount == 0)
        #expect(decoded.lastPlayed == nil)
    }

    @Test func bestTimeKeepsMinimum() {
        var stats = UserStats()
        stats.recordCompletion(format: .twoByThree, difficulty: .easy, seconds: 200)
        stats.recordCompletion(format: .twoByThree, difficulty: .easy, seconds: 150)
        stats.recordCompletion(format: .twoByThree, difficulty: .easy, seconds: 180)
        #expect(stats.bestTimes["2x3_easy"] == 150)
        #expect(stats.completedCount == 3)
        #expect(stats.formatUsage["2x3"] == 3)
    }

    @Test func localPersistenceRoundTrip() {
        let store = UserDefaults(suiteName: "sixdoku.tests.stats")!
        store.removePersistentDomain(forName: "sixdoku.tests.stats")
        let persistence = PersistenceService(userDefaults: store)
        let stats = UserStats(completedCount: 2, formatUsage: ["3x2": 2], bestTimes: ["3x2_medium": 95], streakDays: 1)
        try? persistence.saveUserStats(stats)
        #expect(persistence.loadUserStats() == stats)
        store.removePersistentDomain(forName: "sixdoku.tests.stats")
    }
}
