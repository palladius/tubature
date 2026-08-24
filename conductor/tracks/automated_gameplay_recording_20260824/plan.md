# Implementation Plan: Automated Gameplay Video Recording Pipeline 🎬🎮📹

**Track ID**: `automated_gameplay_recording_20260824`

## Phase 1: High-Speed Screencast & Frame Capture Pipeline
- [x] Task: Set up Python script `tool/record_gameplay.py` with Selenium CDP `Page.startScreencast` / high-speed frame capture
- [x] Task: Implement dual-viewport profile configuration (`mobile`: 412x915, `desktop`: 1280x720)
- [x] Task: Add automatic version extraction from `lib/version.dart` or `VERSION`
- [ ] Task: Phase Verification & Checkpoint (Refer to workflow.md)

## Phase 2: Autonomous Human-Like Puzzle Solver
- [x] Task: Implement level grid inspector to compute the winning rotation offsets for every cell
- [x] Task: Create human-like tap sequencer with natural randomized delays (350-700ms)
- [x] Task: Inject 1-2 realistic human "trial-and-error" rotation mistakes before snapping into victory configuration
- [ ] Task: Phase Verification & Checkpoint (Refer to workflow.md)

## Phase 3: Video Encoding & Directory Output
- [x] Task: Integrate `ffmpeg` / `imageio-ffmpeg` to stitch captured frames into smooth 30 FPS H.264 MP4
- [x] Task: Ensure `out/` directory is automatically created and added to `.gitignore`
- [x] Task: Format output filenames as `out/YYYYMMDD-game-v$VER-$DIFFICULTY-$DEVICE.mp4`
- [ ] Task: Phase Verification & Checkpoint (Refer to workflow.md)

## Phase 4: CLI Integration & Batch Commands
- [x] Task: Add `just record [difficulty] [device]` recipe to `justfile`
- [x] Task: Add `just record-all` for multi-difficulty showcase generation
- [ ] Task: Phase Verification & Checkpoint (Refer to workflow.md)
