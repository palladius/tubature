# Implementation Plan: Magic Cauldron Image Reveal 🧪✨

**Track ID**: `magic_cauldron_reveal_20260824`
**Spec**: [spec.md](./spec.md)

---

## Phase 1: Asset Pipeline & Goodies Database

Generate and organize the circular cartoon goodies images.

- [ ] Task: Create `assets/goodies/` directory structure
- [ ] Task: Generate standard goodies images (AI-generated, 512×512 PNG, circular)
  - [ ] 💎 `ruby.png` — Sparkling Ruby gem
  - [ ] 🐉 `dragon.png` — Friendly cartoon dragon
  - [ ] 🦄 `unicorn.png` — Magical unicorn
  - [ ] 🏎️ `hotwheel.png` — Cartoon race car
  - [ ] 👦 `alessandro.png` — Cartoon boy placeholder (brown hair, Italian look)
  - [ ] 👦 `sebi.png` — Cartoon boy placeholder (different style)
  - [ ] 🧔 `papino.png` — Cartoon dad placeholder (beard, glasses)
  - [ ] 🧙 `wizard.png` — Cartoon wizard with hat & staff
- [ ] Task: Generate legendary Schmoogle image 🐉🔴🔵🟡🟢
  - [ ] `schmoogle.png` — Dragon in Google brand colors
- [ ] Task: Register goodies in `pubspec.yaml` assets section
- [ ] Task: Phase Verification & Checkpoint (Refer to workflow.md)

---

## Phase 2: Goodies Data Model & Assignment Logic

Create the model layer for goodies selection and assignment.

- [ ] Task: Write unit tests for GoodiesCatalog and assignment logic
  - [ ] Test: catalog loads all goodies from asset manifest
  - [ ] Test: assignGoodies(deadEndCount, difficulty) returns unique non-repeating list
  - [ ] Test: Schmoogle only appears on Hard difficulty
  - [ ] Test: Schmoogle probability is ~1% (statistical test with seeded random)
  - [ ] Test: when deadEndCount > standard goodies count, allow repeats gracefully
- [ ] Task: Create `lib/models/goodie.dart` — Goodie data class
  - [ ] Properties: `id`, `assetPath`, `displayName`, `isLegendary`, `emoji`
  - [ ] Static catalog of all goodies
- [ ] Task: Create `lib/logic/goodies_assigner.dart` — Assignment logic
  - [ ] `List<Goodie> assignGoodies(int deadEndCount, Difficulty difficulty, {Random? random})`
  - [ ] Shuffle standard pool, optionally inject Schmoogle (1% chance on Hard)
  - [ ] Return exactly `deadEndCount` unique goodies
- [ ] Task: Phase Verification & Checkpoint (Refer to workflow.md)

---

## Phase 3: Image Preloading Service

Efficiently load and cache goodies images for Canvas rendering.

- [ ] Task: Write tests for GoodiesImageService
  - [ ] Test: preloadImages loads all assigned goodies
  - [ ] Test: getImage(goodieId) returns cached dart:ui.Image
- [ ] Task: Create `lib/services/goodies_image_service.dart`
  - [ ] `Future<void> preloadImages(List<Goodie> goodies)` — decode and cache as `dart:ui.Image`
  - [ ] `ui.Image? getImage(String goodieId)` — retrieve cached image
  - [ ] Images decoded from asset bundle at level start
- [ ] Task: Integrate preloading into game level initialization flow
- [ ] Task: Phase Verification & Checkpoint (Refer to workflow.md)

---

## Phase 4: Cauldron Convergence Renderer

The core visual effect — rendering the goodie image inside the ampolla with turbulence-to-clarity animation.

- [ ] Task: Write tests for convergence math utilities
  - [ ] Test: convergenceOpacity(flowProgress) returns correct values per phase
  - [ ] Test: turbulenceIntensity(flowProgress) decreases correctly over phases
  - [ ] Test: circular clip geometry matches bulb dimensions
