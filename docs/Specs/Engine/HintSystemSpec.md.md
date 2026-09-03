# SixDoku — Hint System Specification

## 1. Hint Types
- Single forced cell
- Row/column elimination
- Box elimination
- Contradiction detection
- Next logical step (future)

## 2. Hint Engine Inputs
- Current grid
- Format
- Solution grid (optional)

## 3. Hint Engine Outputs
- Cell coordinate
- Suggested symbol
- Explanation (future)

## 4. Rules
- Never reveal random numbers
- Only reveal logically deducible moves
- Update stats: hintsUsed++

