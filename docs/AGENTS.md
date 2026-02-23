# AGENTS.md

## Project Overview

**Re:Music** is a native desktop audio file management tool built with Flutter. It supports batch renaming based on audio metadata and music tag editing.

## Key Features

*   **Batch Renaming**: Supports reading audio metadata and provides flexible renaming rule configuration.
*   **Music Tag Editing**: Supports separate editing of track artist and album artist, with batch modification and saving capabilities.
*   **File Management**: Supports drag-and-drop import of folders or files, file list filtering, and sorting.
*   **Personalization**: Built-in light and dark modes, multiple MD3 color modes, and support for Chinese and English.

## Tech Stack

*   **Framework**: [Flutter](https://flutter.dev/) (Windows Desktop)
*   **Language**: Dart
*   **State Management**: `provider`
*   **Core Dependencies**:
    *   `audio_metadata_reader`: Fast cross-format metadata parsing.
    *   `audiotags`: Detailed tag reading and writing (e.g., track artist and album artist).
    *   `window_manager`: Desktop window management.
    *   `file_picker`: File picker.
    *   `intl`: Internationalization.
    *   `provider`: State management.
    *   `path`: Path handling.

## Project Structure

```
lib/
├── constants.dart              # All constants centralized here
├── main.dart                   # App entry point
├── models/
│   ├── app_configs.dart        # App configuration model
│   └── audio_file.dart         # Audio file model
├── providers/
│   ├── audio_provider.dart     # Core audio file state management
│   ├── locale_provider.dart
│   ├── navigation_provider.dart # Page navigation state (home / settings)
│   └── theme_provider.dart
├── screens/
│   ├── home_page.dart          # Main page shell (UI assembly only)
│   └── settings_page.dart      # Settings page shell (UI assembly only)
├── services/
│   ├── file_service.dart       # File operations (pick, scan, rename)
│   ├── metadata_service.dart   # Audio metadata reading/formatting
│   └── configs_service.dart    # Configs persistence
├── widgets/
│   ├── common/                 # Shared layout widgets
│   │   ├── left_sidebar.dart
│   │   ├── metadata_edit_dialog.dart
│   │   ├── selectable_card.dart
│   │   ├── smart_menu_anchor.dart
│   │   └── title_bar.dart
│   ├── home/                   # Home page specific widgets
│   │   ├── bottom_right_panel.dart
│   │   ├── file_list_item.dart
│   │   ├── list_states.dart
│   │   └── rename_control_panel.dart
│   └── settings/               # Settings page specific widgets
│       ├── rename_settings.dart
│       └── theme_color_selector.dart
└── l10n/                       # Internationalization (ARB files)
```

## Dev Environment Setup

### Prerequisites

*   Flutter SDK (>= 3.38.6)
*   Visual Studio C++ Tools

### Getting Started

```bash
# Clone the project
git clone https://github.com/ChuwuYo/Re-Music.git
cd Re-Music

# Install dependencies
flutter pub get

# Run in development mode
flutter run -d windows
```

## Build and Test Commands

### Development

```bash
flutter pub get              # Install dependencies
flutter pub upgrade          # Update dependencies
flutter run -d windows       # Run in development mode
```

### Code Quality

```bash
dart format .                # Format code
flutter analyze              # Static analysis
flutter test                 # Run all tests
```

### Build Release

```bash
# Manual build
flutter build windows --release

# Automated build (recommended)
.\build.ps1 -Version "x.y.z"
```

Build output: `build/windows/runner/Release/`

## Testing Instructions

- Test files are in `test/` directory.
- Run all tests: `flutter test`
- Run specific test: `flutter test test/file_service_test.dart`
- Artist semantics test: `flutter test test/metadata_service_test.dart`
- **All tests must pass before committing.**

## Architecture Guidelines

### Feature Modularity

- **Screen files** (`lib/screens/`) are **UI-only** — they assemble widgets and wire up providers, but contain no business logic.
- Each feature is self-contained:
  - UI sections live in `lib/widgets/<feature>/` (one file per logical section).
  - State and business logic live in `lib/providers/<feature>_provider.dart`.
  - I/O, persistence, or external calls live in `lib/services/<feature>_service.dart`.
- No logic (computation, I/O, state mutation) belongs in screen or widget files — dispatch to a provider or service instead.

Standard layout when adding a new feature:
```
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

- Follow `package:flutter_lints/flutter.yaml` rules.
- Use `// ignore: rule_name` for single-line suppression.
- Use `// ignore_for_file: rule_name` for file-level suppression.
- Keep all constants in `lib/constants.dart` - do not scatter magic values.
- Prefer `const` constructors where possible.

## PR Instructions

- Title format: `[<scope>] <description>` (e.g., `[fix] Fix file rename bug`)
- Run `dart format .` before committing.
- Run `flutter analyze` and fix all issues.
- Run `flutter test` and ensure all tests pass.
- Update version in `pubspec.yaml` if releasing.

## Security Considerations

- File rename operations sanitize filenames using `AppConstants.invalidFilenameChars` regex.
- Paths with directory traversal attempts (e.g., `..\`) are stripped to basename only.
- Empty or invalid filenames (`.`, `..`, whitespace-only) are rejected.

## Additional Information

### Supported Audio Formats
MP3 (`.mp3`), FLAC (`.flac`), M4A/AAC (`.m4a`, `.aac`), OGG/Opus (`.ogg`, `.opus`), WMA (`.wma`), WavPack (`.wv`), DSD (`.dsf`, `.dff`)

### Naming Patterns
The app uses pattern-based file renaming with placeholders:
- `{artist}` - Track artist (fallback: performers -> album artist -> unknown artist)
- `{albumArtist}` - Album artist
- `{title}` - Track title
- `{album}` - Album name
- `{track}` - Track number
- `{index}` - Sequential index

Example: `{artist} - {title}` produces "Artist Name - Track Title.mp3"

### Internationalization (i18n)
- ARB files located in `lib/l10n/`
- Template: `app_en.arb`
- Supported locales: English (`en`), Chinese (`zh`)
- Configuration in `l10n.yaml`
- Access translations via `AppLocalizations.of(context)!.keyName`

### Known Issues / WIP
- Online metadata retrieval is work-in-progress.
- Audio resampling and format conversion are work-in-progress.
- Installer generation requires third-party tools (NSIS / Inno Setup).
