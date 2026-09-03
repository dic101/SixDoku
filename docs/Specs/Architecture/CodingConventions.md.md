# SixDoku — Coding Conventions

## 1. Swift Style
- CamelCase for variables
- PascalCase for types
- No force unwraps
- Use `guard` for early exits

## 2. ViewModel Rules
- One ViewModel per screen
- Use `@Published` for UI state
- Use async/await for CloudKit

## 3. Folder Naming
- Views/
- ViewModels/
- Components/
- Models/
- Engine/
- Services/

## 4. Error Handling
- Use SixDokuError
- No fatal errors
- Graceful fallback

## 5. Comments
- Use doc comments for public API
- No inline comments unless necessary

