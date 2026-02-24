# AGENTS.md

## Scope & Usage (Read-Only)

- This file defines mandatory rules for this repository.
- It is the single source of truth for architecture, code style, and safety constraints.
- AI agents and automation tools must treat `AGENTS.md` as read-only.
- Do not modify, rewrite, or delete this file unless explicitly instructed by a human.

## Non-Negotiables

- Never delete or skip tests, and never weaken assertions to make them pass.
- Never move business logic into `lib/screens/` or `lib/widgets/`.
- Never add a new dependency without a documented reason in the PR.
- Never do broad drive-by refactors of formatting or file structure unless explicitly requested.

## Mandatory Commands (Every Change)

```bash
flutter pub get      # Required when pubspec.yaml or pubspec.lock changes
dart format .
flutter analyze      # Must be clean (0 issues)
flutter test         # All pass
```

- All mandatory commands must pass before commit/PR.

## Testing

- Test files are in `test/`.
- Run all tests: `flutter test`
- File service tests: `flutter test test/file_service_test.dart`
- Metadata semantics tests: `flutter test test/metadata_service_test.dart`
- If changes touch file rename logic or `file_service`, also run `flutter test test/file_service_test.dart`.
- If changes touch metadata parsing or artist semantics, also run `flutter test test/metadata_service_test.dart`.
- All tests must pass before commit.

## Architecture Guidelines

- `lib/screens/` and `lib/widgets/` are UI-only (no business logic, computation, I/O, or state mutation).
- Business logic and state changes must be dispatched to `providers/` or `services/`.
- Feature layering is mandatory.
- UI: `lib/widgets/<feature>/`
- State and business logic: `lib/providers/<feature>_provider.dart`
- I/O and persistence: `lib/services/<feature>_service.dart`

## Code Style Guidelines

- Strictly follow `package:flutter_lints/flutter.yaml`.
- Keep all constants in `lib/constants.dart`.
- Prefer `const` constructors whenever possible.
- Use ignore directives only when necessary and narrowly scoped (`// ignore:` / `// ignore_for_file:`).

## Security Considerations

- Filename sanitization must use `AppConstants.invalidFilenameChars`.
- Reject directory traversal input (for example `..\`) and keep basename only.
- Reject invalid filenames: `.`, `..`, and whitespace-only values.

## PR Instructions

- Title format: `[<scope>] <description>` (example: `[fix] Fix file rename bug`).
- Mandatory pre-PR checks: `dart format .`, `flutter analyze`, and `flutter test`.
- `flutter analyze` must report 0 issues.
- `flutter test` must fully pass.
- Update version in `pubspec.yaml` for release PRs.

## Internationalization (i18n)

- ARB files: `lib/l10n/`
- Template: `app_en.arb`
- Supported locales: `en`, `zh`
- Config: `l10n.yaml`
- Access translations via `AppLocalizations.of(context)!.keyName`.

This file contains only mandatory rules. For descriptive information, see README.md.
When creating or modifying code, run the mandatory commands above before commit/PR and final handoff.
