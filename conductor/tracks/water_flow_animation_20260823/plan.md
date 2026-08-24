# Implementation Plan: Water Flow Animation, Victory Delay & Sound Effects

**Track ID**: `water_flow_animation_20260823`

## Phase 1: Victory Input Lock & 3-Second Admiration Delay
- [x] Task: Update `GameState` and `GameNotifier` with `isVictoryCelebrating` and `isLocked` flags
- [x] Task: Disable tile tap callbacks immediately upon win detection in `GameScreen`
- [x] Task: Add 3-second celebration admiration timer before triggering `VictoryOverlay`
- [x] Task: Create whole-board fluid glow pulse and confetti wave during admiration window
- [x] Task: Phase Verification & Checkpoint — manual and automated test of win delay

## Phase 2: BFS Fluid Propagation Animation
- [x] Task: Compute BFS depth map from source for all connected tiles in `PathFinder`
- [x] Task: Create `FluidFlowController` / animated fill provider with configurable speed factor
- [x] Task: Update `TileWidget` and `PipePainter` to render progressive fluid fill according to wave progress
- [x] Task: Add animated bubble/sparkle pulse when ampolla fills with fluid
- [x] Task: Phase Verification & Checkpoint — test chain reactions (1 to N tiles connecting at once)

## Phase 3: Interactive Audio & Sound Effects
- [x] Task: Integrate lightweight audio manager for sound effects (clicks, fluid whoosh, win fanfare)
- [x] Task: Wire tile tap sound to `TileWidget` rotation
- [x] Task: Wire dynamic water flow sound to fluid propagation
- [x] Task: Wire victory fanfare to level completion
- [x] Task: Phase Verification & Checkpoint — audio playback verification on Web and Mobile

## Phase 5: Organic Liquid Fluid Simulation (Chaos Jitter, Flow Shimmer & Meniscus)
- [x] Task: Replace deterministic BFS delays with turbulent fluid chaos jitter in `TileWidget`
- [x] Task: Implement animated flowing liquid shimmer & moving caustic highlights in `PipePainter`
- [x] Task: Add fluid surge meniscus (pressure front) and dynamic micro-bubbles inside connected pipes
- [x] Task: Add slosh/bounce easing on fluid arrival
- [x] Task: Phase Verification & Checkpoint — visual inspection on Web & Mobile

