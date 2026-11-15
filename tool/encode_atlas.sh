#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
command -v ffmpeg >/dev/null || { echo 'FFmpeg is required to encode motion samples.' >&2; exit 1; }
mkdir -p docs/assets
for image in materials impressions watercolor motion; do
  cp "build/atlas/$image.png" "docs/assets/$image-atlas.png"
done
ffmpeg -v error -y -framerate 12 -i 'build/atlas/motion/frame_%03d.png' \
  -filter_complex 'split[a][b];[a]palettegen=max_colors=128[p];[b][p]paletteuse=dither=sierra2_4a' \
  -loop 0 docs/assets/motion-atlas.gif
