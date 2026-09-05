import Foundation
import CloudKit
import SharedCore
#if os(watchOS)
import WatchKit
#endif
#if canImport(UIKit)
import UIKit
#endif

/// CloudKit service — Dev container `iCloud.com.sixdoku.dev` (Development env).
/// Per `CloudKitSchema.md.md:3` public `PuzzleCatalog` + private `PuzzleState/UserStats`.
public final class CloudKitService: @unchecked Sendable {
    public static let containerIdentifier = "iCloud.com.sixdoku.dev"

    private let persistence: PersistenceService
    private let container: CKContainer
    private let privateDB: CKDatabase
    private let publicDB: CKDatabase

    public init(persistence: PersistenceService = PersistenceService()) {
        self.persistence = persistence
        self.container = CKContainer(identifier: Self.containerIdentifier)
        self.privateDB = container.privateCloudDatabase
        self.publicDB = container.publicCloudDatabase
    }

    // MARK: - PuzzleState

    /// Saves puzzle state with 3 retries, queues on failure per `ErrorHandlingSpec.md.md:10`.
    public func savePuzzleState(_ state: PuzzleState) async throws {
        var attempts = 0
        while attempts < 3 {
            do {
                try await performSave(state)
                return
            } catch {
                attempts += 1
                if attempts >= 3 {
                    persistence.queueForSync(state)
                    throw SixDokuError.networkUnavailable
                }
                try? await Task.sleep(nanoseconds: 200_000_000)
            }
        }
    }

    /// Timestamp-based conflict resolution per `CloudKitSchema.md.md:35`.
    public func loadLatestPuzzleState(local: PuzzleState?, remote: PuzzleState?) -> PuzzleState? {
        guard let local else { return remote }
        guard let remote else { return local }
        return remote.lastUpdated > local.lastUpdated ? remote : local
    }

    /// Fetches latest PuzzleState from CloudKit private DB (by current user).
    public func fetchRemotePuzzleState(puzzleID: String) async throws -> PuzzleState? {
        let predicate = NSPredicate(format: "puzzleID == %@", puzzleID)
        let query = CKQuery(recordType: "PuzzleState", predicate: predicate)
        let result = try await privateDB.records(matching: query, resultsLimit: 1)
        guard let (_, recordResult) = result.matchResults.first,
              let record = try? recordResult.get() else { return nil }
        return Self.decodeState(from: record)
    }

    // MARK: - PuzzleCatalog (Public DB)

    /// Encodes a PuzzleDefinition to a PuzzleCatalog CKRecord (stable recordName = puzzleID).
    /// Fields per `CloudKitSchema.md.md:4`: puzzleID, format, difficulty, initialClues, solutionGrid, createdAt, version.
    public static func encodeCatalog(_ puzzle: PuzzleDefinition, version: Int = SeedCatalog.version) -> CKRecord {
        let recordID = CKRecord.ID(recordName: puzzle.puzzleID)
        let record = CKRecord(recordType: "PuzzleCatalog", recordID: recordID)
        record["puzzleID"] = puzzle.puzzleID as CKRecordValue
        record["format"] = puzzle.format.rawValue as CKRecordValue
        record["difficulty"] = puzzle.difficulty.rawValue as CKRecordValue
        record["initialClues"] = puzzle.initialClues.map { ($0 ?? 0) } as CKRecordValue
        record["solutionGrid"] = puzzle.solutionGrid as CKRecordValue
        record["createdAt"] = Date() as CKRecordValue
        record["version"] = version as CKRecordValue
        return record
    }

    /// Uploads definitions to the public DB (dev seeding). Uses stable recordNames so re-runs overwrite.
    /// Requires iCloud sign-in; throws `networkUnavailable` / `cloudKitPermissionDenied` per ErrorHandlingSpec.
    @discardableResult
    public func uploadCatalog(_ puzzles: [PuzzleDefinition]) async throws -> Int {
        var saved = 0
        // Batch in groups to stay under CloudKit limits
        for chunk in puzzles.chunked(into: 20) {
            let records = chunk.map { Self.encodeCatalog($0) }
            do {
                let result = try await publicDB.modifyRecords(saving: records, deleting: [], savePolicy: .allKeys)
                saved += result.saveResults.values.filter { (try? $0.get()) != nil }.count
            } catch let ckError as CKError where ckError.code == .networkUnavailable || ckError.code == .notAuthenticated {
                throw SixDokuError.networkUnavailable
            } catch let ckError as CKError where ckError.code == .permissionFailure {
                throw SixDokuError.cloudKitPermissionDenied
            }
        }
        return saved
    }

