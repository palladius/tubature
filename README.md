# 🚰 Tubature — FlowConnect

A pipe-puzzle game where you rotate tiles to connect a **Source** to a **Sink**, letting color flow through the grid.

Built with **Flutter/Dart** for Android, iOS, and Web.

## Game Concept

**FlowConnect** is a grid-based puzzle game. Tap tiles to rotate them 90° clockwise and create an unbroken path from Source to Sink. Tiles fill with color as they connect, giving instant visual feedback.

### Tile Types (v1.1)
- **Line (`I`)** — Straight segment (2 rotations)
- **Corner (`L`)** — 90° curve (4 rotations)
- **T-Junction (`T`)** — Three-way intersection (4 rotations)
- **Source** ⊕ — Fixed starting point (1 opening)
- **Sink** ⊗ — Fixed endpoint (1 opening)

### Difficulty Progression
1. **Easy** — `I` and `L` tiles, small grids
2. **Medium** — `T` and `+` tiles, larger grids
3. **Hard** — Bridges/Tunnels introduced
4. **Expert** — Portals + all mechanics combined

## Tech Stack

- **Language**: Dart
- **Framework**: Flutter
- **Platforms**: Android, iOS, Web (HTML5)
- **Game logic**: Pure Dart (no game engine needed for a tile puzzle)
- **State management**: TBD (Riverpod or BLoC)

## Project Structure

```
lib/
├── main.dart
├── models/          # Tile, Grid, Level data models
├── logic/           # Game logic, path verification (BFS/DFS)
├── screens/         # Game screen, level select, menu
├── widgets/         # TileWidget, GridWidget, FlowAnimation
└── levels/          # Level definitions (JSON or Dart)
```

## Docs

- [Original Game Design (Italian)](docs/FlowConnect.md) — from Obsidian
- [Design Images](docs/design/) — 5 reference mockups

## Status

🚧 **In development** — Setting up with Conductor for spec-driven development.

## Version

1.0.0
