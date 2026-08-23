# Changelog

All notable changes to FlowConnect (Tubature) are documented here.

## 2.0.4 — 2026-08-23

### UI/UX & Quality Improvements 🧪
- **Fixed Button Text Clipping** — wrapped Play button label in `FittedBox` with adaptive scaling, preventing multi-line overflow when difficulty names are displayed
- **Enhanced Difficulty Chip Contrast** — increased contrast on active chips (deep emerald, amber, and berry backgrounds with crisp bold white text)
- **Automated Visual QA Suite** — added `tool/qa_runner.py` and `just qa` for continuous headless visual inspection and playability regression checks

## 2.0.3 — 2026-08-23

### Visual & UX Improvements 🎨
- **Seamless Corner Pipes** — removed the ugly circular center juncture blob; corners now render as clean continuous rounded elbows
- **Dead-End "Ampolla" Redesign** — terminations now look like sealed glass magic flasks/bulbs with liquid fills and specular glass highlights
- **Home Screen Difficulty Selector** — kids can now choose Auto ⚡, Easy 🟢 (6×6), Medium 🟡 (7-8), or Hard 🔴 (9-10) directly from home
- **Clean T-Junctions & Crossings** — layered drawing prevents seams at pipe intersections

## 2.0.2 — 2026-08-23

### Bug Fixes 🔧
- **Fixed pipe bleeding** — canvas clipping prevents thick strokes from overflowing into neighboring cells
- **Removed glow effect** — `MaskFilter.blur` doesn't respect `clipRect` on Flutter Web CanvasKit
- **Reverted corner pipes** — back to original two-line + center-circle style (arcs were broken)
- **Robust deploy** — `just deploy` copies build to /tmp before branch switch, auto-rebuilds for localhost

## 2.0.1 — 2026-08-23

### Visual Improvements 🎨
- **Smooth corner pipes** — L-tiles now use quarter-circle arcs instead of ugly 3-piece joints
- **Better T-junctions** — straight-through pipe with clean branch, no more circle blobs
- **Bigger grids** — Easy 6×6, Medium 7-8, Hard 9-10 (kids said it was too easy!)
- **Direction-biased DFS** — 60% same-direction preference creates longer chains, fewer dead-ends
- **Faster difficulty ramp** — Medium after 2 wins, Hard after 5

## 2.0.0 — 2026-08-23

### 💥 BREAKING: New Game Mechanics
- **Removed Sink** — no more endpoint tile. Only the Source remains.
- **Fill ALL tiles** — win condition is now: every tile on the grid must be connected to the source
- **Spanning tree level generation** — randomized DFS creates grids where ALL tiles form one connected network when correctly rotated. Every generated level is guaranteed solvable!
- **Dead-end tiles** — new cap tile type with 1 opening, for tree leaf nodes

### Added
- 💧 **Progress indicator** — shows "X/Y" connected tiles count during gameplay
- 📌 **Version footer** — `v2.0.0` shown on home screen
- 🔍 **Pinch-to-zoom** — viewport allows 0.5x to 5x zoom for accessibility
- 🚀 **GitHub Pages** — playable at https://palladius.github.io/tubature/
- 📦 **`just deploy`** — one-command deployment to GitHub Pages
- 📦 **`just serve`** — local web server on port 8765

### Removed
- ❌ `TileType.sink` — removed from tile enum entirely
- ❌ Sink creatures (gems, dungeon, starship) — only source creatures remain
- ❌ Source-to-sink path generation — replaced by spanning tree

## 1.1.0 — 2026-08-22

### Fixed
- 🐛 **CRITICAL: Levels now have solutions!** — Sink opening was pointing outward (off the grid), making every generated level unsolvable
- 🐛 **CRITICAL: Path now connects through source/sink openings** — Path generator now ensures the pipe path enters through the source's opening direction and arrives at the sink's opening direction
- 🐛 **Pre-shuffle solution verification** — Generator now verifies the grid is actually solved before shuffling, rejecting bad generations

### Changed
- ❌ **Removed cross (+) tiles** — They're rotationally symmetric (rotating does nothing), which confuses players and makes the puzzle less interesting
- 📈 **Progressive difficulty** — Single "PLAY" button now auto-escalates: Easy (levels 1-3) → Medium (levels 4-7) → Hard (levels 8+)
- 🏠 **Simplified home screen** — One big PLAY button + Tutorial, instead of separate Easy/Medium buttons
- 📊 **Level counter in top bar** — Shows "Level 5 • Medium" instead of just difficulty name
- 🧠 **More interesting paths** — BFS now shuffles directions for varied, non-trivial path layouts

### Added
- 🧪 **55+ tests** — Up from 29, including gameplay simulation, generator diagnostics, DFS-based solvability proof, progressive difficulty, and edge cases

## 1.0.0 — 2026-08-22

### Added
- 🎮 **Full playable game** — pipe-puzzle with tap-to-rotate mechanics
- 🐉 **3 creature themes**: Dragon→Gems, Wizard→Dungeon, Space→Starship
- 📐 **Grid sizes**: Easy (5×5), Medium (6×6, 7×7)
- 🧠 **Algorithmic level generator** with guaranteed solvability
- 📖 **10 tutorial levels** of increasing complexity
- 🎨 **5 color palettes**: Emerald, Purple, Blue, Orange, Teal
- ✨ **Victory celebration** with confetti and multilingual text (MAGNIFICO/BRAVO/WOW)
- 🎯 **Riverpod state management** for clean, testable architecture
- 🧪 **29 unit tests** with 90%+ coverage on game logic
- 📱 **Android-first** with 56dp+ kid-friendly tap targets
- 🌐 **Web build** for Chrome browser testing
- 🚰 **CustomPainter pipe rendering** with chunky, colorful, glowing pipes
- 🦄 **Creature painters** — Dragon, Wizard, Rocket, Gems, Dungeon, Starship
- 🔄 **Smooth rotation animation** (200ms) with scale pulse feedback
- 📊 **Move counter** in-game

## 0.1.0 — 2026-08-22

- Initial project setup
- Imported FlowConnect game design doc from Obsidian
- Copied 5 design reference images
- Chose Flutter/Dart as tech stack (Android + iOS + Web)
- Initialized git repo at ~/git/tubature/
