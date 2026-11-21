#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
# Run only in a disposable checkout: SDK-specific pins replace the local locks.
# The release baseline keeps --enforce-lockfile in its separate CI lane.
flutter pub upgrade
flutter analyze --fatal-infos
flutter test --reporter expanded
# Shader/image ownership differs between native and CanvasKit; cover both SDKs.
flutter test --platform chrome test/rendering_review_regressions_test.dart test/material_opacity_parity_test.dart
(
  cd example
  flutter pub upgrade
  flutter analyze --fatal-infos
  flutter test --reporter expanded
  flutter build web --release --no-web-resources-cdn --base-href /handcrafted_flutter/ -t lib/main_gallery.dart
)
