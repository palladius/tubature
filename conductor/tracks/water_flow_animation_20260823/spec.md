# Track Specification: Water Flow Animation, Victory Delay & Sound Effects

**Track ID**: `water_flow_animation_20260823`  
**Status**: New  
**Priority**: High  

## Overview
Adds dynamic water flow animation to give the player a visceral sense of water advancing through the pipe network from the source. Includes a 3-second victory admiration delay where input is locked while a full-network fluid celebration wave plays before displaying the victory modal, plus interactive sound effects (pipe clicks, water flow whoosh, and victory fanfare).

---

## Functional Requirements

### 1. Victory Input Lock & 3-Second Board Admiration 🏆
- **Input Lock:** The moment `WinChecker.checkWin()` evaluates to `true`, immediately lock user tile rotations (`isLocked = true`) to prevent accidental taps while celebrating.
- **Admiration Delay:** Delay the appearance of the `VictoryOverlay` by **3 seconds** (N=3s).
- **Celebration Wave:** During the 3-second window, trigger a pulsing fluid glow wave passing through all connected pipes and ampolle from the source, accompanied by board-level confetti/sparkles.
- **Victory Reveal:** After 3 seconds, smoothly fade in the `VictoryOverlay` with score and next level options.

### 2. Fluid Flow Propagation Animation 🌊
- **BFS Depth-Based Flow:** When rotating a tile connects new branches to the source, animate the fluid filling incrementally based on distance (BFS depth) from the source tile.
- **Configurable Speed Factor:** Expose a tunable animation duration (e.g. 120ms per tile step) allowing rapid, satisfying chain reactions when multiple tiles connect at once.
- **Ampolla Fill Reaction:** Dead-end ampolla bulbs light up with a bubble pop/sparkle when the fluid wave reaches them.

### 3. Audio & Sound Effects 🎵
- **Tile Click:** Crisp click/ratchet sound when tapping and rotating a pipe.
- **Water Flow:** Organic water bubbling/whoosh sound playing as the fluid propagates through newly connected tiles (randomized variations to stay fresh).
- **Victory Fanfare:** Cheerful completion chord/jingle when the puzzle is solved.

---

## Non-Functional Requirements
- Maintain smooth 60 FPS performance on Flutter Web, Android, and iOS.
- Web audio compatibility across desktop and mobile browsers.
- Game logic remains pure Dart and 100% unit-testable.

---

## Acceptance Criteria
- [ ] Rotating a tile to complete the level immediately locks input.
- [ ] 3-second admiration delay displays full-board fluid wave before victory card appears.
- [ ] Connecting 1-N tiles shows sequential fluid flow advancing from source outwards.
- [ ] Rotation clicks, water flow sounds, and victory jingles play correctly.
- [ ] `flutter analyze` passes with 0 issues.
- [ ] `just test` passes with 100% success rate.
