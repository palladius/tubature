# Changelog

All notable changes to FlowConnect (Tubature) are documented here.

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
