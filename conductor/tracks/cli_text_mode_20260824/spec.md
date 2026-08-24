# Spec: CLI Text Mode — Terminal Pipe Puzzle 🖥️🕹️

**Track ID**: `cli_text_mode_20260824`
**Type**: Feature
**GH Issue**: [#2](https://github.com/palladius/tubature/issues/2)
**Requested by**: Riccardo (inspired by Daniel's keyboard request)

## Overview

A standalone CLI/terminal text-mode client for Tubature. Play the pipe puzzle entirely in the terminal with ASCII art pipes, ANSI colors, and keyboard controls. Pure Dart — reuses game logic without Flutter.

## Functional Requirements

### FR1: ASCII Pipe Rendering
- Render grid using Unicode box-drawing characters:
  - **Line (I)**: `║` (vertical) / `═══` (horizontal)
  - **Corner (L)**: `╔` `╗` `╚` `╝`
  - **Tee (T)**: `╠` `╣` `╦` `╩`
  - **Cross (+)**: `╬`
  - **Dead-end**: `╸` `╹` `╺` `╻` (or `○`)
  - **Source**: Creature emoji `🐉` `🧙` `🚀`
- Each tile occupies a 3×3 or 5×3 character cell for clear rendering

### FR2: ANSI Color Coding
- **Focused tile**: Reverse video (inverted colors) or bright yellow background
- **Connected pipes**: Green (`\033[32m`)
- **Disconnected pipes**: Gray/dim (`\033[90m`)
- **Source**: Bold + creature color
- **Header/footer**: Cyan info bars

### FR3: Keyboard Controls
- **Arrow keys / WASD**: Move focus cursor (toroidal wrapping)
- **Space / Enter**: Rotate focused tile clockwise
- **Shift+Space**: Rotate counter-clockwise (if terminal supports it)
- **R**: Reset level
- **Q**: Quit game
- **N**: New game (same difficulty)
- **1/2/3**: Switch difficulty (Easy/Medium/Hard)

### FR4: Game HUD
- Top bar: version, difficulty, grid size
- Stats: move count, connected/total tiles, percentage bar
- Bottom bar: controls legend
- Victory message with ASCII art celebration

### FR5: Level Generation & Win Detection
- Reuse existing `LevelGenerator`, `WinChecker` from `lib/logic/`
- Reuse `Tile`, `Grid`, `Level` models from `lib/models/`
- Pure Dart — no Flutter imports

## Non-Functional Requirements

- **Zero Flutter dependency**: Must run with `dart run` (no `flutter run`)
- **Terminal compatibility**: Works on macOS Terminal, iTerm2, Linux terminals, Windows Terminal
- **Responsive**: Full redraw on each input (<16ms for smooth feel)
- **Raw mode**: Terminal in raw mode for single-keypress input (no Enter needed)

## Technical Approach

1. Entry point: `tool/cli_play.dart`
2. Terminal I/O: `dart:io` `stdin` in raw mode (`lineMode = false, echoMode = false`)
3. Screen: ANSI escape `\033[2J\033[H` for clear + home
4. Rendering: `StringBuffer` builds full frame, print in one shot (no flicker)
5. Import game logic: `import '../lib/models/tile.dart'` etc.
6. Launch: `dart run tool/cli_play.dart` or `just play-cli`

## Acceptance Criteria

- [ ] Playable via `dart run tool/cli_play.dart`
- [ ] ASCII pipe rendering with proper box-drawing chars per tile type + rotation
- [ ] ANSI color for focus, connected, disconnected tiles
- [ ] Arrow/WASD + Space controls, toroidal wrapping
- [ ] Win detection + celebration message
- [ ] Difficulty selection (1/2/3 keys or CLI flag)
- [ ] Reuses models/logic from `lib/` — no duplication
- [ ] Works without Flutter SDK (pure Dart)

## Out of Scope

- Multiplayer / networked play
- Mouse support in terminal
- Windows `cmd.exe` support (Windows Terminal only)
