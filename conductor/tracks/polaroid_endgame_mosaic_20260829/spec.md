# Specification: Polaroid End-Game Celebration Mosaic (`polaroid_endgame_mosaic_20260829`)

## 1. Overview
A celebratory victory splash screen inspired by Picasa's classic photo scatter / polaroid pile effect. When the player wins a level in Tubature, the unlocked badges and cauldron goodies cascade down onto the screen sequentially at random angles ($\pm 30^\circ$), casting realistic drop shadows, framed in vintage Polaroid borders with handwritten-style labels.

## 2. Functional Requirements

### 2.1 Polaroid Card Widget (`PolaroidWidget`)
- Classic Polaroid frame: thick white border, larger bottom chin for badge title/label.
- Rotation angle: randomly chosen or configured within $[-30^\circ, +30^\circ]$.
- Drop shadow elevation and subtle paper texture/border.
- Content support: badge icon / image (`ui.Image` or `CauldronGoodie` asset), name / rarity label.

### 2.2 Cascade Mosaic Overlay (`PolaroidMosaicOverlay`)
- Staggered cascade animation: polaroids drop/toss onto the screen one by one into an organic scattered collage.
- Source collection: fetches all discovered `CauldronGoodie` badges in the session / game catalog.
- Central celebration banner / title (e.g. "✨ LIVELLO COMPLETATO! ✨").

### 2.3 Controls & Dismissal
- **Keyboard navigation**: Pressing **Spacebar** (`LogicalKeyboardKey.space`) or **Enter** (`LogicalKeyboardKey.enter`) dismisses the overlay and immediately triggers `onNextLevel`.
- **Touch / Pointer**: Tapping anywhere on the screen backdrop or clicking the prominent "Prossimo Livello ➡️" button advances to the next level.

### 2.4 Victory Flow Integration
- Connected seamlessly into the victory flow (`GameScreen` / `VictoryOverlay`).

## 3. Non-Functional Requirements
- Smooth 60fps animations.
- Pure Flutter widgets / canvas rendering without external dependencies.
- Fully responsive across mobile portrait/landscape and desktop/web viewports.

## 4. Acceptance Criteria
- All tests in `test/widgets/polaroid_widget_test.dart` and `test/screens/polaroid_mosaic_overlay_test.dart` pass.
- `flutter analyze` passes with 0 issues.
- Pressing Spacebar or clicking advances to the next level.
