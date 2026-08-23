# Implementation Plan: Water Flow Animation, Victory Delay & Sound Effects

**Track ID**: `water_flow_animation_20260823`

## Phase 1: Victory Input Lock & 3-Second Admiration Delay
- [ ] Task: Update `GameState` and `GameNotifier` with `isVictoryCelebrating` and `isLocked` flags
- [ ] Task: Disable tile tap callbacks immediately upon win detection in `GameScreen`
- [ ] Task: Add 3-second celebration admiration timer before triggering `VictoryOverlay`
- [ ] Task: Create whole-board fluid glow pulse and confetti wave during admiration window
- [ ] Task: Phase Verification & Checkpoint — manual and automated test of win delay

## Phase 2: BFS Fluid Propagation Animation
- [ ] Task: Compute BFS depth map from source for all connected tiles in `PathFinder`
- [ ] Task: Create `FluidFlowController` / animated fill provider with configurable speed factor
- [ ] Task: Update `TileWidget` and `PipePainter` to render progressive fluid fill according to wave progress
- [ ] Task: Add animated bubble/sparkle pulse when ampolla fills with fluid
- [ ] Task: Phase Verification & Checkpoint — test chain reactions (1 to N tiles connecting at once)

## Phase 3: Interactive Audio & Sound Effects
- [ ] Task: Integrate lightweight audio manager for sound effects (clicks, fluid whoosh, win fanfare)
- [ ] Task: Wire tile tap sound to `TileWidget` rotation
- [ ] Task: Wire dynamic water flow sound to fluid propagation
- [ ] Task: Wire victory fanfare to level completion
- [ ] Task: Phase Verification & Checkpoint — audio playback verification on Web and Mobile

## Phase 4: Verification & Automated QA
- [ ] Task: `flutter analyze` — 0 issues
- [ ] Task: `just test` — 100% pass rate
- [ ] Task: Run `just qa` automated browser inspection
- [ ] Task: Bump version in all 4 files (`version.dart`, `VERSION`, `pubspec.yaml`, `CHANGELOG.md`)
- [ ] Task: Deploy to GitHub Pages + verify on localhost
