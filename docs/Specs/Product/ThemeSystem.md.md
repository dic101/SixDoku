# SixDoku — Theme & Symbol System

## 1. Theme Model
```swift
struct Theme {
    let name: String
    let background: Color
    let gridLines: Color
    let cellFill: Color
    let accent: Color
    let numberColor: Color
}
```

## 2. Symbol Set Model
```swift
struct SymbolSet {
    let name: String
    let symbols: [String] // maps to 1–6
}
```

## 3. Sync Rules
- Theme stored in UserStats
- Symbol set stored in UserStats
- Sync across devices

## 4. Rendering Rules
- Grid uses theme colors
- Number pad uses accent color
- Symbols map to numbers internally

