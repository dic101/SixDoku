# SixDoku — Product Definition Document (PDD)

## 1. Purpose
SixDoku delivers a fast, satisfying Sudoku experience optimized for Apple Watch and expanded on iOS. It uses a 6×6 grid with two valid region formats (2×3 and 3×2) and supports quick-play, haptics, puzzle continuity, and future extensibility.

## 2. Core Concept
- 6×6 grid
- Symbols 1–6
- Two region formats:
  - Format A: 2×3 boxes
  - Format B: 3×2 boxes
- Standard Sudoku constraints:
  - Each row contains 1–6
  - Each column contains 1–6
  - Each box contains 1–6

## 3. Supported Region Formats
### Format A — 2×3 Boxes
```
+-----+-----+
|1 2 3|4 5 6|
|1 2 3|4 5 6|
+-----+-----+
|1 2 3|4 5 6|
|1 2 3|4 5 6|
+-----+-----+
|1 2 3|4 5 6|
|1 2 3|4 5 6|
+-----+-----+
```

### Format B — 3×2 Boxes
```
+---+---+---+
|1 2|3 4|5 6|
|1 2|3 4|5 6|
|1 2|3 4|5 6|
+---+---+---+
|1 2|3 4|5 6|
|1 2|3 4|5 6|
|1 2|3 4|5 6|
+---+---+---+
```

## 4. Key Features
- Dual-format puzzle engine
- Auto-save puzzle state
- Haptic feedback (watch + iOS)
- Puzzle library
- Puzzle sharing via ID
- Stats tracking
- iOS companion app with full gameplay

## 5. iOS App Overview
- Full grid gameplay
- Puzzle library browser
- Stats dashboard
- Sync with watchOS
- Future: themes, symbol sets, daily puzzles

## 6. Technical Requirements
- Shared puzzle engine module
- SwiftUI UI layers
- CloudKit sync
- Local persistence via AppStorage

## 7. Puzzle Generation
- Backtracking solver
- Uniqueness enforcement
- Difficulty via clue count
- Format-aware box mapping

## 8. MVP Scope
Included:
- Dual formats
- Puzzle library
- Sync
- Stats
- Haptics

Excluded:
- Themes
- Daily puzzle
- Achievements
- Undo/redo

## 9. Success Criteria
- Smooth gameplay on watch + iOS
- Reliable sync
- Distinct format feel
- Strong replayability

