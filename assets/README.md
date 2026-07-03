# Assets

This directory contains all static assets for the Sunny Side Songs "Back to the Garden" children's book app.

## Directory Structure

- `images/` — Illustrations, covers, icons, and other visual assets
- `audio/` — Soundtracks, narration, and sound effects for interactive reading
- `data/` — JSON, text, or structured data (e.g., page content, song lyrics, navigation)

## Usage

Assets are declared in `pubspec.yaml` under the `flutter:` section:

```yaml
flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/audio/
    - assets/data/
```

Reference assets in code using paths relative to the project root, for example:

```dart
Image.asset('assets/images/cover.png')
```

## Guidelines

- Keep file names lowercase with underscores (e.g., `page_01_illustration.png`).
- Prefer optimized formats: PNG/WebP for illustrations, MP3/M4A for audio.
- Add resolution-specific variants for images when targeting multiple device densities.
- Do not commit large binary files to git without LFS or a separate asset pipeline if the repo size becomes an issue.

Populate this folder with the actual book assets when they become available.
