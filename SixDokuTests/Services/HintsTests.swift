import Foundation
import Testing
import CloudKit
@testable import SharedCore
@testable import SharedServices

@Suite("Hints Tests")
struct HintsTests {
    @Test func settingsDefaultsToDisabled() {
        let name = "sixdoku.tests.hints.defaults"
        let store = UserDefaults(suiteName: name)!
        store.removePersistentDomain(forName: name)
        #expect(SettingsService(defaults: store).hintsEnabled == false)
        store.removePersistentDomain(forName: name)
    }

    @Test func settingsPersistsToggle() {
        let name = "sixdoku.tests.hints.persist"
        let store = UserDefaults(suiteName: name)!
        store.removePersistentDomain(forName: name)
        let settings = SettingsService(defaults: store)
        settings.hintsEnabled = false
        #expect(SettingsService(defaults: store).hintsEnabled == false)
        settings.hintsEnabled = true
        #expect(SettingsService(defaults: store).hintsEnabled == true)
        store.removePersistentDomain(forName: name)
    }

    @Test func statsMissingKeyMeansDisabled() {
        // Backward compat: records saved before the flag existed decode to nil → disabled.
        let stats = UserStats()
        #expect(stats.hintsEnabled == nil)
        #expect(stats.hintsOn == false)
        #expect(UserStats(hintsEnabled: true).hintsOn == true)
    }

    @Test func statsJsonRoundTrip() {
        let stats = UserStats(completedCount: 1, hintsEnabled: true)
        let data = try? JSONEncoder().encode(stats)
        let decoded = data.flatMap { try? JSONDecoder().decode(UserStats.self, from: $0) }
        #expect(decoded?.hintsEnabled == true)
        #expect(decoded?.hintsOn == true)
    }

    @Test func statsRecordRoundTrip() {
        let stats = UserStats(completedCount: 3, hintsEnabled: true)
        let record = CKRecord(recordType: "UserStats", recordID: CKRecord.ID(recordName: "UserStats_current"))
        CloudKitService.applyStats(stats, to: record)
        guard let decoded = CloudKitService.decodeStats(from: record) else {
            Issue.record("decodeStats returned nil")
            return
        }
        #expect(decoded.hintsEnabled == true)
        #expect(decoded == stats)
    }

    @Test func statsRecordMissingKeyDecodesNil() {
        // Old record without the field → nil → treated as disabled.
        let record = CKRecord(recordType: "UserStats", recordID: CKRecord.ID(recordName: "UserStats_current"))
        record["completedCount"] = 1 as CKRecordValue
        guard let decoded = CloudKitService.decodeStats(from: record) else {
            Issue.record("decodeStats returned nil")
            return
        }
        #expect(decoded.hintsEnabled == nil)
        #expect(decoded.hintsOn == false)
    }

    @Test func hintsUsedDefaultsToZero() {
        #expect(UserStats().hintsUsed == nil)
        #expect(UserStats().totalHintsUsed == 0)
    }

    @Test func recordHintUsedIncrements() {
        var stats = UserStats()
        stats.recordHintUsed()
        stats.recordHintUsed()
        #expect(stats.hintsUsed == 2)
        #expect(stats.totalHintsUsed == 2)
    }

    @Test func hintsUsedJsonRoundTrip() {
        let stats = UserStats(hintsUsed: 3)
        let data = try? JSONEncoder().encode(stats)
        let decoded = data.flatMap { try? JSONDecoder().decode(UserStats.self, from: $0) }
        #expect(decoded?.hintsUsed == 3)
        #expect(decoded?.totalHintsUsed == 3)
    }

    @Test func hintsUsedMissingJsonKeyDecodesNil() {
        // Old payload (all pre-hints keys, no hintsUsed) must still decode —
        // missing key means zero, and must NOT wipe the rest of the stats.
        let oldPayload: [String: Any] = [
            "completedCount": 4,
            "formatUsage": ["2x3": 4],
            "bestTimes": ["2x3_easy": 120],
            "streakDays": 2,
        ]
        let data = try? JSONSerialization.data(withJSONObject: oldPayload)
        let decoded = data.flatMap { try? JSONDecoder().decode(UserStats.self, from: $0) }
        #expect(decoded?.hintsUsed == nil)
        #expect(decoded?.totalHintsUsed == 0)
        #expect(decoded?.completedCount == 4)
        #expect(decoded?.streakDays == 2)
    }

    @Test func hintsUsedRecordRoundTrip() {
        let stats = UserStats(completedCount: 1, hintsUsed: 5)
        let record = CKRecord(recordType: "UserStats", recordID: CKRecord.ID(recordName: "UserStats_current"))
        CloudKitService.applyStats(stats, to: record)
        guard let decoded = CloudKitService.decodeStats(from: record) else {
            Issue.record("decodeStats returned nil")
            return
        }
        #expect(decoded.hintsUsed == 5)
        #expect(decoded == stats)
    }

    @Test func hintsUsedMissingRecordKeyDecodesNil() {
        let record = CKRecord(recordType: "UserStats", recordID: CKRecord.ID(recordName: "UserStats_current"))
        record["completedCount"] = 1 as CKRecordValue
        guard let decoded = CloudKitService.decodeStats(from: record) else {
            Issue.record("decodeStats returned nil")
            return
        }
        #expect(decoded.hintsUsed == nil)
        #expect(decoded.totalHintsUsed == 0)
    }

    @Test @MainActor func managerPersistsLocally() {
        let name = "sixdoku.tests.hints.manager"
        let store = UserDefaults(suiteName: name)!
        store.removePersistentDomain(forName: name)
        let manager = HintsManager(
            settings: SettingsService(defaults: store),
            cloudKit: HintsStubSync(),
            persistence: PersistenceService(userDefaults: store)
        )
        #expect(manager.isEnabled == false)
        manager.setEnabled(true)
        #expect(manager.isEnabled == true)
        #expect(SettingsService(defaults: store).hintsEnabled == true)
        store.removePersistentDomain(forName: name)
    }

    @Test @MainActor func refreshPullsRemoteFlag() async {
        let name = "sixdoku.tests.hints.pull"
        let store = UserDefaults(suiteName: name)!
        store.removePersistentDomain(forName: name)
        let stub = HintsStubSync()
        await stub.set(UserStats(hintsEnabled: true))
        let manager = HintsManager(
            settings: SettingsService(defaults: store),
            cloudKit: stub,
            persistence: PersistenceService(userDefaults: store)
        )
        await manager.refreshFromCloud()
        #expect(manager.isEnabled == true)
        #expect(SettingsService(defaults: store).hintsEnabled == true)
        store.removePersistentDomain(forName: name)
    }

    @Test @MainActor func refreshIgnoresMissingFlag() async {
        // Remote without the flag must not flip a local explicit choice.
        let name = "sixdoku.tests.hints.missing"
        let store = UserDefaults(suiteName: name)!
        store.removePersistentDomain(forName: name)
        SettingsService(defaults: store).hintsEnabled = true
        let stub = HintsStubSync()
        await stub.set(UserStats()) // hintsEnabled nil
        let manager = HintsManager(
            settings: SettingsService(defaults: store),
            cloudKit: stub,
            persistence: PersistenceService(userDefaults: store)
        )
        await manager.refreshFromCloud()
        #expect(manager.isEnabled == true)
        store.removePersistentDomain(forName: name)
    }
}

private actor HintsStubSync: UserStatsSyncing {
    private var stored: UserStats?
    func set(_ stats: UserStats) { stored = stats }
    func fetchUserStats() async throws -> UserStats? { stored }
    func saveUserStats(_ stats: UserStats) async throws { stored = stats }
}
