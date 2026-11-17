#!/usr/bin/env bash
# Instala o XISO Studio no usuário: AppImage, ícones hicolor e entrada de menu,
# e renova os caches de ícones/menu (KDE/GTK) para que o ícone novo apareça.
# Uso: ./packaging/install.sh
# Nada interfere em /usr: tudo vai para ~/.local/share e ~/AppImages.
set -u
AQUI="$(cd "$(dirname "$0")/.." && pwd)"
DESTINO="${1:-$HOME}"
APP_FONT="$AQUI/dist/XISO-Studio-x86_64.AppImage"
APP_INST="$DESTINO/AppImages/xiso_studio.appimage"
ICONS_DIR="$DESTINO/.local/share/icons/hicolor"
APPS_DIR="$DESTINO/.local/share/applications"

if [ ! -f "$APP_FONT" ]; then
  echo "AppImage não encontrado em $APP_FONT — rode ./packaging/build-appimage.sh antes." >&2
  exit 1
fi

mkdir -p "$(dirname "$APP_INST")" "$ICONS_DIR" "$APPS_DIR"
cp -f "$APP_FONT" "$APP_INST"
chmod +x "$APP_INST"
echo "AppImage instalado em $APP_INST"

# ícones nas resoluções do hicolor
for tamanho in 16 32 48 64 128 256 512; do
  alvo="$ICONS_DIR/${tamanho}x${tamanho}/apps/xiso-studio.png"
  mkdir -p "$(dirname "$alvo")"
  cp -f "$AQUI/packaging/icons/xiso-studio-$tamanho.png" "$alvo"
done
echo "Ícones hicolor instalados"

# entrada de menu apontando para o AppImage instalado
cat > "$APPS_DIR/xiso-studio.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=XISO Studio
GenericName=XISO Manager
Comment=Extrair, listar, criar e otimizar imagens XISO de Xbox
Exec=$APP_INST %F
Icon=xiso-studio
Terminal=false
Categories=Utility;FileTools;
Keywords=xiso;xbox;iso;extract;
MimeType=application/x-iso9660-image;
EOF
chmod +x "$APPS_DIR/xiso-studio.desktop"
echo "Entrada de menu instalada"

# renova os caches usados pelos menus; falha de um deles não é fatal
if command -v gtk-update-icon-cache >/dev/null; then
  gtk-update-icon-cache -f -t "$ICONS_DIR" >/dev/null 2>&1 || true
fi
if command -v kbuildsycoca6 >/dev/null; then
  kbuildsycoca6 --noincremental >/dev/null 2>&1 || true
fi
echo "Caches de ícones e menu renovados"

echo
echo "Pronto. Se o menu do KDE ainda mostrar o ícone antigo, reinicie a barra:"
echo "  plasmashell --replace &"