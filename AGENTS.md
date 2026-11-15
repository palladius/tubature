# FlowConnect / Tubature — Agent Instructions

## Project Overview
Tubature is a pipe-puzzle game built with Flutter/Dart. The player rotates tiles on a grid so that water from the Source flows through **every single tile** on the board. There is no Sink — the goal is to fill ALL pipes.

## Tech Stack
- **Language**: Dart
- **Framework**: Flutter (cross-platform: Android, iOS, Web)
- **No external game engine** — pure Flutter widgets + Canvas for rendering
- **State management**: Riverpod

## Conventions
- Follow Dart/Flutter style guide (effective_dart)
- Use `flutter analyze` and `flutter test` for validation
- Game logic must be pure Dart (no Flutter dependencies) for easy testing
- Separate models, logic, screens, and widgets into distinct directories
- Version constant in `lib/version.dart` — update on every release

## Game Mechanics (v2.0+)
- **Source only** — no Sink. Source is fixed on a grid edge.
- **Win condition**: ALL tiles connected to the source via matching pipe openings
- **Tile types**: line (I), corner (L), tee (T), dead-end (cap)
- **Level generation**: Randomized DFS spanning tree covering ALL grid cells
- **Themes**: 3 creature themes (Dragon 🐉, Wizard 🧙, Space 🚀)
- **Difficulty**: Progressive — Easy (5×5) → Medium (6×6, 7×7) → Hard (8×8)

## Design Reference
- Original Italian spec: `docs/FlowConnect.md`
- Design mockups: `docs/design/FlowConnect_*.jpg`

## Quality & Testing
- **Minimum 90% unit test coverage** on all game logic (models, path verification, level generation)
- Run `flutter test --coverage` and verify with `lcov`
- AI agent must be able to **play the game visually via browser** (Web build) to verify playability end-to-end
- All PRs must pass `flutter analyze` (zero warnings) + `flutter test` before merge
- **Every generated level MUST be solvable** — verified by pre-shuffle WinChecker
- **Solvable = ALL tiles connected** (not just source-to-sink path)

## UX & Platform Priorities
- **Android-first**, Web second, iOS third
- Primary audience: **kids** — finger-friendly tap targets with **deterministic 100% viewport auto-fit**: NEVER clamp grid tile sizes to a fixed minimum like `48.0` (which overflows `7×7`–`10×10` boards on Pixel 10 portrait `412×915` and `+20%` zoom `343×762`); always use `LayoutBuilder` auto-fit (`tileSize.clamp(1.0, 120.0)`) + `InteractiveViewer` pinch-to-zoom (`1.0x`–`2.5x`, auto-resetting on victory)
- Never place floating badge overlays (`_activeBadges`) in a `Stack` over the puzzle grid on mobile portrait — use the dedicated non-overlapping `_buildGoodiesShelf` inside the main `Column`
- Export `RenderBox` bounds to `window._tubatureBoardRect` and `window._tubatureHomeRects` for deterministic Chrome CDP verification, and pass `-vf "scale=trunc(iw/2)*2:trunc(ih/2)*2"` to `ffmpeg` (`libx264` / `yuv420p`) when recording odd-height mobile viewports (`412×915`)
- **Raspberry Pi 400 ("Sguisatazzo") Turbo Compliance (`v2.13.0+`)**: Maintain `PerformanceConfig` (`lib/logic/performance_config.dart`) with `targetWidth: 128` texture downscaling, `RepaintBoundary` per tile, zero-idle-CPU tickers, no `saveLayer`/`MaskFilter.blur`/`BackdropFilter` in RPi mode, and `delete window.ImageDecoder` in `web/index.html` for WebKit2GTK (`sguisa-game-runner`).
- Tiles must be easy to tap on a Pixel 10 screen without accidental mis-taps
- **Colorful, fun, swift** — prioritize playability and joy over features
- Smooth rotation animations (≤200ms), satisfying color flood, clear victory celebration
- Mouse/click interaction on Web must feel equally natural
- Pinch-to-zoom enabled for accessibility
- No login, accounts, or monetization for now — pure gameplay focus

## Design Aesthetic (from mockups)
- Clean, minimal background (warm cream/off-white)
- Bold, rounded pipe outlines (dark stroke)
- Color flood fills connected pipes (green, pink/mauve — vary by level or theme)
- Source creature is visually prominent
- Bottom toolbar with hint/magic-wand button
- Version number shown in home screen footer

## Deployment
- **Web (GitHub Pages)**: `just deploy` → https://palladius.github.io/tubature/
- **Local**: `just serve` → http://localhost:8765
- **Android**: `just build-apk` (future: Google Play)
- GitHub remote: `github` (git@github.com:palladius/tubature.git)
- GitLab remote: `origin` (git@gitlab.com:palladius/tubature.git)

## Version & Changelog
- Version tracked in `lib/version.dart`, `VERSION`, `CHANGELOG.md`, `pubspec.yaml`
- Update ALL FOUR on every meaningful change
