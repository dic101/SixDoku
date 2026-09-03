# SixDoku — Testing Strategy

## 1. Unit Tests
### Solver
- Solve valid puzzles
- Detect multiple solutions
- Detect unsolvable puzzles

### Generator
- Ensure uniqueness
- Ensure clue count matches difficulty

### Validator
- Test row/column/box rules

## 2. UI Tests (iOS)
- Tap cells
- Fill numbers
- Validate completion
- Test theme switching

## 3. UI Tests (watchOS)
- Tap grid
- Use number picker
- Validate haptics

## 4. CloudKit Tests
- Save/load PuzzleState
- Conflict resolution
- Offline queueing

## 5. Performance Tests
- Solver speed
- Generator speed
- CloudKit latency

