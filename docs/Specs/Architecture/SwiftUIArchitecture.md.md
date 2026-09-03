# SixDoku SwiftUI Architecture

## 1. High-Level Structure
SixDokuApp
 ├── SharedCore
 ├── SharedServices
 ├── iOSApp
 └── WatchApp

## 2. SharedCore
- Models
- Puzzle engine
- Solver
- Generator
- Utilities

## 3. SharedServices
- CloudKitService
- SettingsService
- PersistenceService

## 4. iOS View Hierarchy
- HomeView
- PuzzleView
- LibraryView
- StatsView
- SettingsView

## 5. iOS ViewModels
- HomeViewModel
- PuzzleViewModel
- LibraryViewModel
- StatsViewModel
- SettingsViewModel

## 6. watchOS View Hierarchy
- WatchHomeView
- WatchFormatSelectorView
- WatchPuzzleView

## 7. watchOS ViewModels
- WatchHomeViewModel
- WatchPuzzleViewModel
- WatchFormatViewModel

## 8. Shared Engine Integration
- solve()
- isValidMove()
- isComplete()
- generatePuzzle()

## 9. CloudKit Integration
- savePuzzleState()
- loadLatestPuzzleState()
- updateStats()

