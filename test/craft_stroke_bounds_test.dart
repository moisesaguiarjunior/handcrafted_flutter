import 'dart:math' as math;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

import 'support/raster.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  Path drawing() => Path()
    ..moveTo(25, 30)
    ..cubicTo(35, 12, 50, 55, 68, 30)
    ..lineTo(44, 31)
    ..lineTo(69, 35)
    ..moveTo(37, 48)
    ..lineTo(64, 58);
  test('conservative envelopes preserve every drawn pixel across instruments and patterns', () async {
    for (final tool in CraftStrokeTool.values) {
      for (final pattern in CraftLinePattern.values) {
        for (final width in [.5, 12.0, 32.0]) {
          for (final coverage in [0.0, 1.0]) {
            final style = CraftStrokeStyle(
              tool: tool,
              pattern: pattern,
              width: width,
              variation: 1,
              dryCoverage: coverage,
              join: StrokeJoin.miter,
            );
            final bounds = craftStrokeBounds(drawing(), style: style);
            for (final seed in [3, 83]) {
              final original = await pixels(
                (c) => paintCraftStroke(
                  c,
                  drawing(),
                  color: const Color(0xFF27485B),
                  style: style,
                  seed: seed,
                  progress: .83,
                ),
              );
              for (var y = 0; y < 80; y++) {
                for (var x = 0; x < 100; x++) {
                  if (original[(y * 100 + x) * 4 + 3] != 0) {
                    expect(
                      bounds.contains(Offset(x + .5, y + .5)),
                      isTrue,
                      reason: '$tool/$pattern/$width/$coverage at $x,$y',
                    );
                  }
                }
              }
            }
          }
        }
      }
    }
  });
  test('acute native miters stay inside the reported envelope', () async {
    const style = CraftStrokeStyle(width: 4, join: StrokeJoin.miter);
    for (final degrees in [10, 12, 14, 15, 20, 30, 45]) {
      final a = degrees * math.pi / 180;
      final path = Path()
        ..moveTo(50 - math.sin(a) * 20, 40 + math.cos(a) * 20)
        ..lineTo(50, 40)
        ..lineTo(50 + math.sin(a) * 20, 40 + math.cos(a) * 20);
      final bound = craftStrokeBounds(path, style: style);
      final raster = await pixels(
        (c) => paintCraftStroke(
          c,
          path,
          color: const Color(0xFF000000),
          style: style,
        ),
      );
      for (var y = 0; y < 80; y++) {
        for (var x = 0; x < 100; x++) {
          if (raster[(y * 100 + x) * 4 + 3] != 0) {
            expect(
              bound.contains(Offset(x + .5, y + .5)),
              isTrue,
              reason: 'miter $degrees at $x,$y',
            );
          }
        }
      }
    }
  });
  test('reveals keep stable clearance, zero/empty do not invent area, and lines have width', () {
    final vertical = Path()
      ..moveTo(50, 20)
      ..lineTo(50, 55);
    expect(craftStrokeBounds(vertical).width, greaterThan(0));
    expect(
      craftStrokeBounds(drawing(), progress: .01),
      craftStrokeBounds(drawing()),
    );
    expect(craftStrokeBounds(drawing(), progress: 0), Rect.zero);
    expect(craftStrokeBounds(Path()), Rect.zero);
    expect(
      craftStrokeBounds(
        drawing(),
        style: const CraftStrokeStyle(join: StrokeJoin.miter),
      ).width,
      greaterThan(craftStrokeBounds(drawing()).width),
    );
  });
  test('invalid input is rejected even for invisible endpoints', () {
    expect(
      () => craftStrokeBounds(
        drawing(),
        style: const CraftStrokeStyle(width: 0),
        progress: 0,
      ),
      throwsArgumentError,
    );
    expect(
      () => craftStrokeBounds(drawing(), progress: double.nan),
      throwsArgumentError,
    );
    expect(
      () => craftStrokeBounds(drawing(), rasterPadding: -1),
      throwsArgumentError,
    );
    expect(
      () => craftStrokeBounds(Path()..lineTo(9000, 0)),
      throwsArgumentError,
    );
    expect(
      () => craftStrokeBounds(drawing(), rasterPadding: double.maxFinite),
      throwsArgumentError,
    );
  });
}
