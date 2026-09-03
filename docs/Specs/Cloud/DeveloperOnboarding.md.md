# SixDoku — Developer Onboarding Guide

## 1. Requirements
- Xcode (latest)
- iOS 17+
- watchOS 10+
- CloudKit enabled

## 2. Setup
1. Clone repo  
2. Open project  
3. Enable CloudKit  
4. Run iOS target  
5. Run watchOS target

## 3. Testing Engine
- Run SolverTests
- Run GeneratorTests
- Validate uniqueness

## 4. Adding New Puzzles
- Use Generator.generatePuzzle()
- Add to PuzzleCatalog

## 5. Adding Themes
- Add Theme to ThemeManager
- Update SettingsView

## 6. Adding Symbol Sets
- Add SymbolSet to SymbolSetManager

