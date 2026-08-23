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

# Serve web build locally on port 8765 (kills old server, builds fresh)
serve:
    -lsof -ti :8765 | xargs kill 2>/dev/null
    flutter build web
    cd build/web && python3 -m http.server 8765

# Deploy to GitHub Pages (https://palladius.github.io/tubature/)
# NOTE: copies build to /tmp first since gh-pages checkout cleans build/
deploy:
    flutter build web --base-href '/tubature/'
    cp -r build/web /tmp/tubature_deploy
    @echo "🚀 Deploying to GitHub Pages..."
    git stash --quiet 2>/dev/null || true
    git checkout gh-pages
    git rm -rf . --quiet 2>/dev/null || true
    cp -r /tmp/tubature_deploy/* .
    rm -rf .dart_tool .idea
    git add -A
    git commit -m 'deploy: update GitHub Pages'
    git push github gh-pages
    git checkout main
    git stash pop --quiet 2>/dev/null || true
    rm -rf /tmp/tubature_deploy
    @echo "✅ Deployed! Visit: https://palladius.github.io/tubature/"
    @echo "⚠️  Rebuilding for localhost (no base-href)..."
    flutter build web
    @echo "✅ Localhost build ready. Run: just serve"
