# Plan: Keyboard Navigation & Controls

## Phase 1: Focus State & Key Handling
- [ ] Task: Add `focusedTile` state to `GameScreen`
  - [ ] Add `Position? _focusedTile` and `bool _keyboardActive` local state
  - [ ] Wrap game body in `Focus` widget with `FocusNode` (autofocus)
  - [ ] Handle `KeyEvent` via `onKeyEvent` callback
- [ ] Task: Implement navigation key handling
  - [ ] Arrow keys (↑↓←→) move `_focusedTile` with toroidal wrapping
  - [ ] WASD keys as alternate navigation
  - [ ] Space → `rotateTile(focusedTile)` clockwise
  - [ ] Shift+Space → `rotateTileCounterClockwise(focusedTile)` (add to GameNotifier)
  - [ ] R → `resetLevel()`, Escape → `Navigator.pop()`
- [ ] Task: Add `rotateTileCounterClockwise` to GameNotifier
  - [ ] Implement as 3× clockwise rotation (270° = -90°)
- [ ] Task: Phase Verification & Checkpoint
  - [ ] Arrow keys move focus, Space rotates, wrap works, R resets, Esc goes back

## Phase 2: Focus Ring Visual
- [ ] Task: Pass `focusedTile` to GridWidget → PipePainter
  - [ ] Add `Position? focusedTile` parameter to `GridWidget`
  - [ ] Forward to `PipePainter` constructor
- [ ] Task: Render glowing focus ring in PipePainter
  - [ ] Draw rounded rect with theme `flowColor` + `MaskFilter.blur(BlurStyle.outer, 6)`
  - [ ] 2px stroke, slightly inset from tile bounds
  - [ ] Subtle pulse animation via `AnimationController` (opacity 0.6 → 1.0, 800ms)
- [ ] Task: Theme-aware focus color
  - [ ] Use `LevelTheme.flowColor` for ring color (auto-adapts to all 5 themes)
  - [ ] Add `focusRingColor` to `LevelTheme` if contrast is insufficient
- [ ] Task: Phase Verification & Checkpoint
  - [ ] Focus ring visible on all 5 themes, glow animates, disappears on touch

## Phase 3: Touch/Keyboard Mode Switching
- [ ] Task: Auto-detect input mode
  - [ ] On keyboard event → set `_keyboardActive = true`, show focus ring
  - [ ] On touch/pointer event → set `_keyboardActive = false`, hide focus ring
  - [ ] Focus ring only renders when `_keyboardActive == true`
- [ ] Task: Phase Verification & Checkpoint
  - [ ] Touch hides focus, keyboard shows it, no mobile interference

## Phase 4: Tests & Polish
- [ ] Task: Write unit tests
  - [ ] Test toroidal wrapping logic (all 4 edges + corners)
  - [ ] Test key mapping (arrows, WASD, Space, Shift+Space, R, Escape)
  - [ ] Test counter-clockwise rotation (3× clockwise = 1× counter-clockwise)
- [ ] Task: Write widget tests
  - [ ] Test focus ring renders when `focusedTile` is set
  - [ ] Test focus ring hides when `focusedTile` is null
- [ ] Task: Version bump & CHANGELOG
- [ ] Task: Phase Verification & Checkpoint
  - [ ] `flutter analyze` = 0 issues, `flutter test` passes
