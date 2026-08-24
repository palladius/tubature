# Spec: Keyboard Navigation & Controls for Desktop/Web

**Track ID**: `keyboard_navigation_20260824`
**Type**: Feature
**GH Issue**: [#1](https://github.com/palladius/tubature/issues/1)
**Requested by**: Daniel 🙏

## Overview

Add full keyboard support for playing Tubature on desktop/web. A visible "focus cursor" highlights the active tile, arrow keys (+ WASD) move it around the grid, and Space rotates the tile. This enables mouse-free gameplay, improves accessibility, and simplifies automated testing.

## Functional Requirements

### FR1: Navigation Keys
- **Arrow keys** (`←` `→` `↑` `↓`) move the focus cursor between tiles
- **WASD keys** (`W` `A` `S` `D`) as alternate navigation (gamer-style)
- Both schemes work simultaneously — no configuration needed

### FR2: Rotation Keys
- **Space** = rotate focused tile **clockwise** (matches tap behavior)
- **Shift+Space** = rotate focused tile **counter-clockwise** (undo shortcut)

### FR3: Utility Keys
- **R** = Reset level
- **Escape** = Go back to home screen
- **Tab** = Cycle through bottom bar buttons (Hint, Reset)

### FR4: Focus Indicator Visual
- **Glowing animated border ring** around the focused tile
- Color matches the current creature theme (green for Dragon, purple for Wizard, etc.)
- Must be visible on ALL 5 themes — high contrast, kid-friendly
- Subtle pulse/glow animation (not distracting, but clearly visible)

### FR5: Edge Wrapping (Toroidal)
- Pressing `→` at right edge wraps to leftmost tile of **same row**
- Pressing `←` at left edge wraps to rightmost tile of **same row**
- Pressing `↓` at bottom edge wraps to topmost tile of **same column**
- Pressing `↑` at top edge wraps to bottommost tile of **same column**
- Like Pac-Man — modular universe! 🟡

### FR6: Initial Focus
- Focus starts at tile **(0, 0)** (top-left) when game begins
- Focus indicator appears only after the first keyboard event (not on touch)
- On touch/click interaction, focus indicator hides (to avoid clutter on mobile)

## Non-Functional Requirements

- **No mobile interference**: Keyboard shortcuts only active on web/desktop
- **Performance**: Focus ring rendering adds no overhead to paint cycle
- **Accessibility**: Follows WAI-ARIA focus management best practices

## Technical Approach

1. Wrap `GameScreen` body in a `Focus` widget with a `FocusNode`
2. Handle key events via `KeyboardListener` or `Shortcuts`/`Actions`
3. Store `focusedTile` as `Position?` in `GameScreen` local state (not GameNotifier)
4. Pass `focusedTile` to `GridWidget` → `PipePainter` for focus ring rendering
5. Focus ring: `Canvas.drawRect` with theme-colored `Paint` + `MaskFilter.blur` for glow

## Acceptance Criteria

- [ ] Arrow keys + WASD navigate between tiles on the grid
- [ ] Space rotates focused tile clockwise
- [ ] Shift+Space rotates focused tile counter-clockwise
- [ ] Visual focus ring clearly shows which tile is selected (all 5 themes)
- [ ] Focus wraps toroidally at grid edges
- [ ] Focus hides on touch, shows on keyboard
- [ ] R resets level, Escape goes back
- [ ] Works on Chrome, Firefox, Safari (web build)
- [ ] Does not interfere with mobile touch interactions
- [ ] `flutter analyze` = 0 issues

## Out of Scope

- Gamepad/controller support (future track)
- Screen reader announcements (future a11y track)
- CLI text-mode play (separate track: `cli_text_mode_20260824`)
