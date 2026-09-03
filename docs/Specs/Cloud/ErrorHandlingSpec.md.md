# SixDoku — Error Handling & Edge Cases

## 1. CloudKit Errors
### Types
- Network unavailable
- Permission denied
- Record conflict
- Serialization failure

### Behavior
- Retry silently (3 attempts)
- If still failing:
  - iOS: banner “Sync delayed”
  - watchOS: no banner, silent fallback

## 2. Puzzle Errors
- Invalid grid → reset puzzle
- Non-unique puzzle → regenerate
- Unsolvable puzzle → regenerate

## 3. User Errors
- Invalid move → shake/haptic
- Erase clue cell → blocked

## 4. Offline Mode
- Use local persistence only
- Queue CloudKit writes
- Sync when online

