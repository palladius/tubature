# Track Specification: Magic Cauldron Image Reveal 🧪✨

**Track ID**: `magic_cauldron_reveal_20260824`
**Type**: Feature
**Status**: New
**Created**: 2026-08-24

## Overview

When water reaches an **ampolla** (dead-end / cap tile), instead of just filling with colored liquid, a hidden **"goodie" image** gradually emerges from the turbulent swirling liquid — like a mystical figure materializing inside a magic cauldron. The reveal takes 8–10 seconds of dramatic convergence: initially the image is completely invisible under violent turbolence, then progressively sharpens into a clear, circular cartoon portrait.

Each ampolla in the same puzzle reveals a **different** randomly-assigned goodie (no duplicates within one level). Kids watching will excitedly wonder: *"Sarà il drago? Sarà Alessandro? Sarà l'unicorno?!"* 🐉👦🦄

### The Schmoogle Easter Egg 🐉🔴🔵🟡🟢

A super-rare legendary goodie: **Schmoogle**, a cartoon dragon in Google's four brand colors (Red, Blue, Yellow, Green). Schmoogle appears with only a **1% probability** and **only on Hard difficulty levels**. When Schmoogle materializes, a mysterious/magical sound effect plays, creating a sense of FOMO and delight for players who discover it.

## Functional Requirements

### FR1: Goodies Image Database
1. Create an `assets/goodies/` directory containing circular (1:1 aspect ratio) cartoon images
2. **Standard Goodies** (~8 images):
   - 💎 `ruby.png` — A sparkling cartoon Ruby gem (homage to the Ruby developer!)
   - 🐉 `dragon.png` — A friendly cartoon dragon
   - 🦄 `unicorn.png` — A magical cartoon unicorn
   - 🏎️ `hotwheel.png` — A cartoon race car / Hot Wheels
   - 👦 `alessandro.png` — Cartoon portrait of Alessandro (placeholder initially)
   - 👦 `sebi.png` — Cartoon portrait of Sebastian (placeholder initially)
   - 🧔 `papino.png` — Cartoon portrait of Papino/Riccardo (placeholder initially)
   - 🧙 `wizard.png` — A cartoon wizard
3. **Legendary Goodie** (1% chance, Hard mode only):
   - 🐉 `schmoogle.png` — Google-colored dragon (Red 🔴, Blue 🔵, Yellow 🟡, Green 🟢)
4. All images must be:
   - PNG format with transparency
   - Circular or circle-cropped (square canvas, content fills a circle)
   - Resolution: 512×512px (will be downscaled to tile size at runtime)
   - File size: <200KB each

### FR2: Goodie Assignment Logic
1. At level generation time, assign one unique goodie to each dead-end tile
2. **No duplicates** within the same level — if there are 4 ampolle, 4 different goodies are shown
3. Selection is random (shuffled) from the standard pool
4. **Schmoogle special rules**:
   - Only eligible on Hard difficulty (8×8 grids)
   - 1% probability of appearing (replaces one standard goodie in the shuffle)
   - When Schmoogle is assigned, play a special mysterious sound effect on reveal

### FR3: Cauldron Convergence Animation (8–10 seconds)
1. **Phase 0 — Pre-fill (0–30% flowProgress)**: No image visible. Standard ampolla neck flooding behavior
2. **Phase 1 — Turbulent Chaos (30–50% flowProgress)**: Image begins loading behind the liquid but is completely obscured by heavy turbulence distortion (noise, swirl, extreme blur). Only vague color hints visible
3. **Phase 2 — Emerging Form (50–75% flowProgress)**: Turbulence intensity decreases. The image becomes partially recognizable — you can see shapes and dominant colors but not identify the subject clearly. Tantalizingly blurry
4. **Phase 3 — Convergence (75–95% flowProgress)**: Image sharpens significantly. The swirling effect reduces to gentle ripples. The cartoon figure becomes clearly identifiable
5. **Phase 4 — Full Reveal (95–100% flowProgress)**: Image is fully clear and vivid. A subtle golden glow or shimmer effect plays around the circle. The goodie is "locked in"
6. The total convergence from Phase 1 to Phase 4 should span approximately 8–10 real-time seconds
7. The image is rendered as a circular clip inside the ampolla bulb, respecting the bulb's existing geometry (bulbCenter, bulbRadius)

### FR4: Rendering Integration
1. The goodie image is rendered **inside** the existing ampolla bulb, layered between the liquid fill and the specular glass reflections
2. The image must rotate with the tile (it's "trapped" in the liquid)
3. The convergence animation must not interfere with existing ampolla effects (bubbles, foam, shimmer)
4. Image rendering uses Flutter's `Canvas.drawImage` with a circular clip path matching the bulb
5. The turbulence/blur effect can use Canvas blend modes, opacity modulation, and the existing shimmerProgress for organic synchronization

### FR5: Schmoogle Sound Effect
1. When a Schmoogle goodie begins its convergence (Phase 1), play a unique mysterious/magical sound
2. The sound should be distinctly different from normal ampolla glub sounds
3. Sound can be synthesized (like existing audio) or a short audio asset

## Non-Functional Requirements

- **Performance**: Image loading must not cause frame drops. Pre-load goodies images at level start. Maintain 60fps during convergence animation
- **Memory**: Images are small (512×512 PNG). Total goodies footprint <2MB
- **Cross-Platform**: Must work on Web (Canvas), Android, and iOS
- **Extensibility**: The goodies system should be designed so new images can be added by simply dropping a PNG into `assets/goodies/`

## Acceptance Criteria

- [ ] `assets/goodies/` contains at least 8 standard goodies + 1 legendary (Schmoogle)
- [ ] Each dead-end ampolla in a puzzle displays a unique, non-repeating goodie
- [ ] The convergence animation spans 8–10 seconds from turbulence to clear image
- [ ] The image is rendered inside the ampolla bulb circle, clipped correctly
- [ ] The turbulence-to-clarity effect is visually compelling and "magical"
- [ ] Schmoogle appears only on Hard difficulty with ~1% probability
- [ ] A unique mysterious sound plays when Schmoogle converges
- [ ] No performance regression (60fps maintained)
- [ ] Works on Web, Android, iOS
- [ ] VERSION and CHANGELOG updated

## Out of Scope

- User-uploaded custom goodies images
- Animated GIF/video goodies
- Goodies trading/collection system
- Per-theme goodie restrictions (all goodies are available in all themes)
- Photo-to-cartoon pipeline for real family photos (placeholder PNGs used initially)
