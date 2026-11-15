#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
dart format --output=none --set-exit-if-changed lib test tool/capture_materials.dart tool/capture_showcase.dart example/lib example/test
flutter analyze --fatal-infos
flutter test
(cd example && flutter analyze --fatal-infos && flutter test)
