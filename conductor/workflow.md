# Development Workflow

## TDD & Quality Gates
Follow the standard Test-Driven Development (TDD) cycle:
1. **Write Tests First**: Create unit and widget tests defining the expected behavior.
2. **Implement**: Write minimal, clean code to pass tests.
3. **Verify**:
   - `flutter analyze` must show **0 issues** (zero warnings / errors).
   - `flutter test` must **pass all tests**.
4. **Commit**: Keep commits small, atomic, and well-described.

## Versioning & Releases
When completing features or bugfixes that warrant a version bump:
- Update `VERSION`
- Update `pubspec.yaml` (`version: x.y.z+n`)
- Update `lib/version.dart` (if present)
- Document changes in `CHANGELOG.md`

## Commit Conventions
- Use standard Conventional Commits format (`feat(...)`, `fix(...)`, `chore(...)`, `test(...)`, `refactor(...)`).
- Always use **single quotes** in git commit commands: `git commit -m '...'`.
