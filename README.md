<p align="center">
  <img src="packaging/icons/xiso-studio-128.png" width="112" alt="XISO Studio"/>
</p>

<h1 align="center">XISO Studio</h1>

<p align="center">
  A modern Linux desktop GUI for <code>extract-xiso</code> —
  inspect, extract, create and optimize <strong>Xbox XISO</strong> disc images.<br/>
  Ships as <strong>one self-contained ELF</strong>: no GTK, Dart or Flutter to install.
</p>

<p align="center">
  <a href="https://github.com/LucianoSkx/xiso-studio/releases/latest"><img src="https://img.shields.io/github/v/release/LucianoSkx/xiso-studio?label=download&color=52B043" alt="Latest release"/></a>
  <img src="https://img.shields.io/badge/platform-linux--x86__64-52B043" alt="Linux x86_64"/>
  <img src="https://img.shields.io/badge/Flutter-3.47-027DFD" alt="Flutter"/>
  <img src="https://img.shields.io/badge/locales-EN%20%7C%20PT--BR%20%7C%20ES-1f6feb" alt="Locales"/>
  <a href="https://github.com/LucianoSkx/xiso-studio/actions/workflows/ci.yml"><img src="https://img.shields.io/github/actions/workflow/status/LucianoSkx/xiso-studio/ci.yml?label=CI" alt="CI"/></a>
  <img src="https://img.shields.io/badge/license-MIT-orange" alt="MIT"/>
</p>

<p align="center">
  <img src="docs/screenshot.png" width="760" alt="XISO Studio — Extract page"/>
</p>

---

## Why

`extract-xiso` is the standard tool for Xbox disc images, but it is
command-line only: remembering `-x`, `-l`, `-c`, `-r`, `-d`, `-s`, `-m`, `-D`
and the argument order is easy to get wrong. XISO Studio wraps it in a desktop
app that makes the four operations obvious, shows live progress, and needs
nothing installed at runtime.

## Highlights

- **Four modes, zero flags to memorize** — Extract, List, Create, Optimize.
- **Real progress bar** — the app pre-counts entries with `-l` and then counts
  finished files, so you see `246 / 324 files` instead of a spinner.
- **Batches** — select many images at once; each one can extract into its own
  subfolder.
- **Editable paths** — paste a path or use the file dialog, whichever is faster.
- **Live log + cancel** — stdout/stderr streamed into the UI, `SIGTERM` on demand.
  The console follows the newest line, clears itself when you switch modes, and
  the whole session can be exported with **Save log** (`.txt`).
- **Desktop notification when a run ends** — success or failure, so you can leave
  the window in the background during a long extraction.
- **Open folder** — after a run finishes, one click reveals the files it wrote.
- **Recent images** — the last eight images you used, one click away in the image
  field (stored in `~/.config/xiso-studio/settings.json`).
- **Three languages** — English, Português (BR) and Español, switchable in-app
  and remembered between sessions.
- **One file to ship** — the `extract-xiso` binary is embedded and unpacked to
  `~/.cache/xiso-studio/` on first run.

## Install

### 1. Download the single ELF

