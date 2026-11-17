#!/usr/bin/env bash
# Gera um único ELF (AppImage tipo 2) do XISO Studio a partir do bundle do
# Flutter. O extract-xiso já vai embutido como asset dentro do app.
#
# Uso: ./packaging/build-appimage.sh
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

export PATH="$HOME/Projetos/flutter/bin:$PATH"

OUT_DIR="$ROOT/dist"
BUNDLE="$ROOT/build/linux/x64/release/bundle"
APP_NAME="XISO-Studio"
WD="$(mktemp -d)"
trap 'rm -rf "$WD"' EXIT

# versão vem do proprio código, para o nome do arquivo nunca divergir do app
VERSION="$(sed -n "s/^const String appVersion = '\(.*\)';$/\1/p" "$ROOT/lib/version.dart")"
[ -n "$VERSION" ] || { echo "não consegui ler a versão em lib/version.dart" >&2; exit 1; }
OUT="$OUT_DIR/$APP_NAME-$VERSION-x86_64.AppImage"
# informação de atualização: o AppImageUpdate baixa o .zsync deste release
UPDATE_INFO="gh-releases-zsync|LucianoSkx|xiso-studio|latest|$APP_NAME-*-x86_64.AppImage.zsync"

echo "==> 1/5  build release do Flutter"
flutter build linux --release

echo "==> 2/5  montando AppDir"
APPDIR="$WD/AppDir"
mkdir -p "$APPDIR/usr/bin" "$APPDIR/usr/share/applications" \
         "$APPDIR/usr/share/metainfo"

cp -a "$BUNDLE/." "$APPDIR/usr/bin/"

# AppRun: ponto de entrada do AppImage
cat > "$APPDIR/AppRun" <<'RUN'
#!/bin/sh
HERE="$(dirname "$(readlink -f "$0")")"
export LD_LIBRARY_PATH="$HERE/usr/bin/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
# Flutter precisa do diretório do bundle como base dos assets.
cd "$HERE/usr/bin" 2>/dev/null || true
exec "$HERE/usr/bin/xiso_studio" "$@"
RUN
chmod +x "$APPDIR/AppRun"

for size in 32 48 64 128 256 512; do
  icon="$ROOT/packaging/icons/xiso-studio-$size.png"
  [ -f "$icon" ] || continue
  install -Dm644 "$icon" \
    "$APPDIR/usr/share/icons/hicolor/${size}x${size}/apps/xiso-studio.png"
done
cp "$ROOT/packaging/icons/xiso-studio-512.png" "$APPDIR/xiso-studio.png"
ln -sf usr/share/icons/hicolor/512x512/apps/xiso-studio.png "$APPDIR/.DirIcon"

cat > "$APPDIR/xiso-studio.desktop" <<'DESK'
[Desktop Entry]
Type=Application
Name=XISO Studio
GenericName=XISO Manager
Comment=Extrair, listar, criar e otimizar imagens XISO de Xbox
Exec=xiso_studio %F
Icon=xiso-studio
Terminal=false
Categories=Utility;FileTools;
Keywords=xiso;xbox;iso;extract;
DESK
cp "$APPDIR/xiso-studio.desktop" \
   "$APPDIR/usr/share/applications/xiso-studio.desktop"

cat > "$APPDIR/usr/share/metainfo/xiso-studio.appdata.xml" <<'META'
<?xml version="1.0" encoding="UTF-8"?>
<component type="desktop-application">
  <id>br.oliveira.XisoStudio</id>
  <name>XISO Studio</name>
  <summary>Extrair, listar, criar e otimizar imagens XISO de Xbox</summary>
  <metadata_license>MIT</metadata_license>
  <project_license>MIT</project_license>
  <description>
    <p>Interface gráfica para o extract-xiso. Permite extrair o conteúdo de
    imagens XISO, listar arquivos, criar imagens a partir de uma pasta e
    otimizar imagens existentes. O binário do extract-xiso vai embutido.</p>
  </description>
  <launchable type="desktop-id">xiso-studio.desktop</launchable>
  <releases>
    <release version="1.0.0" date="2026-11-17"/>
  </releases>
</component>
META

echo "==> 3/5  obtendo o runtime do AppImage"
RUNTIME="$ROOT/packaging/runtime-x86_64"
if [ ! -x "$RUNTIME" ]; then
  curl -fsSL -o "$RUNTIME" \
    https://github.com/AppImage/type2-runtime/releases/download/continuous/runtime-x86_64
  chmod +x "$RUNTIME"
fi

echo "==> 4/5  empacotando o ELF único"
mkdir -p "$OUT_DIR"
rm -f "$OUT" "$OUT.zsync"
mksquashfs "$APPDIR" "$WD/app.squashfs" \
  -root-owned -noappend -comp zstd -b 262144 -no-progress >/dev/null
cat "$RUNTIME" "$WD/app.squashfs" > "$OUT"
chmod +x "$OUT"

echo "==> 5/5  update information e .zsync"
python3 "$ROOT/packaging/patch-appimage.py" "$OUT" "$UPDATE_INFO"

# zsyncmake: usa o do sistema, o que estiver em packaging/.tools, ou baixa um
# pacote do Ubuntu (sem root) só para o build local
ZSYNCMAKE="$(command -v zsyncmake || true)"
if [ -z "$ZSYNCMAKE" ] && [ -x "$ROOT/packaging/.tools/zsyncmake" ]; then
  ZSYNCMAKE="$ROOT/packaging/.tools/zsyncmake"
fi
if [ -z "$ZSYNCMAKE" ]; then
  echo "    zsyncmake ausente: buscando pacote do Ubuntu em packaging/.tools"
  mkdir -p "$ROOT/packaging/.tools"
  CACHE="$WD/zsync.deb"
  curl -fsSL -o "$CACHE" \
    "http://archive.ubuntu.com/ubuntu/pool/universe/z/zsync/zsync_0.6.3-2_amd64.deb"
  echo "efb23cca654ee92cbf331103699ac2dbcba1e22ffcc5f86ac46b6e3a06f98720  $CACHE" \
    | sha256sum -c - >/dev/null
  mkdir -p "$WD/deb" && (cd "$WD/deb" && ar x "$CACHE" && tar xf data.tar.zst)
  cp "$WD/deb/usr/bin/zsyncmake" "$ROOT/packaging/.tools/zsyncmake"
  chmod +x "$ROOT/packaging/.tools/zsyncmake"
  ZSYNCMAKE="$ROOT/packaging/.tools/zsyncmake"
fi

(cd "$OUT_DIR" && "$ZSYNCMAKE" -u "$(basename "$OUT")" -o "$(basename "$OUT.zsync")" \
  "$(basename "$OUT")" >/dev/null)

echo
file "$OUT" "$OUT.zsync"
du -h "$OUT" "$OUT.zsync"
echo "OK: $OUT"
echo "OK: $OUT.zsync"
