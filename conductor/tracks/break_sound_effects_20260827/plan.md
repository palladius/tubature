# Plan: Dynamic Pipe Break Sound Effects 💥🔊

## Phase 1: Delta Calculation Logic
- [x] Task: Add connectivity delta calculation in `game_notifier.dart`
  - [x] In `rotateTile()`, compute connected tiles count before rotation
  - [x] After rotation, compute connected tiles count again
  - [x] Calculate Δ = before - after
  - [x] If Δ > 0, call `AudioService.playBreakSound(delta: Δ)`
- [ ] Task: Write unit tests for delta calculation
  - [ ] Test Δ = 0 (no change) → no sound
  - [ ] Test Δ = 1 (minor) → minor break sound
  - [ ] Test Δ = 5 (moderate) → moderate break sound
  - [ ] Test Δ = 12 (catastrophic) → catastrophic break sound
- [ ] Task: Phase Verification & Checkpoint (Refer to workflow.md)

## Phase 2: Procedural Break Sound (Web Audio)
- [x] Task: Add `playBreakSound()` to `audio_synth_web.dart`
  - [x] Minor break (Δ=1): white noise burst + high-freq square osc decay (glass crack)
  - [x] Expose via JS interop like existing sounds
- [x] Task: Add stub in `audio_synth_stub.dart`
- [x] Task: Phase Verification & Checkpoint — analyze 0 issues ✅

## Phase 3: Voice Clip Integration
- [x] Task: Generate/place TTS placeholder clips
  - [x] `assets/voices/good/tmp-majjal.mp3/.ogg` — "Mayyàl!"
  - [x] `assets/voices/bad/tmp-aldamar.mp3/.ogg` — "Aldamàr!"
  - [ ] Future: Replace with Ale's recordings (see issue #5)
- [x] Task: Wire clips into `AudioService.playBreakSound()`
  - [x] Δ 1–2: procedural crack
  - [x] Δ 3–9: play "Aldamàr!" clip
  - [x] Δ ≥ 10: play "Mayyàl!" clip
- [ ] Task: Add to `VoiceCatalog` with `engine: "tts"` + `tmp-` prefix convention
- [x] Task: Phase Verification & Checkpoint — deployed to GH Pages ✅

## Phase 4: Integration & Polish
- [x] Task: Verify mute toggle respected for all break sounds
- [ ] Task: Test in-game: rotate tiles to break connections, verify sounds
- [ ] Task: Version bump + CHANGELOG update
- [x] Task: `flutter analyze` — 0 issues ✅
- [x] Task: `flutter test` — 34/34 pass ✅
- [x] Task: Phase Verification & Checkpoint — deployed ✅
