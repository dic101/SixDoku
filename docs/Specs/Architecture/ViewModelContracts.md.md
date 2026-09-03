# SixDoku — ViewModel Behavior Contracts

## 1. HomeViewModel
### Inputs
- App launch
- Resume tap
- New puzzle tap

### Outputs
- Current puzzle summary
- Last used format

### Responsibilities
- Load latest PuzzleState
- Route to PuzzleView
- Provide format selection

---

## 2. PuzzleViewModel
### Published Properties
- `gridState`
- `selectedCell`
- `isCompleted`
- `hintsAvailable` (future)
- `theme`

### Methods
- `applyMove(row, col, symbol)`
- `validateMove(row, col, symbol)`
- `checkCompletion()`
- `saveState()`
- `loadState()`

### Side Effects
- CloudKit sync
- Haptic triggers
- Stats updates

---

## 3. LibraryViewModel
### Responsibilities
- Fetch puzzle catalog
- Filter by format/difficulty
- Load puzzle preview

---

## 4. StatsViewModel
### Responsibilities
- Load UserStats
- Compute streaks
- Compute averages
- Update on puzzle completion

---

## 5. SettingsViewModel
### Responsibilities
- Manage theme
- Manage symbol set
- Manage format preference

