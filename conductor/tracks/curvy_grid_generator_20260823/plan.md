# Implementation Plan — Curvy Grid Generation ("Arzigogolamento")

## Phase 1: Metric & Analysis Model (TDD)
- [ ] Task: Write unit tests for Grid Straightness Metric in `test/logic/grid_metrics_test.dart`
  - [ ] Test calculation of straight line ratio ($S = \text{lines} / \text{total}$)
  - [ ] Test calculation of max consecutive straight run length $L_{\max}$
  - [ ] Test detection of perimeter straight runs
- [ ] Task: Implement `GridMetrics` utility in `lib/logic/grid_metrics.dart`
- [ ] Task: Phase Verification & Checkpoint (Unit tests pass)

## Phase 2: Chaos Monkey & Turn-Biased Spanning Tree
- [ ] Task: Write unit tests in `test/logic/curvy_level_generator_test.dart`
  - [ ] Verify 100 generated Easy/Medium/Hard levels conform to max straight run thresholds ($L_{\max} \le 2$ or $3$)
  - [ ] Verify high corner/tee diversity across generated levels
  - [ ] Verify 100% pre-shuffle solvability
- [ ] Task: Refactor `LevelGenerator._dfsSpanningTree` in `lib/logic/level_generator.dart`
  - [ ] Invert straight bias to a **Turn Bias** (prefer 90° turns over continuing straight)
  - [ ] Implement perimeter-aware turn enforcement
  - [ ] Integrate `GridMetrics` validation rejection filter with safety retry limit
- [ ] Task: Phase Verification & Checkpoint (Level generation tests pass)

## Phase 3: Visual Solver & QA Validation
- [ ] Task: Update `tool/visual_solver.dart` to print and measure Arzigogolo curviness scores across generated boards
- [ ] Task: Run automated QA cartridges in `tool/qa_cartridges.py` to capture screenshots of newly generated labyrinth boards
- [ ] Task: Phase Verification & Checkpoint (Zero regression on gameplay, 100% solvable)
