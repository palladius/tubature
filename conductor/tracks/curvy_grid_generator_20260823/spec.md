# Specification — Curvy & Intricate Grid Generation ("Chaos Monkey / Arzigogolamento")

## Overview
Currently, the level generator in `lib/logic/level_generator.dart` has a 60% bias to continue in the previous direction during DFS spanning tree generation. On large grids (especially Medium 7-8 and Hard 9-10), this frequently produces long straight pipe runs along perimeter rows and columns (as observed in player feedback).

This track implements an **Arzigogolo (Curviness / Chaos Monkey)** generator enhancement that penalizes long straight lines, encourages winding corner turns and branching tees, and enforces a maximum straightness / minimum curviness metric to guarantee rich, maze-like puzzle layouts.

---

## Functional Requirements

### 1. Curviness & Chaos Monkey Generation Algorithm
- **Turn Bias over Straight Bias**: Replace or tune the `previousDirection` bias with a configurable **Winding Bias** (e.g. 70% preference to turn 90° left or right rather than continuing straight).
- **Perimeter Run Breaker**: Prevent DFS from traversing more than 2 consecutive perimeter border tiles in a straight line without forcing a turn inward or branch.
- **Chaos Monkey Branching**: Introduce controlled branching (Tee and Cross tile formations) to create interwoven multi-path choices instead of single long snaking lines.

### 2. "Arzigogolo" / Curviness Metric & Validation
- Compute a **Straightness Ratio** $S$ on the generated solved grid:
  $$S = \frac{\text{Count of Line tiles (I)}}{\text{Total Non-Source Tiles}}$$
  or **Max Straight Run Length** $L_{\max}$ (longest contiguous run of identical-direction line tiles).
- **Rejection Rule**: If $S > 0.35$ (more than 35% straight lines) or if $L_{\max} > 3$ on any row/col, regenerate the grid.

### 3. Difficulty-Scaled Curviness
- **Easy (6×6)**: Max straight run $\le 3$, Straightness $\le 40\%$, Corner/Tee ratio $\ge 50\%$.
- **Medium (7×7, 8×8)**: Max straight run $\le 2$, Straightness $\le 30\%$, Corner/Tee ratio $\ge 60\%$.
- **Hard (9×9, 10×10)**: Max straight run $\le 2$, Straightness $\le 25\%$, highly intricate labyrinth structure.

---

## Non-Functional Requirements
- **100% Solvability Guarantee**: Every generated level must remain guaranteed solvable (all tiles reachable from source) and verified by `WinChecker.checkWin(grid)`.
- **Generation Speed**: Average level generation time must remain $< 15\text{ms}$ on mobile / web.
- **Unit Test Verification**: Unit tests measuring straightness distributions across 100 generated levels per difficulty.

---

## Acceptance Criteria
- [ ] No generated level has a perimeter run of $\ge 4$ straight line tiles.
- [ ] High difficulty levels show intricate, labyrinthine patterns with varied Corners (L), Tees (T), and Caps.
- [ ] All existing 61+ tests pass with $\ge 90\%$ test coverage.
- [ ] Automated visual solver and QA cartridges confirm visually pleasing, intricate boards.
