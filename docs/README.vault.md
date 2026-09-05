# SixDoku  
A dual‑format 6×6 Sudoku experience for **iOS** and **watchOS**, built with SwiftUI and powered by a shared puzzle engine, CloudKit sync, and a modern modular architecture.

---

## 📌 Overview
SixDoku is a fast, elegant Sudoku variant designed for quick play on Apple Watch and full‑featured gameplay on iOS. It supports **two valid 6×6 region formats**:

- **2×3 boxes** (default)
- **3×2 boxes**

Both formats follow standard Sudoku rules and are backed by a shared solver, generator, and CloudKit‑based sync layer.

---

## 🎯 Core Features
- Dual‑format Sudoku (2×3 and 3×2)
- Shared puzzle engine (solver + generator)
- CloudKit sync between iOS and watchOS
- Auto‑save puzzle state
- Puzzle library with difficulty tiers
- Stats tracking
- Haptics on both platforms
- Future‑ready architecture (themes, daily puzzles, achievements)

---

## 🧩 Architecture Summary
SixDoku uses a **shared core module** for all puzzle logic and services, with **platform‑specific SwiftUI layers** for iOS and watchOS.

### Key modules:
- **SharedCore** — puzzle engine, solver, generator, models  
- **SharedServices** — CloudKit, settings, persistence  
- **iOSApp** — full gameplay UI, library, stats  
- **WatchApp** — compact grid UI, quick‑play interactions  

See:  
- **[SwiftUI Architecture](ca://s?q=Design_SwiftUI_architecture_for_SixDoku)**  
- **[Puzzle Generator Spec](ca://s?q=Write_puzzle_generator_spec_for_SixDoku)**  
- **[Solver Spec](ca://s?q=Design_SixDoku_solver_spec)**  
- **[CloudKit Schema](ca://s?q=Design_CloudKit_schema_for_SixDoku)**  

---

## 📁 Folder Structure
The project is organized for clarity, modularity, and future expansion.

```
SixDoku/
│
├── README.md
├── docs/
│   ├── PDD_SixDoku.md
│   ├── PuzzleGeneratorSpec.md
│   ├── SolverSpec.md
│   ├── CloudKitSchema.md
│   ├── SwiftUIArchitecture.md
│   └── iOSRoadmap.md
│
├── SharedCore/
│   ├── Models/
│   │   ├── GridState.swift
│   │   ├── PuzzleDefinition.swift
│   │   ├── PuzzleState.swift
│   │   ├── FormatType.swift
│   │   └── Difficulty.swift
│   │
│   ├── Engine/
│   │   ├── Solver.swift
│   │   ├── Generator.swift
│   │   ├── Validator.swift
│   │   └── BoxMapping.swift
│   │
│   └── Utils/
│       ├── GridUtils.swift
│       └── Randomization.swift
│
├── SharedServices/
│   ├── CloudKit/
│   │   ├── CloudKitService.swift
│   │   └── SyncManager.swift
│   │
│   ├── Settings/
│   │   └── SettingsService.swift
│   │
│   └── Persistence/
│       └── PersistenceService.swift
│
├── iOSApp/
│   ├── Views/
│   │   ├── HomeView.swift
│   │   ├── PuzzleView.swift
│   │   ├── LibraryView.swift
│   │   ├── StatsView.swift
│   │   └── SettingsView.swift
│   │
│   ├── ViewModels/
│   │   ├── HomeViewModel.swift
│   │   ├── PuzzleViewModel.swift
│   │   ├── LibraryViewModel.swift
│   │   ├── StatsViewModel.swift
│   │   └── SettingsViewModel.swift
│   │
│   └── Components/
│       ├── SudokuGridView.swift
│       ├── NumberPadView.swift
│       ├── FormatSelectorView.swift
│       └── PuzzleCardView.swift
│
└── WatchApp/
    ├── Views/
    │   ├── WatchHomeView.swift
    │   ├── WatchFormatSelectorView.swift
    │   └── WatchPuzzleView.swift
    │
    ├── ViewModels/
    │   ├── WatchHomeViewModel.swift
    │   ├── WatchPuzzleViewModel.swift
    │   └── WatchFormatViewModel.swift

---

## 🚢 Status (2026-09-04)
- **Store name: 6Doku** ("SixDoku" taken) — bundles `com.sixdoku.app` / `com.sixdoku.app.watch`
- **First TestFlight: 1.0 (1)** — repo `dic101/SixDoku` @ `141cbf1`, 23/23 tests green
- Since MVP: 48-puzzle seed catalog, watch input redesign (picker page), 6 iCloud-synced grid themes, VoiceOver audit, AppIcon/LaunchScreen
- Session log: `[[01-Daily/2026-09-04]]`
- Before inviting testers: deploy CloudKit schema (`PuzzleCatalog`, `PuzzleState`, `UserStats`) to **Production**

## ✨ Update (2026-09-05, unreleased — build still 1.0 (1))
- Big completion moment: full-screen `CompletionCelebrationView` (96pt party popper, confetti, spring pop-in, dismissible) on iOS; enlarged "Solved!" header on watch
- Library completed markers: green `checkmark.seal.fill` per solved row, backed by local completed-IDs ledger (`PersistenceService` + `LibraryViewModel.refreshCompleted()`); 38/38 tests green
- Specs updated: `UIInteractionRules` (§4, §7), `ViewModelContracts` (§2–3), `SwiftUIArchitecture` (§3–4a), `APIReference` (§7)