    /// Fetches puzzle catalog from public DB with offline cache fallback.
    /// Fields per `CloudKitSchema.md.md:4`: puzzleID, format, difficulty, initialClues, solutionGrid, createdAt, version.
    public func fetchCatalog() async throws -> [PuzzleDefinition] {
        // If public DB not configured, throw to trigger fallback
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "PuzzleCatalog", predicate: predicate)
        let result = try await publicDB.records(matching: query, resultsLimit: 50)
        var puzzles: [PuzzleDefinition] = []
        for (_, recordResult) in result.matchResults {
            if let record = try? recordResult.get(), let puzzle = Self.decodeCatalog(from: record) {
                puzzles.append(puzzle)
            }
        }
        if !puzzles.isEmpty {
            try? persistence.saveCatalogCache(puzzles)
        }
        return puzzles
    }

    // MARK: - UserStats (Private DB)

    public func saveUserStats(_ stats: UserStats) async throws {
        try persistence.saveUserStats(stats)
        let recordID = CKRecord.ID(recordName: "UserStats_current")
        // Fetch-modify-save: a fresh CKRecord with an existing recordName
        // fails with .serverRecordChanged on second save.
        let record: CKRecord
        do {
            record = try await privateDB.record(for: recordID)
        } catch let ckError as CKError where ckError.code == .unknownItem {
            record = CKRecord(recordType: "UserStats", recordID: recordID)
        }
        Self.applyStats(stats, to: record)
        do {
            _ = try await privateDB.save(record)
        } catch let ckError as CKError where ckError.code == .networkUnavailable || ckError.code == .notAuthenticated {
            throw SixDokuError.networkUnavailable
        } catch let ckError as CKError where ckError.code == .permissionFailure {
            throw SixDokuError.cloudKitPermissionDenied
        }
    }

    /// Writes UserStats fields onto a record (shared by save + tests).
    static func applyStats(_ stats: UserStats, to record: CKRecord) {
        record["completedCount"] = stats.completedCount as CKRecordValue
        if let data = try? JSONEncoder().encode(stats.formatUsage), let str = String(data: data, encoding: .utf8) {
            record["formatUsage"] = str as CKRecordValue
        }
        if let data = try? JSONEncoder().encode(stats.bestTimes), let str = String(data: data, encoding: .utf8) {
            record["bestTimes"] = str as CKRecordValue
        }
        record["streakDays"] = stats.streakDays as CKRecordValue
        if let lastPlayed = stats.lastPlayed {
            record["lastPlayed"] = lastPlayed as CKRecordValue
        }
        if let theme = stats.themePreference {
            record["themePreference"] = theme as CKRecordValue
        }
        if let symbol = stats.symbolSetPreference {
            record["symbolSetPreference"] = symbol as CKRecordValue
        }
        if let hints = stats.hintsEnabled {
            record["hintsEnabled"] = (hints ? 1 : 0) as CKRecordValue
        }
        if let used = stats.hintsUsed {
            record["hintsUsed"] = used as CKRecordValue
        }
    }

    public func fetchUserStats() async throws -> UserStats? {
        let recordID = CKRecord.ID(recordName: "UserStats_current")
        do {
            let record = try await privateDB.record(for: recordID)
            return Self.decodeStats(from: record)
        } catch let ckError as CKError where ckError.code == .unknownItem {
            return persistence.loadUserStats()
        }
    }

    // MARK: - Private

    private func performSave(_ state: PuzzleState) async throws {
        try persistence.savePuzzleState(state)
        let recordID = CKRecord.ID(recordName: "PuzzleState_\(state.puzzleID)")
        let record = CKRecord(recordType: "PuzzleState", recordID: recordID)
        record["puzzleID"] = state.puzzleID as CKRecordValue
        record["format"] = state.format.rawValue as CKRecordValue
        record["gridState"] = state.gridState.asIntArray as CKRecordValue
        record["initialClues"] = state.initialClues.map { ($0 ?? 0) } as CKRecordValue
        record["lastUpdated"] = state.lastUpdated as CKRecordValue
        #if os(watchOS)
        let deviceType = WKInterfaceDevice.current().model
        #elseif canImport(UIKit)
        let deviceType = UIDevice.current.model
        #else
        let deviceType = "Mac"
        #endif
        record["deviceType"] = deviceType as CKRecordValue
        record["isCompleted"] = (state.isCompleted ? 1 : 0) as CKRecordValue

        do {
            _ = try await privateDB.save(record)
        } catch let ckError as CKError where ckError.code == .networkUnavailable || ckError.code == .notAuthenticated {
            throw SixDokuError.networkUnavailable
        } catch {
            if let ckError = error as? CKError, ckError.code == .permissionFailure {
                throw SixDokuError.cloudKitPermissionDenied
            }
            throw SixDokuError.cloudKitConflict
        }
    }

    private static func decodeState(from record: CKRecord) -> PuzzleState? {
        guard let puzzleID = record["puzzleID"] as? String,
              let formatRaw = record["format"] as? String,
              let format = FormatType(rawValue: formatRaw),
              let gridInts = record["gridState"] as? [Int],
              let clueInts = record["initialClues"] as? [Int],
              let lastUpdated = record["lastUpdated"] as? Date else { return nil }
        let gridState = GridState(cells: gridInts.map { $0 == 0 ? nil : $0 })
        let initialClues: [Int?] = clueInts.map { $0 == 0 ? nil : $0 }
        let isCompleted = (record["isCompleted"] as? Int) == 1
        return PuzzleState(puzzleID: puzzleID, format: format, gridState: gridState, initialClues: initialClues, isCompleted: isCompleted, lastUpdated: lastUpdated)
    }

    private static func decodeCatalog(from record: CKRecord) -> PuzzleDefinition? {
        guard let puzzleID = record["puzzleID"] as? String,
              let formatRaw = record["format"] as? String,
              let format = FormatType(rawValue: formatRaw),
              let diffRaw = record["difficulty"] as? String,
              let difficulty = Difficulty(rawValue: diffRaw),
              let clueInts = record["initialClues"] as? [Int],
              let solutionInts = record["solutionGrid"] as? [Int] else { return nil }
        let initialClues: [Int?] = clueInts.map { $0 == 0 ? nil : $0 }
        return PuzzleDefinition(puzzleID: puzzleID, format: format, difficulty: difficulty, initialClues: initialClues, solutionGrid: solutionInts)
    }

    static func decodeStats(from record: CKRecord) -> UserStats? {
        let completedCount = record["completedCount"] as? Int ?? 0
        var formatUsage: [String: Int] = [:]
        if let str = record["formatUsage"] as? String, let data = str.data(using: .utf8) {
            formatUsage = (try? JSONDecoder().decode([String: Int].self, from: data)) ?? [:]
        }
        var bestTimes: [String: Int] = [:]
        if let str = record["bestTimes"] as? String, let data = str.data(using: .utf8) {
            bestTimes = (try? JSONDecoder().decode([String: Int].self, from: data)) ?? [:]
        }
        let streakDays = record["streakDays"] as? Int ?? 0
        let lastPlayed = record["lastPlayed"] as? Date
        let themePreference = record["themePreference"] as? String
        let symbolSetPreference = record["symbolSetPreference"] as? String
        let hintsEnabled = (record["hintsEnabled"] as? Int).map { $0 == 1 }
        let hintsUsed = record["hintsUsed"] as? Int
        return UserStats(completedCount: completedCount, formatUsage: formatUsage, bestTimes: bestTimes, streakDays: streakDays, lastPlayed: lastPlayed, themePreference: themePreference, symbolSetPreference: symbolSetPreference, hintsEnabled: hintsEnabled, hintsUsed: hintsUsed)
    }
}

extension Array {
    fileprivate func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map { Array(self[$0..<Swift.min($0 + size, count)]) }
    }
}
