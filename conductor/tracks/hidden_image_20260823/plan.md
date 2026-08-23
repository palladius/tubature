# Implementation Plan: Hidden Image Reveal Mode

**Track ID**: `hidden_image_20260823`

## Phase 1: Asset Pipeline
- [ ] Task: Design/generate 3 themed images (dragon, wizard, space) at 1080×1080
- [ ] Task: Create ImageSlicer utility to split images into grid-sized fragments
- [ ] Task: Write unit tests for ImageSlicer

## Phase 2: Rendering Layer
- [ ] Task: Create ImageFragmentPainter (CustomPainter) for tile background
- [ ] Task: Integrate fragment rendering into TileWidget (behind pipe layer)
- [ ] Task: Apply rotation transform matching tile rotation
- [ ] Task: Apply 20% opacity for unsolved tiles, 100% for solved

## Phase 3: Game Integration
- [ ] Task: Add "Simple Mode" toggle to game settings/UI
- [ ] Task: Pass image data through to grid rendering when Simple Mode is on
- [ ] Task: Implement full-image reveal animation on win
- [ ] Task: Write integration tests

## Phase 4: Polish & Verification
- [ ] Task: flutter analyze — 0 issues
- [ ] Task: flutter test — all pass
- [ ] Task: Manual verification on web and Android
- [ ] Task: Update VERSION and CHANGELOG
