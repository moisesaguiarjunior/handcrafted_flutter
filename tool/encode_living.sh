#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
command -v ffmpeg >/dev/null || { echo 'FFmpeg is required.' >&2; exit 1; }
mkdir -p docs/assets
cp build/living/watercolor-hero.png docs/assets/watercolor-hero.png
cp build/living/embroidery.png docs/assets/embroidery-progress.png
for study in wash stitch motion reaction reveal; do
  case "$study" in
    wash) output=watercolor-spread ;;
    stitch) output=embroidery-progress ;;
    motion) output=motion-stage ;;
    reaction) output=watercolor-reaction ;;
    reveal) output=embroidery-reveal ;;
  esac
  ffmpeg -v error -y -framerate 7 -i "build/living/$study/frame_%03d.png" \
    -filter_complex 'split[a][b];[a]palettegen=max_colors=128[p];[b][p]paletteuse=dither=sierra2_4a' \
    -loop -1 "docs/assets/$output.gif"
done
