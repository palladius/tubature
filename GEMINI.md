# Tubature — Gemini Agent Notes

## Documentazione

- [docs/ferrarese.md](docs/ferrarese.md) — 🗣️ Glossario ferrarese: fonetica, ortografia e guida TTS per il dialetto usato nel gioco. **IMPORTANTE**: la J ferrarese si pronuncia come la Y inglese (majjal → "mayyàl").

## Key Facts

- Il dialetto ferrarese usa la **J** dove l'italiano userebbe la **GL** o la **I** semivocalica.
- Per generare audio TTS, usare la pronuncia fonetica (es. "mayyàl") ma nei nomi file/codice usare l'ortografia corretta (es. "majjal").
- **Mobile Pixel 10 Auto-Fit & CDP Verification (`/learn` 2026-11-14)**: In Flutter Web mobile games, never clamp grid tile sizes to a fixed minimum like `48px` (which overflows `7×7`–`10×10` boards on Pixel 10 portrait and `+20%` zoom); use deterministic `LayoutBuilder` auto-fit + `InteractiveViewer`, keep revealed goodie badges in a non-overlapping `Column` shelf (`_buildGoodiesShelf`), export `RenderBox` bounds to `window._tubatureBoardRect` for CDP verification, and pass `-vf "scale=trunc(iw/2)*2:trunc(ih/2)*2"` to `ffmpeg` when recording `412×915` odd-height mobile viewports.
- **Raspberry Pi 400 ("Sguisatazzo") Compliance (`/learn` 2026-11-15)**: See skill `raspberry-pi-game-optimization`. Always auto-detect `Linux aarch64` / `devicePixelRatio <= 0.85` / `?rpi=1` via `PerformanceConfig`, delete `window.ImageDecoder` on WebKit2GTK 2.54 so CanvasKit uses its internal Skia WASM codec, downscale decoded textures (`targetWidth: 128`) to fit the BCM2711 1 MB L2 cache, wrap every grid tile in `RepaintBoundary`, stop continuous idle tickers (`0% idle CPU`), and bypass `canvas.saveLayer`, `MaskFilter.blur`, and `BackdropFilter` in RPi Turbo mode.