Published builds live under [Releases](https://github.com/LucianoSkx/xiso-studio/releases).
Once a release is out:

```bash
curl -L -o XISO-Studio.AppImage \
  https://github.com/LucianoSkx/xiso-studio/releases/latest/download/XISO-Studio-x86_64.AppImage
chmod +x XISO-Studio.AppImage
./XISO-Studio.AppImage
```

No release yet? Build it from source — same result, no dependencies on the target
machine.

Optional: hook it into your application menu

```bash
mkdir -p ~/.local/bin ~/.local/share/applications
mv XISO-Studio.AppImage ~/.local/bin/
cat > ~/.local/share/applications/xiso-studio.desktop <<'EOF'
[Desktop Entry]
Type=Application
Name=XISO Studio
Exec=/home/$USER/.local/bin/XISO-Studio.AppImage %F
Icon=xiso-studio
Terminal=false
Categories=Utility;FileTools;
EOF
```

After building from source, `./packaging/install.sh` does the same thing and goes
further: it installs the AppImage in `~/AppImages`, copies every icon size into
`~/.local/share/icons/hicolor`, writes the menu entry and refreshes the icon and
menu caches (GTK and KDE). If your panel keeps showing an older icon after an
update, restart it once with `plasmashell --replace &`.

Requirements: Linux x86_64, X11 or Wayland, OpenGL. No other packages.

### 2. Build from source

```bash
git clone https://github.com/LucianoSkx/xiso-studio.git
cd xiso-studio
flutter pub get

flutter run -d linux              # development
flutter build linux --release     # bundle in build/linux/x64/release/bundle
./packaging/build-appimage.sh     # single ELF in dist/
./packaging/install.sh            # AppImage + icons + menu entry
```

Toolchain: Flutter (Linux desktop), `cmake`, `ninja`, `clang`, `libgtk-3-dev`,
`squashfs-tools`, `curl`.

## Using it

| Mode | What it does | Tool flags |
|------|--------------|------------|
| **Extract** | Expands one or more images into folders | `-x`, `-s`, `-d` |
| **List** | Shows the file tree without extracting anything | `-l` |
| **Create** | Builds a new image from a folder of game files | `-c`, `-s`, `-m` |
| **Optimize** | Rewrites the filesystem layout to shrink the image | `-r`, `-D`, `-d` |

Typical round trip:

1. **Extract** → pick `game.iso`, choose a destination, press *Extract*.
2. Edit the files with any tool.
3. **Create** → point at the edited folder, choose where the new `.iso` goes.
4. **Optimize** → rewrite the result; the output is usually smaller.

Options that mirror the CLI:

| UI option | Flag | Meaning |
|---|---|---|
| Skip the `$SystemUpdate` folder | `-s` | Do not extract the bundled dashboard updates |
| Do not patch media flags on `.xbe` | `-m` | *Not recommended* — the game may not be recognized |
| One subfolder per image | — | Keeps batch extractions from mixing together |
| Delete the original after optimizing | `-D` | Irreversible |

## How it works

```
XISO-Studio-x86_64.AppImage   ← one ELF: AppImage runtime + squashfs
└── usr/bin/
    ├── xiso_studio           ← Flutter runner
    ├── data/                 ← assets, fonts, icudtl
    │   └── flutter_assets/assets/bin/extract-xiso  ← static binary, ~970 KB
    └── lib/                  ← libapp.so, engine
```

`extract-xiso` v2.7.1 is compiled once with
`gcc -O2 -D__LINUX__ -static extract-xiso.c` (no shared libraries at all), shipped
as a Flutter asset and materialized with `chmod +x` into
`~/.cache/xiso-studio/extract-xiso` on startup. The app then runs it as a child
process and streams the output into the UI.

To refresh the bundled tool:

```bash
cd /path/to/extract-xiso && git pull
gcc -O2 -D__LINUX__ -static -o /path/to/xiso-studio/assets/bin/extract-xiso extract-xiso.c
cd /path/to/xiso-studio && ./packaging/build-appimage.sh
```

## Internationalization

`flutter gen-l10n` + three ARB files in [`lib/l10n/`](lib/l10n). The sidebar
picker stores the choice in `~/.config/xiso-studio/settings.json`. Adding a
language is one new `app_xx.arb` file — the test suite fails if a locale has
missing keys, empty strings or mismatched `{placeholders}`.

## Development

```
lib/main.dart      app shell: theme, sidebar, log panel, status bar, language menu
lib/pages.dart     the four mode pages
lib/widgets.dart   PathPicker, OptionTile, LogPanel, ProgressStrip
lib/state.dart     AppState: run orchestration, progress, log, cancel
lib/args.dart      pure argument builders (unit-tested)
lib/xiso.dart      embedded-tool extraction, process runner, progress parsing
lib/settings.dart  persisted preferences
lib/l10n/          ARB sources + generated localizations
assets/bin/        the statically linked extract-xiso
packaging/         AppImage build + install scripts, icon source (SVG → PNGs)
```

## Quality

```bash
flutter analyze     # no issues
flutter test        # 25 tests
```

| Suite | Covers |
|---|---|
| `args_test` | every mode's argv, including the `-c`-swallows-the-next-arg trap |
| `progress_test` | parsing real tool output: per-file lines, summaries, `\r` chunks |
| `l10n_test` | identical keys, no empty strings, matching placeholders across locales |
| `version_test` | displayed version equals `pubspec.yaml` |
| `widget_test` | shell renders, language switch (pt→en→es, persisted), progress bar |
| `flow_test` | end-to-end through the UI: type paths, click Extract, verify files on disk; Create a real XISO and list it back |
| `xiso_test` | embedded tool extraction, create/list/extract against a real image |

GitHub Actions runs `flutter analyze` and the whole suite on every push
([`ci.yml`](.github/workflows/ci.yml)).

Publishing is **manual on purpose**: Actions → *Release* → *Run workflow*, with the
version as input. That builds the AppImage and creates the `v<version>` release
([`release.yml`](.github/workflows/release.yml)). Bump `pubspec.yaml` and
`lib/version.dart` together first — a test keeps them in sync.

## Troubleshooting

**`AppImages require FUSE to run`** — install `fuse2`/`libfuse2`, or run
`./XISO-Studio.AppImage --appimage-extract-and-run`.

**Nothing happens on Wayland** — the app uses the native Wayland backend; if your
compositor has issues, force XWayland with `GDK_BACKEND=x11 ./XISO-Studio.AppImage`.

**`extract-xiso: cannot execute`** — delete the cache with
`rm -rf ~/.cache/xiso-studio` and start the app again; the embedded binary is
re-extracted automatically.

**The tool refuses my image** — XISO Studio is a front-end; anything `extract-xiso`
rejects will show up verbatim in the log panel. Check the image is really an Xbox
XISO (`-l` should list files).

## Contributing

Issues and pull requests are welcome — see [CONTRIBUTING.md](CONTRIBUTING.md).
Run `flutter analyze && flutter test` before opening a PR.

## Credits & license

- App: **MIT** © 2026 [LucianoSkx](https://github.com/LucianoSkx) — see [LICENSE](LICENSE).
- `extract-xiso`: by *in* &lt;in@fishtank.com&gt; and the
  [XboxDev](https://github.com/XboxDev/extract-xiso) organization, under its own
  license — see [NOTICE-extract-xiso.txt](NOTICE-extract-xiso.txt).
- Built with [Flutter](https://flutter.dev) (Material 3); file dialogs by
  [`file_selector`](https://pub.dev/packages/file_selector).
- Independent project, **not affiliated with Microsoft**; Xbox is a trademark of
  Microsoft Corporation.
