# SixDoku — UI Interaction Rules

## 1. Grid Interaction
- Tap a cell → selects it.
- Selected cell is highlighted with theme accent color.
- Tap a number → fills selected cell.
- Long‑press (iOS only) → opens pencil mark menu (future).
- WatchOS: number picker appears automatically at bottom.

## 2. Number Picker
### iOS
- Horizontal bar: 1–6 + Erase.
- Haptic tap on selection.
- Disabled numbers (violating constraints) appear dimmed.

### watchOS
- Compact horizontal picker.
- Auto-dismiss after selection.

## 3. Error Feedback
- Invalid move → brief shake animation (iOS).
- Invalid move → subtle haptic (watchOS).
- No modal alerts for mistakes.

## 4. Completion Feedback
- Row/column filled → light haptic.
- Puzzle completed → celebratory haptic + full-screen celebration (iOS):
  `CompletionCelebrationView` overlay — 96pt `party.popper.fill` in theme
  accent, `largeTitle` "Puzzle Complete!", ~60-piece falling confetti,
  spring pop-in; dismiss via "Keep Admiring". A small persistent
  `checkmark.seal` "Completed" label remains under the grid.
- watchOS: big solved header — 44pt `party.popper.fill` + `title3.bold` "Solved!".

## 5. Accessibility
- Large cell mode.
- High contrast mode.
- Color-blind safe themes.
- VoiceOver reads:
  - “Row 2 Column 4, empty”
  - “Placed 5 in Row 2 Column 4”

## 6. Layout Rules
### iOS
- Grid centered.
- Number pad pinned bottom.
- Safe area respected.

### watchOS
- Grid fills screen.
- Number picker pinned bottom.
- No scroll.

## 7. Library Listing
- Each row shows a green `checkmark.seal.fill` marker (icon-only, "Completed"
  VoiceOver label) when that puzzle is solved.
- Markers refresh on every Library appear (post-solve safe) and derive from
  the local completed-IDs set (latest state + sync queue merged in).

