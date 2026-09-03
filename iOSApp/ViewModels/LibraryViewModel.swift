import Foundation
import SharedCore
import SharedServices

@MainActor
public final class LibraryViewModel: ObservableObject {
    @Published public var puzzles: [PuzzleDefinition] = []
    @Published public var selectedFormat: FormatType?
    @Published public var selectedDifficulty: Difficulty?
    @Published public var isLoading = false
    @Published public var isUsingCache = false

    private let cloudKitService: CloudKitService
    private let persistence: PersistenceService

    public init(cloudKitService: CloudKitService = CloudKitService(), persistence: PersistenceService = PersistenceService()) {
        self.cloudKitService = cloudKitService
        self.persistence = persistence
    }

    /// Loads catalog: try public DB, fallback to cache or local generation per `PuzzleGeneratorSpec.md.md:36`.
    public func loadCatalog() {
        isLoading = true
        Task {
            do {
                let remote = try await cloudKitService.fetchCatalog()
                if !remote.isEmpty {
                    self.puzzles = remote
                    self.isUsingCache = false
                } else {
                    await self.loadFallback()
                }
            } catch {
                await self.loadFallback()
            }
            self.isLoading = false
        }
    }

    @MainActor
    private func loadFallback() {
        if let cached = persistence.loadCatalogCache(), !cached.isEmpty, !persistence.isCatalogStale() {
            puzzles = cached
            isUsingCache = true
            return
        }
        // Generate locally if no cloud catalog
        var catalog: [PuzzleDefinition] = []
        for format in FormatType.allCases {
            for difficulty in Difficulty.allCases {
                for _ in 0..<3 {
                    catalog.append(Generator.generatePuzzle(format: format, difficulty: difficulty))
                }
            }
        }
        puzzles = catalog
        isUsingCache = false
        try? persistence.saveCatalogCache(catalog)
    }

    public var filtered: [PuzzleDefinition] {
        puzzles.filter { p in
            (selectedFormat == nil || p.format == selectedFormat!) &&
            (selectedDifficulty == nil || p.difficulty == selectedDifficulty!)
        }
    }
}
