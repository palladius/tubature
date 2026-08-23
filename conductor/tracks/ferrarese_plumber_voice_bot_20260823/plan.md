# Implementation Plan: Ferrarese Plumber Animated Talking Bot & Audio Engine

## Phase 1: Voice Catalog & Audio Trigger Engine
- [ ] Task 1.1: Create `lib/models/voice_catalog.dart` model parsing `assets/voices/voices.json`
- [ ] Task 1.2: Implement voice line trigger logic in `AudioService` with Easter Egg condition (`deadEndCount == 2`)
- [ ] Task 1.3: Update Web Audio synthesizer / HTML5 audio player in `audio_synth_web.dart` to stream and play voice asset files with playback state callbacks
- [ ] Task 1.4: Unit tests for voice line selection, Easter egg trigger conditions, and catalog model
- [ ] Task 1.5: Phase Verification & Checkpoint

## Phase 2: Animated Cartoon Ferrarese Plumber Avatar & Canvas Lip-Sync
- [ ] Task 2.1: Design and generate cartoon character sprite assets for Ermete (prominent nose, greasy plumber cap, open/closed mouth frames)
- [ ] Task 2.2: Implement `ErmetePainter` / `TalkingAvatarWidget` with animated mouth flapping, blinking eyes, and bouncing head bob
- [ ] Task 2.3: Implement comic speech bubble widget with dialect line and Italian subtitles
- [ ] Task 2.4: Widget tests for `TalkingAvatarWidget` state transitions (`idle`, `talking`, `dismissed`)
- [ ] Task 2.5: Phase Verification & Checkpoint

## Phase 3: Game Screen Integration & Gameplay Reactions
- [ ] Task 3.1: Mount `TalkingAvatarOverlay` onto `GameScreen` with smooth entrance and exit animations
- [ ] Task 3.2: Wire victory event trigger from `GameNotifier` with ampolla count
- [ ] Task 3.3: Wire reset / failure event trigger from bottom reset button
- [ ] Task 3.4: Automated QA test via `tool/qa_cartridges.py` verifying audio playback and avatar pop-up
- [ ] Task 3.5: Phase Verification & Checkpoint

## Phase 4: Final Polish & Release
- [ ] Task 4.1: Bump version to `2.3.3` across `lib/version.dart`, `VERSION`, `pubspec.yaml`, and `CHANGELOG.md`
- [ ] Task 4.2: Full validation with `just test` and `flutter analyze`
- [ ] Task 4.3: Deploy to GitHub Pages (`just deploy`) and push to main
