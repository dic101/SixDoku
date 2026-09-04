import Foundation
import SharedCore
import SharedServices

@MainActor
public final class SettingsViewModel: ObservableObject {
    @Published public var formatPreference: FormatType {
        didSet { settings.formatPreference = formatPreference }
    }
    @Published public var seedStatus: String?
    @Published public var isSeeding = false

    private let settings: SettingsService
    private let cloudKit: CloudKitService

    public init(settings: SettingsService = SettingsService(), cloudKit: CloudKitService = CloudKitService()) {
        self.settings = settings
        self.cloudKit = cloudKit
        self.formatPreference = settings.formatPreference
    }

    /// Uploads the bundled (or freshly generated) seed catalog to the public DB. Dev seeding only.
    public func seedCatalog() {
        isSeeding = true
        seedStatus = "Seeding…"
        Task {
            let catalog = LibraryViewModel.loadBundledSeed() ?? SeedCatalog.generate()
            do {
                let count = try await cloudKit.uploadCatalog(catalog)
                self.seedStatus = "Seeded \(count) puzzles to iCloud public DB"
            } catch {
                self.seedStatus = "Seed failed: \(error.localizedDescription) (offline? sign into iCloud)"
            }
            self.isSeeding = false
        }
    }
}
