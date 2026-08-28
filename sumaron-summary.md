---
sumaron_version: 0.1.0
date: 2026-08-27
path: /Users/riccardo/bin/sumaron
hostname: mini-lobby
timestamp: 2026-08-27T12:46:29+02:00
model: gemini-flash-latest
files:
  - AGENTS.md
  - CHANGELOG.md
  - README.md
  - TODO.md
  - assets/voices/README.md
  - assets/voices/voices.json
  - conductor/index.md
  - conductor/product-guidelines.md
  - conductor/product.md
  - conductor/tech-stack.md
  - conductor/tracks.md
  - conductor/workflow.md
  - docs/FlowConnect.md
  - web/index.html
  - web/manifest.json
---

# 🚰 Tubature (*FlowConnect*) — Codebase Summary

**Tubature** is an open-source, kid-friendly fantasy pipe-puzzle game built with **Flutter & Riverpod**. Starring *Riccardo the Dungeon Plumber* and his companions, players rotate grid-based conduits to channel magical water from a source tile through **every single tile** on the board (spanning tree mechanics).

---

## 🌟 Key Features & Mechanics

- 🧩 **Pure Spanning-Tree Puzzle Mechanics**: No sink tile—every tile on the grid must be connected to the water source to achieve victory. Levels are algorithmically generated via randomized DFS to guarantee solvability.
- 🧙‍♂️ **Character Lore & Themes**: Medieval D&D-inspired themes (*Dragon & Gems*, *Wizard & Alchemy Lab*, *Crystal Caves*, *Treasure Vault*, *Aqueduct*).
- 🧪 **Collectibles & Rarity System**: "Magic Cauldron" image reveals inside ampolla (flask/dead-end) tiles with a 4-tier rarity system (*Common*, *Uncommon*, *Rare*, *Legendary*).
- 🎙️ **Rich Audio & Ferrarese Voice Engine**:
  - Procedural Web Audio synthesizer for ratchet clicks, bubbling fluid rushes, and fanfare.
  - Authentic voice clips in Ferrarese/Romagnolo Italian dialect (voiced by Alessandro Verlato and TTS engines) with an animated talking plumber avatar (*Ermete*).
- 🤖 **Automated Solver & QA Suite**: Built-in deterministic O(n) solver exposed via a JS bridge (`window._tubatureGrid`) and automated recording scripts (`tool/record_gameplay.py`) for automated visual testing and gameplay capture.
- 📱 **Kid-Friendly & Mobile-First**: Large tap targets ($\ge 56\text{dp}$), locked 1:1 mobile scaling, keyboard navigation (WASD/Arrows + Space) on Web/Desktop, and responsive layouts.

---

## 🛠️ Tech Stack & Architecture

- **Language & Framework**: Dart & Flutter (targeting Web, Android, and iOS).
- **Game Engine**: Pure Flutter widgets and `CustomPainter` on Canvas (no external heavy game engine).
- **State Management**: `flutter_riverpod` (v2.x).
- **Audio Pipeline**: Embedded Web Audio API synthesis (`_tubatureAudio` inside `web/index.html`) + HTML5 audio playback for local voice assets.
- **Project Structure**: Strict separation between pure Dart game logic (models, solvers, generators) and Flutter UI/painters.

---

## 📁 Key Files & Directories

| Path | Description |
|---|---|
| `AGENTS.md` | Core guidelines, conventions, test requirements ($\ge 90\%$ coverage), and AI agent instructions. |
| `README.md` | Public-facing documentation, quick-start commands, demo animations, and live game links. |
| `CHANGELOG.md` | Detailed version history from v0.1.0 up to the latest releases (v2.7+). |
| `TODO.md` | Backlog tracking audio break/disconnect effects and cross-repository task aggregator ideas. |
| `docs/FlowConnect.md` | Original game design specification and mechanics guide (in Italian). |
| `conductor/` | Feature track management, product guidelines, workflow specs, and technical context. |
| `assets/voices/` | Audio assets catalog (`voices.json`), generation scripts (`generate_voices.py`), and documentation. |
| `web/` | Web deployment artifacts (`index.html`, `manifest.json`, favicons) and the JavaScript Web Audio bridge. |

---

## 🚀 Deployment & Quality Assurance

- **Testing**: Test-Driven Development (TDD) approach with $\ge 90\%$ logic test coverage and automated headless Chrome visual QA (`tool/qa_runner.py`).
- **Deployment**:
  - **Live Web**: Hosted on GitHub Pages via `just deploy` at [https://palladius.github.io/tubature/](https://palladius.github.io/tubature/)
  - **Local Development**: `just serve` (runs local server on `http://localhost:8765`).