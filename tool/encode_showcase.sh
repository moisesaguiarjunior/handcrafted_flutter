#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
command -v ffmpeg >/dev/null || { echo 'FFmpeg is required to encode showcase GIFs.' >&2; exit 1; }
mkdir -p docs/assets
cp build/showcase/hero.png docs/assets/hero.png
cp build/showcase/keepsake.png docs/assets/keepsake.png
for scene in hanging kite; do
  case "$scene" in hanging) output=hanging-parts ;; kite) output=kite-tail ;; esac
  ffmpeg -v error -y -framerate 12 -i "build/showcase/$scene/frame_%03d.png" \
    -filter_complex 'split[a][b];[a]palettegen=max_colors=96[p];[b][p]paletteuse=dither=sierra2_4a' \
    -loop 0 "docs/assets/$output.gif"
done
