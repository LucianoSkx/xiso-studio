# Contributing

Thanks for taking a look! This is a small project, so the process is short.

## Before you start

- Bugs and feature ideas: open an [issue](https://github.com/LucianoSkx/xiso-studio/issues)
  with your distro, how you run the app (AppImage or `flutter run`), and the log
  panel contents if something failed.
- Please **do not** paste whole `.iso` files or game data; a description and the
  tool output are enough.

## Development setup

```bash
flutter pub get
flutter run -d linux          # runs the app with hot reload
flutter analyze               # must stay clean
flutter test                  # must stay green
```

Toolchain: Flutter 3.47.x (Linux desktop), `cmake`, `ninja`, `clang`,
`libgtk-3-dev`. To produce the single ELF locally you also need
`squashfs-tools` and `curl`:

```bash
./packaging/build-appimage.sh
```

## Code map

| Path | Responsibility |
|---|---|
| `lib/args.dart` | pure argv builders — change flags here, never inline in pages |
| `lib/xiso.dart` | embedded binary extraction, process runner, output parsing |
| `lib/state.dart` | `AppState`: run lifecycle, progress, log, cancel |
| `lib/pages.dart` | the four mode pages |
| `lib/widgets.dart` | shared widgets (`PathPicker`, `ProgressStrip`, `LogPanel`) |
| `lib/l10n/*.arb` | translations |

## Pull requests

1. Keep the diff focused: one topic per PR.
2. Add or update a test when you touch `lib/args.dart`, `lib/xiso.dart` or a page
   flow — `test/flow_test.dart` shows how to drive the UI end to end.
3. If you add a UI string, add the key to **every** `lib/l10n/app_*.arb`
   (`flutter test test/l10n_test.dart` fails otherwise).
4. `flutter analyze` and `flutter test` must pass; CI runs both.
5. Write commit messages in the imperative mood, e.g.
   `fix: wait for pipe EOF before reading the exit code`.

## Translations

Adding a locale is one file: copy `lib/l10n/app_en.arb` to `app_<code>.arb`,
translate the values, and add the language to the picker in `lib/main.dart`.
