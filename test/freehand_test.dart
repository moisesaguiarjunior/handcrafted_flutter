import 'dart:ui' show PointMode;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

import 'support/raster.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const bounds = Rect.fromLTWH(0, 0, 100, 80);
  const color = Color(0xAA704A88);
  test('long scribbles retain exact native pen pixels and isolated taps at two export scales', () async {
    final long = List.generate(
      100,
      (i) => i.isEven ? const Offset(8, 8) : const Offset(92, 72),
    );
    final input = [
      long,
      const [Offset(50, 40)],
      const <Offset>[],
      const [Offset(30, 55), Offset(30, 55), Offset(72, 20)],
    ];
    final path = Path()..moveTo(long.first.dx, long.first.dy);
    for (final p in long.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    expect(path.computeMetrics().first.length, greaterThan(8192));
    await pixels(
      (c) => expect(
        () => paintCraftStroke(c, path, color: color),
        throwsArgumentError,
      ),
    );
    for (final join in StrokeJoin.values) {
      for (final scale in [.5, 1.0]) {
        final expected = await pixels((c) {
          c.scale(scale);
          final paint = Paint()
            ..style = PaintingStyle.stroke
            ..color = color
            ..strokeWidth = 3
            ..strokeCap = StrokeCap.round
            ..strokeJoin = join;
          for (final stroke in input) {
            if (stroke.isEmpty) continue;
            if (stroke.length == 1) {
              c.drawPoints(PointMode.points, stroke, paint);
              continue;
            }
            final native = Path()..moveTo(stroke.first.dx, stroke.first.dy);
            for (final p in stroke.skip(1)) {
              native.lineTo(p.dx, p.dy);
            }
            c.drawPath(native, paint);
          }
        });
        final actual = await pixels((c) {
          c.scale(scale);
          paintCraftFreehand(
            c,
            input,
            bounds: bounds,
            color: color,
            style: CraftStrokeStyle(width: 3, join: join),
          );
        });
        expect(actual, expected);
        expect(actual.any((v) => v > 0), isTrue);
      }
    }
    expect(long.length, 100);
    expect(input[1], const [Offset(50, 40)]);
  });
  test(
    'invalid later strokes, budgets and unsupported tools paint nothing',
    () async {
      final blank = await pixels((_) {});
      for (final input in [
        [
          const [Offset(10, 10), Offset(20, 20)],
          const [Offset(double.nan, 20)],
        ],
        List.generate(129, (_) => const <Offset>[]),
        [List.filled(8193, const Offset(10, 10))],
        [
          const [Offset(101, 20)],
        ],
      ]) {
        final actual = await pixels(
          (c) => expect(
            () => paintCraftFreehand(c, input, bounds: bounds, color: color),
            throwsArgumentError,
          ),
        );
        expect(actual, blank);
      }
      for (final style in [
        const CraftStrokeStyle(tool: CraftStrokeTool.brush),
        const CraftStrokeStyle(tool: CraftStrokeTool.marker),
        const CraftStrokeStyle(pattern: CraftLinePattern.dotted),
        const CraftStrokeStyle(pattern: CraftLinePattern.dashed),
        const CraftStrokeStyle(width: double.nan),
      ]) {
        final actual = await pixels(
          (c) => expect(
            () => paintCraftFreehand(
              c,
              const [
                [Offset(10, 10)],
              ],
              bounds: bounds,
              color: color,
              style: style,
            ),
            throwsArgumentError,
          ),
        );
        expect(actual, blank);
      }
    },
  );
  test('inclusive edges and exact point/stroke budgets are accepted without changing input', () async {
    final input = List.generate(
      128,
      (_) => List.generate(
        64,
        (i) => i.isEven ? const Offset(0, 0) : const Offset(100, 80),
      ),
    );
    final image = await pixels(
      (c) => paintCraftFreehand(
        c,
        input,
        bounds: bounds,
        color: const Color(0xFF112233),
      ),
    );
    expect(image.any((v) => v > 0), isTrue);
    expect(input.length, 128);
    expect(input.first.length, 64);
    await pixels(
      (c) => expect(
        () => paintCraftFreehand(c, [], bounds: Rect.zero, color: color),
        throwsArgumentError,
      ),
    );
  });
}