- [ ] Task: Create `lib/widgets/cauldron_reveal_painter.dart` — CauldronRevealPainter
  - [ ] Accepts: `ui.Image`, `bulbCenter`, `bulbRadius`, `flowProgress`, `shimmerProgress`
  - [ ] Phase 0 (0–30%): No image rendered
  - [ ] Phase 1 (30–50%): Draw image with very low opacity (0.05–0.15), heavy color distortion via ColorFilter, overlay turbulence noise circles
  - [ ] Phase 2 (50–75%): Increase opacity (0.15–0.50), reduce distortion, partial blur effect via multiple offset draws with decreasing alpha
  - [ ] Phase 3 (75–95%): High opacity (0.50–0.90), gentle ripple distortion only
  - [ ] Phase 4 (95–100%): Full opacity (0.90–1.0), optional golden shimmer glow ring
  - [ ] All rendering inside circular clip matching bulbRadius
- [ ] Task: Integrate CauldronRevealPainter into `_drawTorrentialDeadEnd()` in `pipe_painter.dart`
  - [ ] Draw goodie image AFTER liquid fill, BEFORE specular reflections
  - [ ] Pass appropriate flowProgress, shimmerProgress, and bulb geometry
- [ ] Task: Phase Verification & Checkpoint (Refer to workflow.md)

---

## Phase 5: Game Integration & Goodie Distribution

Wire goodies assignment into the game flow.

- [ ] Task: Write integration tests
  - [ ] Test: level with 3 dead-ends gets 3 unique goodies assigned
  - [ ] Test: goodies images are preloaded before gameplay starts
  - [ ] Test: PipePainter receives correct goodie for each dead-end tile
- [ ] Task: Extend Tile model or create tile-goodie mapping
  - [ ] Add optional `Goodie? assignedGoodie` or maintain separate Map<GridPosition, Goodie>
- [ ] Task: Integrate goodies assignment into level generation (in game provider/logic)
  - [ ] After grid generation, count dead-end tiles
  - [ ] Call GoodiesAssigner.assignGoodies()
  - [ ] Store mapping of tile position → goodie
- [ ] Task: Pass goodie data through to PipePainter for dead-end tiles
- [ ] Task: Phase Verification & Checkpoint (Refer to workflow.md)

---

## Phase 6: Schmoogle Easter Egg Sound

Special audio treatment for the legendary Schmoogle reveal.

- [ ] Task: Write tests for Schmoogle sound trigger
  - [ ] Test: sound plays when Schmoogle goodie enters Phase 1
  - [ ] Test: sound does NOT play for standard goodies
- [ ] Task: Create/synthesize Schmoogle reveal sound effect
  - [ ] Mysterious, magical tone — distinct from normal glub sounds
  - [ ] Add to `lib/services/audio_synth_web.dart` and stub
- [ ] Task: Trigger Schmoogle sound in convergence flow
  - [ ] Detect when a Schmoogle-assigned ampolla starts filling
  - [ ] Play the special sound effect
- [ ] Task: Phase Verification & Checkpoint (Refer to workflow.md)

---

## Phase 7: Convergence Timing Calibration

Ensure the 8–10 second drama plays out correctly.

- [ ] Task: Calibrate flowProgress animation speed for dead-end tiles
  - [ ] Verify the flow animation for dead-end tiles spans ~8–10 real-time seconds from first water contact to full reveal
  - [ ] Adjust animation duration/curves in tile_widget.dart or game provider if needed
- [ ] Task: Test convergence on different grid sizes (5×5 Easy → 8×8 Hard)
- [ ] Task: Manual visual verification — does the effect feel "magical" and suspenseful?
- [ ] Task: Phase Verification & Checkpoint (Refer to workflow.md)

---

## Phase 8: Polish, Version & Verification

Final quality gates and release preparation.

- [ ] Task: `flutter analyze` — 0 issues
- [ ] Task: `flutter test` — all tests pass
- [ ] Task: Manual verification on Web (localhost)
- [ ] Task: Manual verification visual quality of all 9 goodies
- [ ] Task: Verify Schmoogle rarity (run multiple games on Hard, confirm ~1% appearance)
- [ ] Task: Update VERSION (bump minor: 2.4.2 → 2.5.0)
- [ ] Task: Update `pubspec.yaml` version
- [ ] Task: Update `lib/version.dart`
- [ ] Task: Update CHANGELOG.md with Magic Cauldron feature entry
- [ ] Task: Commit all changes
- [ ] Task: Phase Verification & Checkpoint (Refer to workflow.md)
