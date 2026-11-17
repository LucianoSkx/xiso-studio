#!/usr/bin/env bash
# Troca o ícone do app por um dos candidatos (a, b, c) e regenera os PNGs.
# Uso: ./packaging/set-icon.sh a|b|c
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CAND="${1:?uso: $0 a|b|c}"
SRC="$ROOT/packaging/icon-candidates/candidate-$CAND.svg"
[ -f "$SRC" ] || { echo "candidato $CAND não existe"; exit 1; }

cp "$SRC" "$ROOT/packaging/xiso-studio.svg"
for size in 512 256 128 64 48 32 16; do
  rsvg-convert -w "$size" -h "$size" "$ROOT/packaging/xiso-studio.svg" \
    -o "$ROOT/packaging/icons/xiso-studio-$size.png"
done
cp "$ROOT/packaging/icons/xiso-studio-512.png" "$ROOT/packaging/xiso-studio.png"
echo "ícone trocado para o candidato $CAND (rebuild com ./packaging/build-appimage.sh)"
