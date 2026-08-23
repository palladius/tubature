# Specification — Multi-Device Screenshot Showcase Pipeline

## Overview
To showcase Tubature across multiple real-world form factors (Desktop, Google Pixel 10, iPhone 16 Pro Max, Samsung Galaxy Tab / iPad) in both portrait and landscape orientations, this track establishes a dedicated, automated screenshot capturing pipeline.

The captured screenshots will be stored directly in git under `test/screenshots/` with clear device and dimension naming (`<device>/<screen>_<orientation>_<width>x<height>.png`) and indexed in a visual `test/screenshots/README.md` gallery to easily share on GitHub.

---

## Functional Requirements

### 1. Storage & Naming Conventions
- Root directory: `test/screenshots/` (tracked in Git).
- Subdirectories per device:
  - `test/screenshots/desktop_1440x900/`
  - `test/screenshots/pixel10_412x915/`
  - `test/screenshots/iphone16pro_430x932/`
  - `test/screenshots/samsung_tab_820x1180/`
- Naming format:
  `{step}_{screen_name}_{orientation}_{width}x{height}.png`
  - Example: `01_home_portrait_412x915.png`
  - Example: `01_home_landscape_915x412.png`
  - Example: `02_game_easy_portrait_412x915.png`
  - Example: `03_game_hard_portrait_412x915.png`
  - Example: `04_tutorial_level1_portrait_412x915.png`

### 2. Automation & Execution
- **Automated Runner**: `tool/capture_screenshots.py` using Selenium/Chrome headless + self-contained background HTTP server.
- **Justfile Command**: `just screenshots` to build web, launch local server, capture all device viewport combinations, and update the visual gallery.
- **GitHub Gallery Generator**: Automatically regenerate `test/screenshots/README.md` containing visual tables and responsive comparisons for easy viewing on GitHub.

### 3. GitHub Actions CI (Bonus)
- `.github/workflows/device_showcase.yml` on push/manual dispatch to auto-capture and upload screenshots as workflow artifacts or commit them to a media branch.

---

## Acceptance Criteria
- [ ] Running `just screenshots` executes end-to-end without manual intervention.
- [ ] All 4 devices (Desktop, Pixel 10, iPhone 16 Pro, Samsung Tab) have high-res screenshots in `test/screenshots/`.
- [ ] Portrait and landscape orientations are captured and named with `_WWWxHHH.png`.
- [ ] `test/screenshots/README.md` presents an image gallery for GitHub display.
