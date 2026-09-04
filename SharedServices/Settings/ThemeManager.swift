import Foundation
import SharedCore

/// Minimal surface ThemeManager needs (CloudKit in prod, stub in tests).
/// A concrete `CloudKitService()` cannot be instantiated in the `swift test`
/// host (traps the runner), so this stays behind a protocol.
public protocol UserStatsSyncing: Sendable {
    func fetchUserStats() async throws -> UserStats?
    func saveUserStats(_ stats: UserStats) async throws
}

extension CloudKitService: UserStatsSyncing {}

/// Owns the active `AppTheme`: local persistence + CloudKit propagation.
/// iOS writes via `setTheme`; watch pulls via `refreshFromCloud`.
@MainActor
public final class ThemeManager: ObservableObject {
    @Published public private(set) var theme: AppTheme

    private let settings: SettingsService
    private let cloudKit: any UserStatsSyncing
    private let persistence: PersistenceService

    public init(
        settings: SettingsService = SettingsService(),
        cloudKit: any UserStatsSyncing = CloudKitService(),
        persistence: PersistenceService = PersistenceService()
    ) {
        self.settings = settings
        self.cloudKit = cloudKit
        self.persistence = persistence
        self.theme = settings.themePreference
    }

    /// Sets the theme locally and pushes it to CloudKit (fire-and-forget).
    public func setTheme(_ newTheme: AppTheme) {
        guard newTheme != theme else { return }
        theme = newTheme
        settings.themePreference = newTheme
        Task { await push() }
    }

    /// Pulls the latest theme from CloudKit (watch entry point).
    public func refreshFromCloud() async {
        guard let remote = try? await cloudKit.fetchUserStats(),
              let raw = remote.themePreference,
              let incoming = AppTheme(rawValue: raw),
              incoming != theme else { return }
        theme = incoming
        settings.themePreference = incoming
    }

    private func push() async {
        var stats = persistence.loadUserStats() ?? UserStats()
        stats.themePreference = theme.rawValue
        try? await cloudKit.saveUserStats(stats)
    }
}
