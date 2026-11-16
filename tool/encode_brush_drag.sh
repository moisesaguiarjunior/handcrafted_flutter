#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
ffmpeg -v error -y -framerate 15/2 -i build/brush-drag/frame_%03d.png \
  -filter_complex 'split[a][b];[a]palettegen=max_colors=128[p];[b][p]paletteuse=dither=sierra2_4a' \
  -loop -1 docs/assets/brush-drag.gif
