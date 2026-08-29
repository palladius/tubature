# Changelog

All notable changes to FlowConnect (Tubature) are documented here.

## 2.9.1 — 2026-08-29

### Magical Helper Critters Home Animation (V2) 🐉🔧✨
- **Seby's Magical Helper Swarm**: Upgraded default animated home screen to Version 2 where Papino, Alessandro, and Sebastiano stay unique, while a team of 10 adorable magical creatures, baby dragons, and gnomes pop out with mini-wrenches to playfully fix the plumbing!
- **Version 1 Preserved**: Preserved Version 1 animation as `assets/videos/home_background_wide_v1.mp4`.

## 2.9.0 — 2026-08-29

### Veo-Powered Living Painting Home Screen 🎬🪄
- **Living Painting Effect**: When launching the game, players see the static high-resolution background for 2.5s before smoothly fading into a vivid looping animation (*"puff, si comincia ad animare!"*).
- **Veo Character Animation**: Generated custom cinematic character animations with Google Veo (`models/veo-3.1-generate-preview`), bringing Papino Riccardo, Alessandro, Sebastiano, and the green dragon companion to life while keeping the stone dungeon background rock-solid.
- **Orientation Support**: Full Landscape (16:9) and Portrait (9:16) video assets generated (`home_background_wide.mp4` and `home_background_portrait.mp4`) with smooth transitions and graceful fallback.
- **Cross-Platform Bridge**: Refactored JS interop bridge (`js_bridge_stub.dart` / `js_bridge_web.dart`) to ensure 100% unit and widget test compatibility on VM and Web.
- **Generation Tooling**: Added `tool/generate_home_animation_veo.py` with CLI parameters for automated asset generation.

## 2.8.3 — 2026-08-29

