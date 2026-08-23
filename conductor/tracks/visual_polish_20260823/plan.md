# Implementation Plan: Visual Polish & Dead-End Redesign

**Track ID**: `visual_polish_20260823`

## Phase 1: Dead-End "Ampolla" Redesign
- [ ] Task: Design ampolla rendering using outward-arc (`addArc` positive sweep)
- [ ] Task: Implement in `PipePainter._drawDeadEndPipe()` with all 4 rotations
- [ ] Task: Test connected (blue ampolla) vs disconnected (gray flask) states
- [ ] Task: Verify clipRect prevents bleeding into neighbor cells
- [ ] Task: Phase Verification — screenshot all 4 rotations

## Phase 2: Home Screen Difficulty Chooser
- [ ] Task: Add `DifficultySelector` widget to home screen
- [ ] Task: Show grid size per option ("Easy 6×6", "Medium 7-8", "Hard 9-10")
- [ ] Task: Persist selection with `SharedPreferences`
- [ ] Task: Wire selected difficulty into `GameNotifier.startGame()`
- [ ] Task: Update existing auto-progression to respect manual selection
- [ ] Task: Write unit tests for difficulty persistence
- [ ] Task: Phase Verification — play through all 3 difficulties

## Phase 3: Color Themes & Polish
- [ ] Task: Warmer background gradient per creature theme
- [ ] Task: Pipe edge smoothing (anti-aliased strokes)
- [ ] Task: Larger pipe endpoints at cell edges for visual joining
- [ ] Task: Enhanced win celebration (particle effects)
- [ ] Task: Phase Verification — visual QA on web + Android

## Phase 4: Final Verification
- [ ] Task: `flutter analyze` — 0 issues
- [ ] Task: `flutter test` — all pass
- [ ] Task: Update VERSION, CHANGELOG, pubspec.yaml, version.dart
- [ ] Task: Deploy to GitHub Pages + localhost test
