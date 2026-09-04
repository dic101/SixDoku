import Foundation
import Testing
@testable import SharedCore
@testable import SharedServices

@Suite("Theme Tests")
struct ThemeTests {
    @Test func threeThemes() {
        #expect(AppTheme.allCases.count == 6)
        #expect(AppTheme(rawValue: "classic") == .classic)
        #expect(AppTheme(rawValue: "midnight") == .midnight)
        #expect(AppTheme(rawValue: "highContrast") == .highContrast)
        #expect(AppTheme(rawValue: "volt") == .volt)
        #expect(AppTheme(rawValue: "ember") == .ember)
        #expect(AppTheme(rawValue: "cobalt") == .cobalt)
    }

    @Test func themeCodable() {
        let data = try? JSONEncoder().encode(AppTheme.midnight)
        #expect(data.flatMap { try? JSONDecoder().decode(AppTheme.self, from: $0) } == .midnight)
    }

    @Test @MainActor func managerPersistsLocally() {
        let store = UserDefaults(suiteName: "sixdoku.tests.theme")!
        store.removePersistentDomain(forName: "sixdoku.tests.theme")
        let stub = StubSync()
        let manager = ThemeManager(
            settings: SettingsService(defaults: store),
            cloudKit: stub,
            persistence: PersistenceService(userDefaults: store)
        )
        #expect(manager.theme == .classic)
        manager.setTheme(.highContrast)
        #expect(manager.theme == .highContrast)
        #expect(SettingsService(defaults: store).themePreference == .highContrast)
        store.removePersistentDomain(forName: "sixdoku.tests.theme")
    }

    @Test @MainActor func refreshPullsRemoteTheme() async {
        let store = UserDefaults(suiteName: "sixdoku.tests.theme")!
        store.removePersistentDomain(forName: "sixdoku.tests.theme")
        let stub = StubSync()
        await stub.set(UserStats(themePreference: AppTheme.midnight.rawValue))
        let manager = ThemeManager(
            settings: SettingsService(defaults: store),
            cloudKit: stub,
            persistence: PersistenceService(userDefaults: store)
        )
        await manager.refreshFromCloud()
        #expect(manager.theme == .midnight)
        #expect(SettingsService(defaults: store).themePreference == .midnight)
        store.removePersistentDomain(forName: "sixdoku.tests.theme")
    }
}

private actor StubSync: UserStatsSyncing {
    private var stored: UserStats?
    func set(_ stats: UserStats) { stored = stats }
    func fetchUserStats() async throws -> UserStats? { stored }
    func saveUserStats(_ stats: UserStats) async throws { stored = stats }
}
