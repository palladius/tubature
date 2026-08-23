# Specification: Ferrarese Plumber Animated Talking Bot & Audio Engine

## Overview
An interactive, animated cartoon character ("Ermete the Ferrarese Plumber" from *La Bassa*) who reacts to gameplay events with authentic Ferrarese / Romagnolo voice lines and synchronous animated mouth movement ("lip-sync flapping") inside a lively picture-in-picture speech bubble widget.

---

## Character Persona & Visual Design
- **Character Name**: *Ermete / Ermanno* (The Ferrarese Dungeon Plumber from *La Bassa*)
- **Visual Traits**:
  - Distinctive prominent Roman / Ferrarese nose 👃
  - Disheveled plumber cap with grease stains 🧢
  - Thick comedic mustache & expressive bushy eyebrows
  - Low-class, working-class, funny, warm, yet loud and colorful arcade persona
- **Animation States**:
  - `idle`: Calm blinking, breathing, slight mustache wiggle
  - `talking`: Mouth cycling open/closed with phoneme flap frequency synchronized to audio playback duration (~120-180ms per flap cycle)
  - `celebrating`: Eyes wide, happy grin with thumbs up
  - `frustrated`: Angry eyebrows, mouth wide yelling

---

## Functional Requirements

### 1. Voice Trigger System & Catalog
- **Event 1: Level Completed / Victory**:
  - If board has **EXACTLY TWO ampolla dead-ends** (`deadEndCount == 2`):
    - **Trigger Easter Egg Line**: `mayal-ac-du-bal` (*"Mayàl, ac du bàl!"* 🥚🥚)
  - Otherwise, randomly select from the positive victory pool:
    - `a-scor-cle-un-piaser` (*"A scòr ch'l'è un piaśér!"*)
    - `a-scor-cle-un-piaser-low` (*"A scòr ch'l'è un piaśér!"* - Ottava Bassa)
    - `mo-va-che-tubatura` (*"Mo và che tubatùra!"*)
- **Event 2: Puzzle Reset / Frustration / Misplays**:
  - Triggered on Reset button tap or multiple failed moves:
    - `ac-giurnadaza` (*"Ac giurnadàza!"*)
    - `non-capisci-proprio-un-tubo` / `non-capisci-un-tubo` (*"Non capisci proprio un tubo!"*)

### 2. Audio Playback Engine
- Web and native audio playback for `.mp3` / `.ogg` files from `assets/voices/`.
- Expose `AudioService.playVoice(VoiceEvent event, {int ampollaCount})`.
- Provide audio playback duration and callback when speech begins and ends to drive character animation state.

### 3. Floating Picture-in-Picture Avatar Widget
- **Placement**: Bottom corner floating overlay (or docked near the HUD) with clean glassmorphic frame and cartoon drop shadow.
- **Speech Bubble**: Comic-book style balloon with tail pointing to Ermete's mouth.
  - Line 1 (Dialect): e.g., *"Mayàl... ac du bàl!"*
  - Line 2 (Subtitle): e.g., *"Maiale, che due palle!"*
- **Pop-in / Pop-out Transitions**: Smooth slide-and-bounce spring animation when popping up, auto-dismissing 1.2s after voice line finishes.

---

## Acceptance Criteria
- [ ] Voice lines play cleanly in browser (Web) and mobile when triggered.
- [ ] Completing a level with exactly 2 ampolle triggers *"Mayàl, ac du bàl!"* 100% of the time.
- [ ] Regular victories trigger lines 1, 2, or 3.
- [ ] Resets or game over triggers lines 4 or 5.
- [ ] Ermete's mouth actively flaps open and closed while audio is playing, returning to idle when speech ends.
- [ ] Comic speech bubble displays dialect phrase and Italian subtitle.
- [ ] Mute toggle in header silences voices without crashing or blocking the UI.
- [ ] Passes `flutter analyze` and `flutter test`.
