import Foundation
import SharedCore

/// Owns the hints-enabled flag: local persistence + CloudKit propagation.
/// iOS writes via `setEnabled`; all screens pull via `refreshFromCloud`.
/// Mirrors `ThemeManager` but for the `UserStats.hintsEnabled` field.
@MainActor
public final class HintsManager: ObservableObject {
    @Published public private(set) var isEnabled: Bool

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
        self.isEnabled = settings.hintsEnabled
    }

    /// Sets the flag locally and pushes it to CloudKit (fire-and-forget).
    public func setEnabled(_ enabled: Bool) {
        guard enabled != isEnabled else { return }
        isEnabled = enabled
        settings.hintsEnabled = enabled
        Task { await push() }
    }

    /// Pulls the latest flag from CloudKit (puzzle/settings entry point).
    public func refreshFromCloud() async {
        guard let remote = try? await cloudKit.fetchUserStats(),
              let incoming = remote.hintsEnabled,
              incoming != isEnabled else { return }
        isEnabled = incoming
        settings.hintsEnabled = incoming
    }

    /// Re-reads the local preference (see ThemeManager.refreshFromLocal).
    public func refreshFromLocal() {
        let local = settings.hintsEnabled
        guard local != isEnabled else { return }
        isEnabled = local
    }

    private func push() async {
        var stats = persistence.loadUserStats() ?? UserStats()
        stats.hintsEnabled = isEnabled
        try? await cloudKit.saveUserStats(stats)
    }
}
