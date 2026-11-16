#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
ffmpeg -v error -y -framerate 20 -i build/thread-finishing/frame_%03d.png \
  -filter_complex 'split[a][b];[a]palettegen=max_colors=128[p];[b][p]paletteuse=dither=sierra2_4a' \
  -loop -1 docs/assets/thread-finishing.gif
