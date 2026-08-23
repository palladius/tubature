# Track Specification: Visual Polish & Dead-End Redesign

**Track ID**: `visual_polish_20260823`
**Status**: New
**Priority**: After core functionality (difficulty chooser, etc.)

## Overview

Major visual refactoring of pipe tile rendering to make the game look more polished and kid-friendly. The primary change is redesigning the dead-end (termination) tile to use a distinctive outward-curving arc ("ampolla") instead of the current small circle cap ("capocchia di spillo"). Secondary changes include adding a difficulty chooser on the home screen and general visual cleanup.

## Design Reference

### Dead-End Tile Redesign 🧪
**Current**: Pipe from center to edge with a small filled circle at center (looks like a cut-off pipe)
**New**: Outward-curving quarter-circle arc that looks like a sealed bulb/flask ("ampolla"). The arc curves AWAY from the pipe opening, creating a distinctive sealed-end appearance.

Technical detail: Reuse the outward-arc code (`addArc` with positive π/2 sweep) that was accidentally created for corners — it naturally looks like a sealed flask/bulb end.

### Corner (L) Tile
**Keep as-is**: Two straight segments meeting at center with filled circle joint. Simple, clear, functional. User explicitly approved this style.

### T-Junction Tile
**Keep current**: Straight-through pipe + branch from center. Consider smoothing the center junction with a filled square instead of circle.

### Source Tile
**Consider**: Larger, more prominent creature marker. Current ring is good but could be bigger/more colorful.

## Functional Requirements

### Phase 1: Dead-End Ampolla
1. Replace dead-end rendering with outward-curving arc
2. Arc should be thick and rounded, looking like a sealed flask/bulb
3. Connected (blue) dead-ends should look like water-filled bulbs
4. Disconnected (gray) dead-ends should look like empty glass flasks
5. Must work at all 4 rotations (N/S/E/W openings)

### Phase 2: Home Screen Difficulty Chooser
1. Add difficulty selection on home screen (Easy / Medium / Hard)
2. Show grid size for each option (e.g., "Easy 6×6", "Medium 7-8", "Hard 9-10")
3. Selected difficulty persists across sessions (SharedPreferences)
4. Remove or simplify the auto-progression system (or make it optional)

### Phase 3: Color Themes & Polish
1. Warmer, more vibrant background colors per theme
2. Smoother pipe edges (anti-aliasing)
3. Larger pipe endpoints at cell edges (to visually "join" with neighbor pipes)
4. Confetti/particle effects on win (beyond current simple confetti)
5. Sound effects (tap, rotate, connect, win) — optional, needs `audioplayers` package

## Non-Functional Requirements
- Must maintain 60fps during rotation animations
- All changes must work on Web, Android, and iOS
- Minimum tap target size: 56dp (Material guidelines for kids)

## Acceptance Criteria
- [ ] Dead-end tiles use outward-arc "ampolla" design
- [ ] Difficulty chooser on home screen works
- [ ] All 3 creature themes have visually distinct backgrounds
- [ ] `flutter analyze` — 0 issues
- [ ] `flutter test` — all pass
- [ ] Visual QA on web (localhost) and mobile (Android emulator)

## Out of Scope
- Animated water flow through pipes (future feature)
- 3D pipe rendering
- Sound/music (separate track)
