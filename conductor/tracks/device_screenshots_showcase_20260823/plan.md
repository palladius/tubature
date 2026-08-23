# Implementation Plan — Multi-Device Screenshot Showcase Pipeline

## Phase 1: Automation Tool & Device Configuration
- [ ] Task: Create `tool/capture_screenshots.py`
  - [ ] Define devices: Desktop (1440×900), Pixel 10 (412×915 / 915×412), iPhone 16 Pro Max (430×932 / 932×430), Samsung Tab (820×1180 / 1180×820)
  - [ ] Implement self-contained background HTTP server for localhost reliability
  - [ ] Implement automated navigation through Home, Easy, Medium, Hard, and Tutorial
  - [ ] Output screenshots with format: `test/screenshots/{device}/{step}_{screen}_{orientation}_{width}x{height}.png`
- [ ] Task: Implement automatic `test/screenshots/README.md` markdown gallery generation

## Phase 2: Justfile & CLI Integration
- [ ] Task: Add `just screenshots` command to `justfile`
  - [ ] Triggers `flutter build web`
  - [ ] Runs `uv run --with selenium python3 tool/capture_screenshots.py`
  - [ ] Verifies output directory structure
- [ ] Task: Execute `just screenshots` locally and verify all images captured

## Phase 3: Git Tracking & GitHub Actions Workflow (Bonus)
- [ ] Task: Add `.github/workflows/device_showcase.yml` for automated CI capture
- [ ] Task: Commit all generated showcase screenshots to `test/screenshots/` on Git
- [ ] Task: Phase Verification & Checkpoint (GitHub repo shows clean gallery)
