#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
dart format --output=none --set-exit-if-changed lib test tool example/lib example/test
flutter analyze --fatal-infos
python3 tool/check_lint_policy.py
flutter test --coverage
(cd example && flutter analyze --fatal-infos && flutter test)
