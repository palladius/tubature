# Spec: Four Elements Theme — Water 💧, Lava 🌋, Earth 🏔️, Air 💨

**Track ID**: `four_elements_theme_20260824`
**Type**: Feature (P4 — Inspirational, far future)
**GH Issue**: [#3](https://github.com/palladius/tubature/issues/3)
**Priority**: 🌱 P4 — Seed idea, not for today

## Overview

Transform the 4 Google brand colors into 4 **elemental pipe worlds**, each with unique flow animations, procedural sound design, pipe visual aesthetics, and creature companions. This is the "endgame" vision for Tubature's theming system.

## The Four Elements

### 💧 Water (Blue — `#4285F4`)
- **Flow**: Crystal water with bubbles, ripples, foam at junctions
- **Sound**: Glub glub, rushing stream, drip-drop in dead-ends
- **Pipes**: Copper/bronze aqueduct pipes, aged patina
- **Companion**: Water dragon 🐉, fish sprites in the flow

### 🌋 Lava/Fire (Red — `#EA4335`)
- **Flow**: Glowing magma, ember particles, heat shimmer
- **Sound**: Deep rumble, crackling, hissing at junctions
- **Pipes**: Obsidian/dark stone channels, glowing cracks
- **Companion**: Fire salamander 🔥, tiny phoenixes

### 🏔️ Earth/Land (Green — `#34A853`)
- **Flow**: Roots/vines growing through channels, or dwarven rail carts on tracks
- **Sound**: Grinding stone, dwarves hammering/tinkering, pickaxe clinks ⛏️
- **Pipes**: Stone tunnels, wooden scaffolding, mine cart rails
- **Companion**: Dwarves with hard hats, moles digging

### 💨 Air/Gas (Yellow — `#FBBC04`)
- **Flow**: Swirling wind, sparkles, cloud puffs, dandelion seeds
- **Sound**: Swoosh, whistle, gentle breeze, wind chimes
- **Pipes**: Glass/crystal tubes, visible wind currents inside
- **Companion**: Wind sprites, tiny clouds with faces ☁️

## Technical Vision

- Each element = a `PipeTheme` bundle: `flowAnimation`, `soundPack`, `pipeStyle`, `companion`
- Progressive unlock: Water (default) → Earth (level 10) → Air (level 25) → Lava (level 50)
- Seasonal events: "Lava Week" where all pipes are volcanic
- Advanced: mixed-element levels with multiple sources!

## Why This Is Exciting

- 4 arbitrary colors → 4 **meaningful, immersive worlds**
- Kids can have a "favorite element" (like Harry Potter houses!)
- Each element creates a different ASMR-like satisfying experience
- Massive replay value — same puzzle, completely different feel
- Sound design becomes a core gameplay differentiator

## Out of Scope (Even for this P4)

- Elemental interactions (water + lava = obsidian)
- Multiplayer element battles
- Element-specific puzzle mechanics (fire melts ice barriers, etc.)

## Status

🌱 **Seed planted.** This track exists to capture the vision. Implementation is far future — after keyboard controls, CLI mode, and core gameplay polish are complete.
