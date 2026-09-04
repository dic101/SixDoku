import Foundation
import SharedCore

// Generates SeedCatalog.json for bundling + CloudKit Dashboard reference.
// Usage: swift run SeedGenerator [perBucket] [outputPath]
let perBucket = CommandLine.arguments.dropFirst().first.flatMap(Int.init) ?? SeedCatalog.defaultPerBucket
let outputPath = CommandLine.arguments.dropFirst(2).first ?? "iOSApp/Resources/SeedCatalog.json"

let catalog = SeedCatalog.generate(perBucket: perBucket)
guard SeedCatalog.validate(catalog) else {
    fputs("SeedCatalog validation failed\n", stderr)
    exit(1)
}
let encoder = JSONEncoder()
encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
let data = try encoder.encode(catalog)
try FileManager.default.createDirectory(
    atPath: (outputPath as NSString).deletingLastPathComponent,
    withIntermediateDirectories: true
)
try data.write(to: URL(fileURLWithPath: outputPath))
print("Wrote \(catalog.count) puzzles to \(outputPath)")
