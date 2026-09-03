# SixDoku Solver Specification

## 1. Purpose
Solve puzzles, validate moves, enforce uniqueness, support hints.

## 2. Requirements
- Single-solution mode
- Multi-solution detection
- Partial validation
- Format-aware constraints

## 3. Data Structures
- `grid[6][6]`
- Box mapping tables
- `solutionsFound`
- `stopAfterTwo`

## 4. Algorithm
- Find next empty cell
- Try symbols 1–6
- Validate row/column/box
- Recurse
- Detect solution

## 5. Modes
- Solve
- Uniqueness check
- Move validation
- Completion check

## 6. Integration
- Generator uses uniqueness mode
- Gameplay uses validation mode
- Hints use solver logic

