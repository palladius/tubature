# Tech Stack

## Core Technologies
- **Language**: [Dart](https://dart.dev/)
- **Framework**: [Flutter](https://flutter.dev/) (Cross-platform: Web, Android, iOS)
- **State Management**: [Riverpod 2.x](https://riverpod.dev/) (`flutter_riverpod`)
- **Rendering Engine**: Flutter Canvas (`CustomPainter`) for high-performance pipe and grid rendering
- **Testing**: `flutter_test`, `mocktail`
- **Deployment Targets**:
  - **Web**: GitHub Pages
  - **Mobile**: Android (Google Play future), iOS

## Architecture
- **Layered Architecture**: `Models` → `Logic / Providers` → `Widgets / Painters` → `Screens`
- **Game Mechanics**: Spanning tree generation, rotation logic, flow-tracing algorithms
- **Assets**: Lightweight vector/raster assets per theme
