#!/usr/bin/env python3
"""Compare the shared-envelope extraction with its immutable pre-change renderer."""
from pathlib import Path
import subprocess
import tempfile

BASELINE = '6800c599d29b0583b88f2766fc51ef20454a09c0'


def main() -> None:
    repo = Path(__file__).resolve().parents[1]
    with tempfile.TemporaryDirectory(prefix='stroke-parity-', dir=repo / 'lib/src') as temporary:
        folder = Path(temporary)
        for name in ['craft_stroke.dart', 'dry_stroke.dart']:
            source = subprocess.check_output(['git', 'show', f'{BASELINE}:lib/src/{name}'], cwd=repo).decode()
            source = source.replace("import 'path_geometry.dart';", "import '../path_geometry.dart';")
            (folder / name).write_text(source)
        test_source = r'''
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart' as current;
import 'package:handcrafted_flutter/src/FROZEN/craft_stroke.dart' as frozen;
import 'support/raster.dart';
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('frozen renderer and shared envelope primitives preserve original pixels', () async {
    final path = Path()..moveTo(20, 28)..cubicTo(34, 11, 56, 65, 75, 30)
      ..lineTo(40, 31)..lineTo(69, 36)..moveTo(35, 48)..lineTo(67, 58);
    var cases = 0;
    for (var tool = 0; tool < current.CraftStrokeTool.values.length; tool++) {
      for (var pattern = 0; pattern < current.CraftLinePattern.values.length; pattern++) {
        for (final width in [.5, 12.0, 32.0]) {
          for (final coverage in [0.0, 1.0]) {
            for (final seed in [3, 83]) {
              for (final progress in [.17, 1.0]) {
                final a = await pixels((c) => current.paintCraftStroke(c, path,
                  color: const Color(0xFF31536A), seed: seed, progress: progress,
                  style: current.CraftStrokeStyle(tool: current.CraftStrokeTool.values[tool],
                    pattern: current.CraftLinePattern.values[pattern], width: width,
                    dryCoverage: coverage, variation: 1, join: StrokeJoin.miter)));
                final b = await pixels((c) => frozen.paintCraftStroke(c, path,
                  color: const Color(0xFF31536A), seed: seed, progress: progress,
                  style: frozen.CraftStrokeStyle(tool: frozen.CraftStrokeTool.values[tool],
                    pattern: frozen.CraftLinePattern.values[pattern], width: width,
                    dryCoverage: coverage, variation: 1, join: StrokeJoin.miter)));
                expect(a, b, reason: '$tool/$pattern/$width/$coverage/$seed/$progress');
                cases++;
              }
            }
          }
        }
      }
    }
    expect(cases, 432);
  });
}
'''.replace('FROZEN', folder.name)
        with tempfile.NamedTemporaryFile(prefix='stroke_parity_', suffix='_test.dart', dir=repo / 'test', delete=False) as handle:
            test_file = Path(handle.name)
        try:
            test_file.write_text(test_source)
            subprocess.run(['flutter', 'test', '--no-pub', str(test_file.relative_to(repo))], cwd=repo, check=True)
        finally:
            test_file.unlink(missing_ok=True)
    print(f'432 exact raster cases match frozen renderer {BASELINE[:7]}; temporary source removed.')


if __name__ == '__main__':
    main()
