# Specification: Automated Gameplay Video Recording Pipeline 🎬🎮📹

**Track ID**: `automated_gameplay_recording_20260824`  
**Type**: Feature  
**Status**: Draft  

---

## 1. Overview
An automated gameplay recorder tool that programmatically launches a browser, starts a puzzle game on localhost, plays the level with human-like interactions (including optional minor mistakes/hesitations), and outputs a smooth MP4 video to `out/YYYYMMDD-game-v$VER-$DIFFICULTY.mp4` for version showcases and social sharing.

---

## 2. Functional Requirements

### 2.1 Video Recording CLI Command
- A clean `justfile` recipe:
  - `just record [difficulty=medium] [device=mobile|desktop]`
  - `just record-all` (runs batch recordings for easy, medium, hard across mobile and desktop)
- Output directory: `out/` (gitignored, created automatically).
- Output filename format:
  `out/YYYYMMDD-game-v$VER-$DIFFICULTY-$DEVICE.mp4`  
  Example: `out/20260824-game-v2.4.0-medium-mobile.mp4`

### 2.2 Device & Resolution Modes
1. **Mobile Portrait**:
   - Window size: `412 × 915` (Pixel 10 standard size).
   - Video orientation: vertical 9:16 aspect.
2. **Desktop / Tablet Landscape**:
   - Window size: `1280 × 720` (720p 16:9 standard).
   - Video orientation: horizontal wide layout.

### 2.3 Intelligent Human-Like Solver & Playability Simulation
1. **Automatic Grid Inspection / Solving**:
   - Tool reads the generated level structure or solves the rotation state to achieve 100% win condition.
2. **Human-like Timing & Mistakes**:
   - Natural click cadence (400-800ms between taps).
   - Includes 1 to 2 intentional "overshoot" or trial rotations before resolving the final path to make the video feel organic and authentic rather than robotic.
3. **Celebration & Audio Capture**:
   - Waits through the 3-second admiration delay, fluid flood propagation wave, and Ermete voice speech animation.
   - Captures victory overlay appearance.

### 2.4 Video Encoding & Quality
- Frame capture via Chrome DevTools Protocol (`Page.startScreencast` / high-speed canvas grab).
- H.264 MP4 encoding with `ffmpeg` or Python `imageio[ffmpeg]` at 30 FPS.

---

## 3. Acceptance Criteria
- [ ] Running `just record` plays and records a complete game from Home Screen to Victory.
- [ ] Output MP4 file is generated in `out/` with correct timestamp, version, and difficulty.
- [ ] Video playback is smooth (≥30 FPS) with crisp resolution and no rendering artifacts.
- [ ] Supports both `mobile` (412x915) and `desktop` (1280x720) viewport profiles.
