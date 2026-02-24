# AGENTS.md

## Build and Test Commands (Mandatory For Every Change)

```bash
flutter pub get
dart format .
flutter analyze
flutter test
```

- The above commands must all complete successfully for each change (at least before commit).

## Testing Instructions

- Test files are in `test/`.
- Run all tests: `flutter test`
- Run a specific test: `flutter test test/file_service_test.dart`
- Artist semantics test: `flutter test test/metadata_service_test.dart`
- **All tests must pass before committing.**

## Architecture Guidelines

- **Screen files** (`lib/screens/`) are **UI-only**. They only assemble widgets and wire providers.
- **Widget files** (`lib/widgets/`) are **UI-only**. They must not contain business logic.
- No computation, I/O, or state mutation is allowed in screens/widgets. Dispatch to provider/service.
- Each feature must be modular: UI sections live in `lib/widgets/<feature>/` (one file per logical section), state/business logic live in `lib/providers/<feature>_provider.dart`, and I/O/persistence/external calls live in `lib/services/<feature>_service.dart`.

Standard layout for a new feature:

```text
lib/
├── providers/
│   └── <feature>_provider.dart     # State + business logic
├── services/
│   └── <feature>_service.dart      # Persistence / I/O (if needed)
├── screens/
│   └── <feature>_page.dart         # UI assembly only
└── widgets/
    └── <feature>/
        └── <section>_widget.dart   # Reusable UI sections
```

## Code Style Guidelines

- Follow `package:flutter_lints/flutter.yaml`.
- Use `// ignore: rule_name` for single-line suppression.
- Use `// ignore_for_file: rule_name` for file-level suppression.
- Keep all constants in `lib/constants.dart`; do not scatter magic values.
- Prefer `const` constructors when possible.

## Security Considerations

- File rename operations must sanitize filenames with `AppConstants.invalidFilenameChars`.
- Paths with directory traversal attempts (for example `..\`) must be stripped to basename only.
- Empty or invalid filenames (`.`, `..`, whitespace-only) must be rejected.

## PR Instructions

- Title format: `[<scope>] <description>` (example: `[fix] Fix file rename bug`)
- Before PR/commit, mandatory checks are: `dart format .`, `flutter analyze` (no issues), and `flutter test` (all tests passing).
- Update version in `pubspec.yaml` if releasing.

## Internationalization (i18n)

- ARB files are in `lib/l10n/`.
- Template file: `app_en.arb`
- Supported locales: English (`en`) and Chinese (`zh`).
- l10n config file: `l10n.yaml`
- Use translations via `AppLocalizations.of(context)!.keyName`.

This file only contains mandatory project rules. For all descriptive information, refer to README.md.
