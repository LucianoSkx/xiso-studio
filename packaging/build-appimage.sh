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

echo "==> 1/4  build release do Flutter"
flutter build linux --release

echo "==> 2/4  montando AppDir"
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

echo "==> 3/4  obtendo o runtime do AppImage"
RUNTIME="$ROOT/packaging/runtime-x86_64"
if [ ! -x "$RUNTIME" ]; then
  curl -fsSL -o "$RUNTIME" \
    https://github.com/AppImage/type2-runtime/releases/download/continuous/runtime-x86_64
  chmod +x "$RUNTIME"
fi

echo "==> 4/4  empacotando o ELF único"
mkdir -p "$OUT_DIR"
rm -f "$OUT_DIR/$APP_NAME-x86_64.AppImage"
mksquashfs "$APPDIR" "$WD/app.squashfs" \
  -root-owned -noappend -comp zstd -b 262144 -no-progress >/dev/null
cat "$RUNTIME" "$WD/app.squashfs" > "$OUT_DIR/$APP_NAME-x86_64.AppImage"
chmod +x "$OUT_DIR/$APP_NAME-x86_64.AppImage"

echo
file "$OUT_DIR/$APP_NAME-x86_64.AppImage"
du -h "$OUT_DIR/$APP_NAME-x86_64.AppImage"
echo "OK: $OUT_DIR/$APP_NAME-x86_64.AppImage"
