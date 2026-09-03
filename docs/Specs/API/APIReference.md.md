# SixDoku Engine — Full API Reference  
Shared puzzle engine for iOS + watchOS

This document defines the public API surface for the SixDoku core engine, including the solver, generator, validator, grid utilities, and CloudKit‑ready models.

---

# 1. Modules Overview

```
SharedCore/
 ├── Models/
 ├── Engine/
 │    ├── Solver.swift
 │    ├── Generator.swift
 │    ├── Validator.swift
 │    └── BoxMapping.swift
 └── Utils/
```

---

# 2. Models

## 2.1 `FormatType`
Represents the region layout.

```swift
enum FormatType {
    case twoByThree   // 2 rows × 3 columns per box
    case threeByTwo   // 3 rows × 2 columns per box
}
```

## 2.2 `Difficulty`
```swift
enum Difficulty {
    case easy
    case medium
    case hard
}
```

## 2.3 `GridState`
Represents the current puzzle grid.

```swift
struct GridState {
    var cells: [Int?]   // 36 entries, nil = empty
}
```

## 2.4 `PuzzleDefinition`
Static puzzle definition from catalog.

```swift
struct PuzzleDefinition {
    let puzzleID: String
    let format: FormatType
    let difficulty: Difficulty
    let initialClues: [Int?]
    let solutionGrid: [Int]
}
```

## 2.5 `PuzzleState`
User’s active puzzle.

```swift
struct PuzzleState {
    var puzzleID: String
    var format: FormatType
    var gridState: GridState
    var initialClues: [Int?]
    var isCompleted: Bool
    var lastUpdated: Date
}
```

---

# 3. Box Mapping API

## 3.1 `BoxMapping.boxIndex(for:row:col:)`

```swift
func boxIndex(for format: FormatType, row: Int, col: Int) -> Int
```

Returns the box index (0–5) for a given cell.

---

# 4. Validator API

## 4.1 `Validator.isValidMove(...)`

```swift
func isValidMove(
    grid: GridState,
    row: Int,
    col: Int,
    symbol: Int,
    format: FormatType
) -> Bool
```

Checks row, column, and box constraints.

## 4.2 `Validator.isComplete(...)`

```swift
func isComplete(grid: GridState) -> Bool
```

Returns `true` if no cells are empty.

## 4.3 `Validator.isSolved(...)`

```swift
func isSolved(grid: GridState, solution: [Int]) -> Bool
```

Checks if grid matches solution.

---

# 5. Solver API

## 5.1 `Solver.solve(...)`

```swift
func solve(
    grid: GridState,
    format: FormatType
) -> [Int]?   // returns solution or nil
```

Finds a single valid solution.

## 5.2 `Solver.isUnique(...)`

```swift
func isUnique(
    grid: GridState,
    format: FormatType
) -> Bool
```

Returns `true` if puzzle has exactly one solution.

## 5.3 `Solver.findSolutions(...)`

```swift
func findSolutions(
    grid: GridState,
    format: FormatType,
    maxSolutions: Int
) -> [[Int]]
```

Returns up to `maxSolutions` solutions.

Used for:
- uniqueness check  
- difficulty classification  
- hint system  

---

# 6. Generator API

## 6.1 `Generator.generateSolution(...)`

```swift
func generateSolution(format: FormatType) -> [Int]
```

Generates a full valid 6×6 solution grid.

## 6.2 `Generator.generatePuzzle(...)`

```swift
func generatePuzzle(
    format: FormatType,
    difficulty: Difficulty
) -> PuzzleDefinition
```

Creates a puzzle with:
- initial clues  
- solution grid  
- difficulty  
- unique solution  

## 6.3 `Generator.removeClues(...)