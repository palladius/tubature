# Plan: Dynamic Pipe Break Sound Effects 💥🔊

## Phase 1: Delta Calculation Logic
- [ ] Task: Add connectivity delta calculation in `game_notifier.dart`
  - [ ] In `rotateTile()`, compute connected tiles count before rotation
  - [ ] After rotation, compute connected tiles count again
  - [ ] Calculate Δ = before - after
  - [ ] If Δ > 0, call `AudioService.playBreakSound(delta: Δ)`
- [ ] Task: Write unit tests for delta calculation
  - [ ] Test Δ = 0 (no change) → no sound
  - [ ] Test Δ = 1 (minor) → minor break sound
  - [ ] Test Δ = 5 (moderate) → moderate break sound
  - [ ] Test Δ = 12 (catastrophic) → catastrophic break sound
- [ ] Task: Phase Verification & Checkpoint (Refer to workflow.md)

## Phase 2: Procedural Break Sound (Web Audio)
- [ ] Task: Add `playBreakSound()` to `audio_synth_web.dart`
  - [ ] Minor break (Δ=1): short noise burst + high-freq decay (glass crack)
  - [ ] Expose via JS interop like existing sounds
- [ ] Task: Add stub in `audio_synth_stub.dart`
- [ ] Task: Phase Verification & Checkpoint (Refer to workflow.md)

## Phase 3: Voice Clip Integration
- [ ] Task: Generate/place TTS placeholder clips
  - [ ] `assets/voices/good/tmp-majjal.mp3/.ogg` — "Mayyàl!" (already done ✅)
  - [ ] `assets/voices/bad/tmp-aldamar.mp3/.ogg` — "Aldamàr!" (already done ✅)
  - [ ] Future: Replace with Ale's recordings (see issue #5)
- [ ] Task: Wire clips into `AudioService.playBreakSound()`
  - [ ] Δ=1: procedural crack
  - [ ] 3≤Δ<10: play "Aldamàr!" clip
  - [ ] Δ≥10: play "Mayyàl!" clip (or future epic clip)
- [ ] Task: Add to `VoiceCatalog` with `engine: "tts"` + `tmp-` prefix convention
- [ ] Task: Phase Verification & Checkpoint (Refer to workflow.md)

## Phase 4: Integration & Polish
- [ ] Task: Verify mute toggle respected for all break sounds
- [ ] Task: Test in-game: rotate tiles to break connections, verify sounds
- [ ] Task: Version bump + CHANGELOG update
- [ ] Task: `flutter analyze` — 0 issues
- [ ] Task: `flutter test` — all pass
- [ ] Task: Phase Verification & Checkpoint (Refer to workflow.md)
