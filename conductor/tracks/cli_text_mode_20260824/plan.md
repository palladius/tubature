# Plan: CLI Text Mode

## Phase 1: ASCII Tile Renderer
- [ ] Task: Create `tool/cli_play.dart` entry point
  - [ ] Parse CLI args: `--difficulty easy|medium|hard`, `--size N`
  - [ ] Initialize `LevelGenerator`, generate level
- [ ] Task: Build ASCII tile renderer
  - [ ] Map each `TileType` × `rotation` to a 3-char ASCII pattern
  - [ ] Line: `═══` / `║` variants
  - [ ] Corner: `╔═` `═╗` `╚═` `═╝` variants
  - [ ] Tee: `╠═` `═╣` `╦` `╩` variants
  - [ ] Cross: `╬`, Dead-end: `╸╹╺╻`, Source: emoji
- [ ] Task: Build grid renderer
  - [ ] `StringBuffer` composites all tile cells into a full-grid string
  - [ ] ANSI color: green for connected, gray for disconnected
  - [ ] Reverse video for focused tile
- [ ] Task: Phase Verification & Checkpoint
  - [ ] Static grid renders correctly with all tile types

## Phase 2: Terminal I/O & Game Loop
- [ ] Task: Raw mode terminal input
  - [ ] `stdin.lineMode = false; stdin.echoMode = false`
  - [ ] Read single keypress, detect arrow key escape sequences
  - [ ] Map to game actions (move, rotate, reset, quit)
- [ ] Task: Game loop
  - [ ] Clear screen + render grid on each input
  - [ ] Track `focusedTile` position with toroidal wrapping
  - [ ] Space → call tile rotation logic
  - [ ] R → reset, Q → quit, N → new game
- [ ] Task: HUD rendering
  - [ ] Top bar: version, difficulty, grid size
  - [ ] Stats bar: moves, connected/total, percentage bar
  - [ ] Bottom bar: controls legend
- [ ] Task: Phase Verification & Checkpoint
  - [ ] Full interactive game loop works in terminal

## Phase 3: Win Detection & Polish
- [ ] Task: Win detection integration
  - [ ] Check `WinChecker.checkWin(grid)` after each rotation
  - [ ] Display ASCII victory celebration
  - [ ] Prompt: N = new game, Q = quit
- [ ] Task: Difficulty switching
  - [ ] 1/2/3 keys switch difficulty mid-game
  - [ ] Display difficulty in HUD
- [ ] Task: Add `just play-cli` recipe to justfile
- [ ] Task: Phase Verification & Checkpoint
  - [ ] Complete playthrough from start to victory in terminal

## Phase 4: Tests
- [ ] Task: Unit tests for ASCII renderer
  - [ ] Test each tile type × rotation produces correct characters
  - [ ] Test grid composition
- [ ] Task: Version bump & CHANGELOG
- [ ] Task: Phase Verification & Checkpoint
