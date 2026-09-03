# SixDoku — Daily Puzzle System

## 1. Daily Puzzle Rules
- One puzzle per day
- Same puzzle across all devices
- Resets at midnight local time

## 2. CloudKit Fields
- `isDailyPuzzle: Bool`
- `dailyDate: Date`

## 3. Streak Logic
- If user completes daily puzzle:
  - streakDays++
  - lastPlayed = today
- If user misses a day:
  - streakDays = 0

## 4. Caching
- Cache daily puzzle locally
- Refresh on app launch

