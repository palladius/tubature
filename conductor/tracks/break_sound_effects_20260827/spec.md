# Spec: Dynamic Pipe Break Sound Effects 💥🔊

## Overview
When the player rotates a pipe tile and **reduces** water connectivity (i.e., pipes that were previously connected to the flow become disconnected), the game should play reactive audio feedback proportional to the severity of the disconnection.

This adds visceral feedback to "bad" moves, making the game more engaging and teaching players to think before they rotate.

## Functional Requirements

### FR-1: Connectivity Delta Calculation
- In `game_notifier.dart` → `rotateTile(Position pos)`:
  - Before applying the rotation, calculate the number of connected tiles (`connectedBefore`).
  - After applying the rotation, recalculate (`connectedAfter`).
  - Compute Δ = `connectedBefore - connectedAfter`.
  - If Δ > 0, invoke `AudioService.playBreakSound(delta: Δ)`.

### FR-2: Tiered Sound Effects
Based on the Δ value, play different audio:

| Δ Range | Severity | Sound Type | Description |
|---------|----------|------------|-------------|
| Δ = 1 | Minor | Procedural (Web Audio) | Crisp glass crack / mechanical snap |
| 3 ≤ Δ < 10 | Moderate | Voice clip (mp3) | "Uh-oh!" / "Oh-oh!" concerned voice |
| Δ ≥ 10 | Catastrophic | Voice clip (mp3) | Epic/magical exclamation (placeholder TTS, future: Ale recording) |

### FR-3: AudioService Integration
- New method: `AudioService.playBreakSound({required int delta})`
- Respects existing `isMuted` flag.
- Minor breaks: procedural via `audio_synth_web.dart` (OscillatorNode + noise burst).
- Moderate/catastrophic: file-based via `playVoiceFile()`.

### FR-4: Voice Assets
- `assets/voices/bad/uhoh.mp3` + `.ogg` — "Uh-oh!" (TTS generated)
- `assets/voices/bad/catastrophe.mp3` + `.ogg` — Epic exclamation (placeholder TTS)
- Future: Alessandro Verlato will record custom clips for catastrophic breaks.

## Non-Functional Requirements
- Sound must not block UI or cause jank.
- Procedural sounds must use the existing Web Audio API pattern (no new dependencies).
- Voice clips must be trimmed (no silence) and < 2 seconds.

## Acceptance Criteria
- [ ] Rotating a tile that disconnects exactly 1 pipe plays a short crack sound.
- [ ] Rotating a tile that disconnects 3–9 pipes plays "Uh-oh!" voice clip.
- [ ] Rotating a tile that disconnects 10+ pipes plays epic voice clip.
- [ ] No sound plays when rotation improves or maintains connectivity (Δ ≤ 0).
- [ ] All sounds respect the mute toggle.
- [ ] Unit test verifies delta calculation logic.

## Out of Scope
- Visual effects for pipe breakage (future track).
- Custom voice recordings from Alessandro (will replace placeholder TTS later).
- Vibration/haptic feedback on mobile.
