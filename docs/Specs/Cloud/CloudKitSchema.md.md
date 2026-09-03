# SixDoku CloudKit Schema

## Record Types
### 1. PuzzleCatalog (Public DB)
- puzzleID: String
- format: String
- difficulty: String
- initialClues: List<Int>
- solutionGrid: List<Int>
- createdAt: Date
- version: Int

### 2. PuzzleState (Private DB)
- userID: Reference
- puzzleID: String
- format: String
- gridState: List<Int>
- initialClues: List<Int>
- lastUpdated: Date
- deviceType: String
- isCompleted: Bool
- completionTime: Int
- mistakes: Int (future)

### 3. UserStats (Private DB)
- userID: Reference
- completedCount: Int
- formatUsage: Dictionary
- bestTimes: Dictionary
- streakDays: Int
- lastPlayed: Date
- themePreference: String
- symbolSetPreference: String

## Sync Behavior
- Timestamp-based conflict resolution
- Watch uses lightweight deltas
- iOS pushes full state

