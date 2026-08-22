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

## Version & Changelog
- Version tracked in `README.md` and `CHANGELOG.md`
- Update both on every meaningful change
