# Tubature - The Magic Plumber 🚰

# Default: show available commands
list:
    just -l

# Run all tests
test:
    flutter test

# Run tests with coverage
coverage:
    flutter test --coverage
    @echo "Coverage report at coverage/lcov.info"

# Generate HTML coverage report (requires lcov: brew install lcov)
coverage-html: coverage
    genhtml coverage/lcov.info -o coverage/html
    @echo "Open coverage/html/index.html in your browser"

# Run static analysis
analyze:
    flutter analyze

# Run on Chrome (web)
run-web:
    flutter run -d chrome

# Build for web
build-web:
    flutter build web

# Build Android APK
build-apk:
    flutter build apk

# Clean build artifacts
clean:
    flutter clean
    flutter pub get

# Run analyze + tests (CI check)
ci: analyze test

# Full check: analyze + tests with coverage
check: analyze coverage
