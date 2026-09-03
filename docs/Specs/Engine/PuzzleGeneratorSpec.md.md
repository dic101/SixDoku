# SixDoku Puzzle Generator Specification

## 1. Goals
Generate valid, unique 6×6 Sudoku puzzles for both region formats with difficulty tiers.

## 2. Constraints
- Grid: 6×6
- Symbols: 1–6
- Formats:
  - 2×3 boxes
  - 3×2 boxes

## 3. Data Structures
- `grid[6][6] : Int?`
- Box mapping tables
- `PuzzleDefinition`

## 4. Generation Pipeline
### Step 1 — Generate full solution
- Backtracking solver
- Randomized symbol order

### Step 2 — Remove clues
- Target clue count by difficulty
- Remove cell → check uniqueness → keep or revert

### Step 3 — Uniqueness check
- Solver runs with early exit after 2 solutions

## 5. Difficulty Tuning
- Easy: 14–18 clues
- Medium: 12–14 clues
- Hard: 10–12 clues
- Format B requires +1–2 clues

## 6. Catalog Generation
- Generate N puzzles per difficulty per format
- Store initial clues + solution

