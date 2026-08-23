# Track Specification: Hidden Image Reveal Mode

**Track ID**: `hidden_image_20260823`  
**Status**: New  

## Overview
Generate themed background images (one per level/theme) that are sliced into tiles matching the puzzle grid. Each tile fragment has ~20% opacity. When the player rotates a tile to its correct position, the image fragment aligns, providing subtle visual feedback. When the full puzzle is solved, the complete image is revealed at full opacity as a celebration effect.

## Functional Requirements
1. **Themed Grid-Sized Images**: Generate or use pre-made images sized to match the grid (1:1 aspect ratio for square grids).
2. **Image Slicing**: Slice images into tile-sized fragments matching the grid dimensions.
3. **Fragment Rendering**: Render each fragment behind its corresponding pipe tile at ~20% opacity.
4. **Synchronized Rotation**: Fragment rotation follows the pipe tile rotation (so it looks jumbled when unsolved).
5. **Visual Alignment Feedback**: When a tile is in the correct position, its fragment aligns with neighbors.
6. **Victory Reveal**: On win, fade image to full opacity (100%) as a celebration effect.
7. **Mode Toggle**: This is a "Simple Mode" / "Hint Mode" — toggled via settings or level selection.
8. **Creature Theming**: Images should be themed per creature theme (dragon scenes 🐉, wizard castles 🧙, space scenes 🚀).

## Non-Functional Requirements
- **Lightweight Assets**: Images must be lightweight (WebP/PNG, <500KB each).
- **Animation Performance**: Must not slow down tile rotation animations (maintain 60fps).
- **Cross-Platform**: Should work seamlessly across all supported platforms (Web, Android, iOS).

## Acceptance Criteria
- [ ] At least 3 images (one per creature theme) are included
- [ ] Image fragments are visible behind tiles at reduced opacity (~20%)
- [ ] Fragments visually align when tiles are correctly rotated
- [ ] Full image reveal on puzzle completion
- [ ] Feature is toggled as "Simple Mode" in the UI
- [ ] Performance: no noticeable lag during rotation

## Out of Scope
- AI-generated images at runtime
- User-uploaded images
- Animated/video backgrounds
