# FlowConnect / Tubature — Agent Instructions

## Project Overview
FlowConnect is a pipe-puzzle game built with Flutter/Dart. The player rotates tiles on a grid to connect a Source to a Sink, creating a continuous flow path.

## Tech Stack
- **Language**: Dart
- **Framework**: Flutter (cross-platform: Android, iOS, Web)
- **No external game engine** — pure Flutter widgets + Canvas for rendering

## Conventions
- Follow Dart/Flutter style guide (effective_dart)
- Use `flutter analyze` and `flutter test` for validation
- Game logic must be pure Dart (no Flutter dependencies) for easy testing
- Separate models, logic, screens, and widgets into distinct directories

## Design Reference
- Original Italian spec: `docs/FlowConnect.md`
- Design mockups: `docs/design/FlowConnect_*.jpg`

## Quality & Testing
- **Minimum 90% unit test coverage** on all game logic (models, path verification, level generation)
- Run `flutter test --coverage` and verify with `lcov`
- AI agent must be able to **play the game visually via browser** (Web build) to verify playability end-to-end
- All PRs must pass `flutter analyze` (zero warnings) + `flutter test` before merge

## UX & Platform Priorities
- **Android-first**, Web second, iOS third
- Primary audience: **kids** — large, finger-friendly tap targets (minimum 48×48dp, prefer 56×56dp+)
- Tiles must be easy to tap on a Pixel 10 screen without accidental mis-taps
- **Colorful, fun, swift** — prioritize playability and joy over features
- Smooth rotation animations (≤200ms), satisfying color flood, clear victory celebration
- Mouse/click interaction on Web must feel equally natural
- No login, accounts, or monetization for now — pure gameplay focus

## Design Aesthetic (from mockups)
- Clean, minimal background (warm cream/off-white)
- Bold, rounded pipe outlines (dark stroke)
- Color flood fills connected pipes (green, pink/mauve — vary by level or theme)
- Source and Sink are visually distinct (filled/open circles)
- Bottom toolbar with hint/magic-wand button

## Version & Changelog
- Version tracked in `README.md` and `CHANGELOG.md`
- Update both on every meaningful change