### New Goodies & Characters Collection 🧆🚊👦👦🦒🦏🐘🐊♒
- **8 New Circular Goodie Badges**:
  - ♒ **Acquario d'Oro** (RARE): Gold Saint Camus of Aquarius with ice crystals and golden sacred armor.
  - 🫂 **Ale & Sebi** (RARE): Heartwarming brotherly hug in a golden magical runic frame (with Sebi's blonde hair!).
  - 🚊 **Züri-Tram VBZ** (RARE): Classic 3D blue and white Zurich tramway in an ornate brass porthole.
  - 🧆 **Salama da Sugo** (UNCOMMON): 1/4 slice of Ferrara's famous salamina on mashed potato purée with silver runic rim.
  - 👦 **Sebi Biondo** (UNCOMMON): Updated Sebi with golden blonde hair.
  - 🦒 **Giraffa Boxer** (COMMON): Cute boxing giraffe with French beret saying *"Bonjour!"* (Ale's choice!).
  - 🦏 **Rinoceronte Cucciolo** (COMMON): Super kawaii baby rhino with sparkling eyes (Seby's choice!).
  - 🐘 **E-Le-Fante** (COMMON): Joyful baby elephant drinking Tubature Fizzy Orange with bubbles spouting from ears.
  - 🐊 **Coccodrillo Chill** (COMMON): Relaxing on a deckchair with sunglasses, mojito and peace sign ✌️.
- **Goodie Framing**: All goodies unified into circular brass/pipe porthole badges for ampolla dead-ends.

## 2.7.2 — 2026-08-26

### Ferrarese Voices & Image Fix 🎵🖼️
- **Bug Fix**: All goodie images were JPEG files masquerading as `.png` — some mobile browsers rejected them, showing emoji fallback instead of images. Converted all to real PNG with `sips`.
- **New Test**: `goodies_images_test.dart` — 5 tests verifying file existence, non-empty, valid PNG header (magic bytes `89 50 4E 47`), unique IDs, unique paths. Will catch this class of bug forever.
- **12 Ferrarese Voice Clips**: by [Alessandro Verlato](https://github.com/madAle) (Fancy Pixel, Portomaggiore 🇮🇹) — "Piaśér!", "Mo' và che tubatùra!", "Do bàl!", "Ac giurnadàza!" — trimmed, converted to mp3/ogg, wired into VoiceCatalog and soundboard.
- **23 Total Voices**: 7 TTS + 12 human (Ale) + 4 existing = 23 voice lines in soundboard.
- **Infra**: Removed GitLab remote, GitHub is sole `origin`.


### Ruby Brilliant Cut & Cache Fixes 💎
- **New Art**: Ruby gemstone in brilliant cut style with 4 Google-colored gems inside (red, blue, yellow, green)
- **New Goodie**: Ruby Mosaico (RARE) — the Ravenna Byzantine mosaic pentagonal ruby, recycled as a rare collectible ♦️
- **Cache Bust**: Renamed ruby asset to `ruby2.png` to force service worker refresh
- **Prod Cleanup**: Audio Soundboard debug button now hidden in production (localhost only) 🔇
- **Infra**: Removed GitLab remote — GitHub is now the sole `origin`
- **Justfile**: Updated `just deploy` to use `origin` instead of `github`

## 2.7.0 — 2026-08-25

### Rarity System, Debug Gallery & New Goodies 🏅🍕🖼️
- **Rarity System**: MTG-inspired 4-tier rarity: Common (w:10), Uncommon (w:5), Rare (w:2), Legendary (w:1)
- **Weighted Random**: `GoodiesAssigner` uses weighted selection with duplicate avoidance; Legendary only on Hard mode
- **New Goodies**: Pizza Cotto&Funghi 🍕 (Common), Antigravity 🅰️ (Rare, Byzantine mosaic of AGY logo)
- **Full-Page Goodies Gallery**: Debug catalog now opens as a proper full-page route with 3-column grid, circular images, rarity labels, and click-to-fullscreen — replaces the old ugly popup dialog
- **Image Preloading Fix**: `GoodiesImageService.preloadImages()` called before showing catalog — no more emoji fallback!
- **Debug Panel**: Single 🐞 DEBUG button on home screen (localhost only), opens hub with links to Sound Board and Goodies Catalog
- **Replay Hover Fix**: `didUpdateWidget()` now detects `isVictoryCelebrating` true→false transition and calls `_resetAll()`
- **Badge Timing**: 3s delay before badge appears in sidebar (after 6s reveal = 9s total), badges stay until level change
- **Victory Goodies Clickable**: Tap any goodie circle on victory overlay for fullscreen preview with rarity glow
- **Catalog Integrity Tests**: 8 new tests — unique IDs, valid asset paths, rarity tiers, isLegendary derivation, min catalog size
- **12 Goodies Total**: 5 Common, 4 Uncommon, 2 Rare, 1 Legendary

## 2.6.1 — Magic Cauldron Image Reveal 🧪✨
- **New Feature**: CauldronGoodie images emerge from turbulent liquid inside ampolla (dead-end) tiles
- 9 cartoon goodies: Papino, Alessandro, Sebi, Ruby, Dragon, Unicorn, Hot Wheel, Wizard + legendary Schmoogle
- 4-phase convergence animation: turbulent chaos → emerging form → convergence → full reveal (8-10 sec)
- **Easter Egg**: Schmoogle 🐉🔴🔵🟡🟢 — Google-colored legendary dragon (1% chance, Hard mode only)
- Mysterious magical sound effect when Schmoogle appears
- Unique non-repeating goodies per level — every ampolla reveals a different surprise
- Full TDD coverage with 90+ tests

## 2.6.0 — 2026-08-24

### ⌨️ Keyboard Navigation & Controls for Desktop/Web
- **Arrow keys + WASD** navigation — move focus cursor between tiles on the grid
- **Space** rotates focused tile clockwise, **Shift+Space** rotates counter-clockwise
- **R** resets level, **Escape** goes back to home screen
- **Glowing focus ring** — theme-colored border with blur glow around focused tile
- **Toroidal wrapping** — Pac-Man style: right edge wraps to left of same row, etc.
- **Auto-hide on touch** — focus ring disappears when touching/clicking (mobile-friendly)
- **GH Issue**: [#1](https://github.com/palladius/tubature/issues/1)

## 2.5.0 — 2026-08-24

### AI Gameplay Solver & Automated Demo Recording 🤖🎬
- **Deterministic O(n) Solver** — exposes `solvedRotation` cheat code via JS bridge (`window._tubatureGrid`), enabling a Python Selenium script to solve any grid with exact click counts
- **`solvedGrid` in Level model** — level generator now stores the pre-shuffle solved grid alongside the shuffled one
- **Automated Recording Pipeline** — `tool/record_gameplay.py` records gameplay videos with human-like clicking, progress bars, and victory celebration capture
- **Service Worker Cache Bypass** — Chrome headless uses `--incognito` + CDP `Network.setBypassServiceWorker` to always load fresh builds
- **Even-Dimension ffmpeg Fix** — `scale=trunc(iw/2)*2:trunc(ih/2)*2` filter for x264 compatibility with odd viewport heights (915px)
- **README Demo Video** — embedded gameplay recording in README for instant wow-factor
- **`just capture-video`** — one-command video recording with difficulty/device/speed params

## 2.4.2 — 2026-08-24

### Truly Fluid Wave Propagation & Corner Junction Fix 🌊🔧
- **75% Tile Overlap** — reduced stagger from 280ms to 180ms (with 700ms fill), so ~4 tiles fill simultaneously creating a truly continuous sweeping river wave with zero visible pauses
- **L-Corner Junction Fix** — filled gray gap at L/T/cross bend points with junction circles so corners render as seamlessly connected fluid channels
- **Reduced Jitter** — tighter spatial turbulence (±15ms) for smoother natural feel

## 2.4.1 — 2026-08-24

### Google Brand Color Themes & Fluid Wave Propagation 🌊🎨
- **Google 4-Color Themes** — pipe flow colors now cycle through iconic Google Blue (#4285F4), Red (#EA4335), Yellow (#FBBC04), and Green (#34A853)
- **Fluid Sequential Wave** — water propagation now overlaps ~60% between adjacent tiles (280ms stagger, 700ms fill), so 2-3 tiles fill simultaneously creating a continuous sweeping river wave instead of stop-and-go tile-by-tile animation
- **Conductor Track Created** — `automated_gameplay_recording_20260824` registered for video recording pipeline

## 2.4.0 — 2026-08-24

### Torrential River Flood ("Fiume in Piena") Simulation Engine 🌊🏞️⚡
- **Asymmetric Flash Flood Wave** — water bursts into dry pipes like a dam break, surging along the left/right banks at differing speeds with turbulent parabolic tongue inertia
- **Foaming Crest & Spray Splashes** — thick white frothing wave head with dynamic spray beads and splashing water droplets jumping ahead of the flood
- **Centrifugal Corner Sloshing** — water rushes against the outer pipe wall with natural inertia before wrapping around corner and tee bends
- **Continuous 60 FPS Living River Current** — connected pipes maintain multi-layered flowing sinusoidal streamlines, traveling sunlight caustics, and drifting micro-bubbles
- **Conductor Track Completed** — verified and marked `water_flow_animation_20260823` Phase 5 complete in Conductor registry

## 2.3.4 — 2026-08-24

### Crystal-Clear Audio Mastering & Consonant Clarity 🎙️🔊✨
- **Cleaned Vocal Formants** — removed murky -12/-5 semitones down-pitching that rendered voice lines muffled and unintelligible
- **Broadcast Loudness Normalization (EBU R128)** — boosted speech volume to `volume=2.2` with high-pass filtering (80Hz) to cut sub-bass rumble and `treble=g=4` to bring out clear consonant presence
- **Tuned Dialect Phonation** — all Romagnolo, Ferrarese and arcade voice lines are now 100% crystal-clear and intelligible
- **Synced Asset Catalog** — updated `voices.json` and `lib/models/voice_entry.dart` across all good/bad voice lines

## 2.3.3 — 2026-08-23

### Ferrarese Plumber Voice Reactions & Animated Lip-Sync 🎭🎙️👃
- **Ermete da Ferrara Talking Avatar** — cartoon plumber avatar with signature prominent Ferrarese nose 👃, messy green cap 🧢, thick mustache, and synchronized animated mouth flapping when voice lines are spoken!
- **Comic Speech Bubbles** — picture-in-picture pop-up balloon showing authentic Ferrarese / Romagnolo dialect lines with Italian subtitles
- **Easter Egg: "Mayàl, ac du bàl!"** — triggers 100% of the time when solving a puzzle with **exactly 2 ampolle**!
- **Good & Bad Categorized Voice Catalog** — organized voice assets into `assets/voices/good/` and `assets/voices/bad/` for easy expansion
- **Reset & Misplay Voice Reactions** — Ermete reacts with *"Ac giurnadàza!"* or *"Non capisci proprio un tubo!"* when resetting a puzzle

## 2.3.2 — 2026-08-23

### Organic Liquid Fluid Simulation & Mobile UI Fix 🌊🫧📱
- **Turbulent Fluid Chaos & Jitter** — replaced deterministic BFS delays with organic spatial chaos delays (`TileWidget._triggerFlowAnimation`) creating realistic fluid bursts and surges through pipes
- **Dynamic Caustic Waves & Moving Bubbles** — animated pulsating liquid shimmer (`PipePainter`) with floating micro-bubbles and moving caustic highlights
- **Surging Meniscus Pressure Front** — dynamic curved meniscus with light aura when water rushes into empty pipes
- **Swirling Ampolla Chamber** — dead-end flasks now feature swirling liquid cores and floating bubbles
- **Pixel 10 Mobile Portrait Layout Overhaul** — spacious 2x2 difficulty selector cards with 56dp+ touch targets, 60dp PLAY button, and anti-squish glassmorphic container
- **Aggressive Cache-Busting for Mobile Web** — added Cache-Control meta headers and `flutter_bootstrap.js?v=2.3.2` query parameter to force phone browsers to immediately display the updated UI

## 2.3.0 — 2026-08-23

### Riccardo, Ale & Seby: The Dungeon Plumbers! 🚰👦🧒🐉💎
- **Family Character Consistency** — starring **Riccardo** (yellow **"R"** cap), **Alessandro** (green **"A"** cap), and **Sebastian** (orange **"S"** cap with little wrench) along with their cute baby emerald dragon companion
- **Dual-Orientation Title Screens** — pixel-perfect portrait (3:4) and widescreen (16:9) background artworks
- **Pixel 10 & Mobile-First UI** — top title header + bottom-docked glassmorphic control sheet leaving character art completely visible
- **Custom Riccardo App Icons & Favicon** — cropped 512px, 192px app icons and favicon
- **Live Play Badge** — added permalink directly at the top of README.md

## 2.2.1 — 2026-08-23

### Pixel 10 & Mobile Portrait Layout Overhaul 📱✨
- **Unobstructed Hero Artwork** — on mobile portrait screens, the game title floats at the top while the interactive control panel docks at the bottom, leaving Riccardo and the baby dragon visible in the center
- **Riccardo App Icon & Favicon** — cropped Riccardo's friendly yellow "R" cap face into high-res 512px, 192px app icons and favicon
- **Mobile Viewport Fit & CSS Reset** — added `viewport-fit=cover`, `touch-action: manipulation`, and user-select locks to HTML
- **README Game Permalink** — added prominent live play link badge at top of README.md

## 2.2.0 — 2026-08-23

### Riccardo the Dungeon Plumber Title Overhaul 🚰🐉💎
- **Riccardo the Plumber Hero Artwork** — starring Riccardo in his signature yellow cap with red **"R"**, blue overalls, magic glowing golden wrench, and cute baby dragon companion
- **Dynamic Dual-Orientation Backgrounds** — automatic switching between vertical portrait (`assets/images/home_background.jpg`) on phones/tablets and panoramic 16:9 widescreen (`assets/images/home_background_wide.jpg`) on desktop/tablets
- **Glassmorphic Hero Title Panel** — gold embossed `TUBATURE` branding, subtitle *"THE DUNGEON PLUMBER: Quest for the Crystal Springs"*, glowing 2×2 difficulty cards, and hero Play/Tutorial actions
- **Trademark Safe & Cohesive Lore** — distinct Italian dungeon plumber artificer hero repairing mystical conduit networks in ancient D&D castles

## 2.1.2 — 2026-08-23

### Mobile-First Responsive Home Screen 📱🚰
- **Fixed Mobile Sizing & Zoom** — locked HTML viewport to 1:1 scale (`user-scalable=no, maximum-scale=1.0`), preventing accidental browser zoom-out and microscopic UI on high-DPI mobile devices
- **2×2 Large Difficulty Cards** — replaced cramped wrap chips with prominent full-width 2×2 grid cards designed for large finger taps (≥56dp)
- **Full-Width Hero Buttons** — primary PLAY button ($72\text{dp}$ tall) and TUTORIAL button expand across the layout with clear bold typography and soft shadows
- **Responsive Layout** — constrained layout automatically centers on desktop while filling 100% of mobile screens with comfortable padding

## 2.1.1 — 2026-08-23

### Pure Fantasy Medieval & D&D Themes 🐉🧙💎
- **Removed Space Theme** — transitioned all themes and creature sources to cohesive medieval fantasy, dungeons, crystals, and gemstones
- **Added Crystal Caves Theme (💎)** — glowing turquoise water, luminous crystals, and faceted gemstone source icon
- **Bundled 5 High-Resolution Fantasy Backgrounds** — crystal cave, dungeon treasure vault, dragon gem lair, wizard alchemy lab, and dungeon aqueduct ready for background art & reveal modes
- **Updated Home Screen Header** — header icons updated to `🐉 🧙 💎`

## 2.1.0 — 2026-08-23

### Fluid Flow, Victory Admiration & Audio 🌊🎵
- **Dynamic BFS Water Flow Animation** — fluid advances through newly connected pipes with progressive depth delays (60ms/step), creating a lively wave from the source
- **Ampolla Sparkle & Liquid Fill** — sealed dead-end flasks light up with animated liquid glow and sparkle effects when fluid arrives
- **Victory Input Lock & 3-Second Admiration Window** — board input immediately locks on win while a full-network fluid pulse and celebratory banner (`ALL PIPES CONNECTED! 🌊✨`) let players admire their completed puzzle for 3 seconds before the victory card appears
- **Procedural Sound Effects & Web Audio Synthesis** — mechanical pipe clicks on rotation, organic water bubbling whooshes on fluid advancement, and an arpeggio victory fanfare, with top-bar sound toggle

## 2.0.5 — 2026-08-23

### UI/UX Fixes 🎨
- **Play Button Redesign** — standardized PLAY button label to `▶ PLAY!` across all difficulty choices, preventing any multi-line wrapping or text cut-off
- **Dynamic Mode Caption** — selected difficulty and grid dimensions (e.g. `🟢 Fixed Easy mode (6×6 grid)`) are cleanly displayed below the button
- **High-Contrast Theme Chips** — deep solid chip colors with crisp bold white text for maximum legibility

## 2.0.4 — 2026-08-23

### UI/UX & Quality Improvements 🧪
- **Fixed Button Text Clipping** — wrapped Play button label in `FittedBox` with adaptive scaling, preventing multi-line overflow when difficulty names are displayed
- **Enhanced Difficulty Chip Contrast** — increased contrast on active chips (deep emerald, amber, and berry backgrounds with crisp bold white text)
- **Automated Visual QA Suite** — added `tool/qa_runner.py` and `just qa` for continuous headless visual inspection and playability regression checks

## 2.0.3 — 2026-08-23

### Visual & UX Improvements 🎨
- **Seamless Corner Pipes** — removed the ugly circular center juncture blob; corners now render as clean continuous rounded elbows
- **Dead-End "Ampolla" Redesign** — terminations now look like sealed glass magic flasks/bulbs with liquid fills and specular glass highlights
- **Home Screen Difficulty Selector** — kids can now choose Auto ⚡, Easy 🟢 (6×6), Medium 🟡 (7-8), or Hard 🔴 (9-10) directly from home
- **Clean T-Junctions & Crossings** — layered drawing prevents seams at pipe intersections

## 2.0.2 — 2026-08-23

### Bug Fixes 🔧
- **Fixed pipe bleeding** — canvas clipping prevents thick strokes from overflowing into neighboring cells
- **Removed glow effect** — `MaskFilter.blur` doesn't respect `clipRect` on Flutter Web CanvasKit
- **Reverted corner pipes** — back to original two-line + center-circle style (arcs were broken)
- **Robust deploy** — `just deploy` copies build to /tmp before branch switch, auto-rebuilds for localhost

## 2.0.1 — 2026-08-23

### Visual Improvements 🎨
- **Smooth corner pipes** — L-tiles now use quarter-circle arcs instead of ugly 3-piece joints
- **Better T-junctions** — straight-through pipe with clean branch, no more circle blobs
- **Bigger grids** — Easy 6×6, Medium 7-8, Hard 9-10 (kids said it was too easy!)
- **Direction-biased DFS** — 60% same-direction preference creates longer chains, fewer dead-ends
- **Faster difficulty ramp** — Medium after 2 wins, Hard after 5

## 2.0.0 — 2026-08-23

### 💥 BREAKING: New Game Mechanics
- **Removed Sink** — no more endpoint tile. Only the Source remains.
- **Fill ALL tiles** — win condition is now: every tile on the grid must be connected to the source
- **Spanning tree level generation** — randomized DFS creates grids where ALL tiles form one connected network when correctly rotated. Every generated level is guaranteed solvable!
- **Dead-end tiles** — new cap tile type with 1 opening, for tree leaf nodes

### Added
- 💧 **Progress indicator** — shows "X/Y" connected tiles count during gameplay
- 📌 **Version footer** — `v2.0.0` shown on home screen
- 🔍 **Pinch-to-zoom** — viewport allows 0.5x to 5x zoom for accessibility
- 🚀 **GitHub Pages** — playable at https://palladius.github.io/tubature/
- 📦 **`just deploy`** — one-command deployment to GitHub Pages
- 📦 **`just serve`** — local web server on port 8765

### Removed
- ❌ `TileType.sink` — removed from tile enum entirely
- ❌ Sink creatures (gems, dungeon, starship) — only source creatures remain
- ❌ Source-to-sink path generation — replaced by spanning tree

## 1.1.0 — 2026-08-22

### Fixed
- 🐛 **CRITICAL: Levels now have solutions!** — Sink opening was pointing outward (off the grid), making every generated level unsolvable
- 🐛 **CRITICAL: Path now connects through source/sink openings** — Path generator now ensures the pipe path enters through the source's opening direction and arrives at the sink's opening direction
- 🐛 **Pre-shuffle solution verification** — Generator now verifies the grid is actually solved before shuffling, rejecting bad generations

### Changed
- ❌ **Removed cross (+) tiles** — They're rotationally symmetric (rotating does nothing), which confuses players and makes the puzzle less interesting
- 📈 **Progressive difficulty** — Single "PLAY" button now auto-escalates: Easy (levels 1-3) → Medium (levels 4-7) → Hard (levels 8+)
- 🏠 **Simplified home screen** — One big PLAY button + Tutorial, instead of separate Easy/Medium buttons
- 📊 **Level counter in top bar** — Shows "Level 5 • Medium" instead of just difficulty name
- 🧠 **More interesting paths** — BFS now shuffles directions for varied, non-trivial path layouts

### Added
- 🧪 **55+ tests** — Up from 29, including gameplay simulation, generator diagnostics, DFS-based solvability proof, progressive difficulty, and edge cases

## 1.0.0 — 2026-08-22

### Added
- 🎮 **Full playable game** — pipe-puzzle with tap-to-rotate mechanics
- 🐉 **3 creature themes**: Dragon→Gems, Wizard→Dungeon, Space→Starship
- 📐 **Grid sizes**: Easy (5×5), Medium (6×6, 7×7)
- 🧠 **Algorithmic level generator** with guaranteed solvability
- 📖 **10 tutorial levels** of increasing complexity
- 🎨 **5 color palettes**: Emerald, Purple, Blue, Orange, Teal
- ✨ **Victory celebration** with confetti and multilingual text (MAGNIFICO/BRAVO/WOW)
- 🎯 **Riverpod state management** for clean, testable architecture
- 🧪 **29 unit tests** with 90%+ coverage on game logic
- 📱 **Android-first** with 56dp+ kid-friendly tap targets
- 🌐 **Web build** for Chrome browser testing
- 🚰 **CustomPainter pipe rendering** with chunky, colorful, glowing pipes
- 🦄 **Creature painters** — Dragon, Wizard, Rocket, Gems, Dungeon, Starship
- 🔄 **Smooth rotation animation** (200ms) with scale pulse feedback
- 📊 **Move counter** in-game

## 0.1.0 — 2026-08-22

- Initial project setup
- Imported FlowConnect game design doc from Obsidian
- Copied 5 design reference images
- Chose Flutter/Dart as tech stack (Android + iOS + Web)
- Initialized git repo at ~/git/tubature/
