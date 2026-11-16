import 'dart:typed_data';

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

import 'support/raster.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const tools = [
    CraftStrokeTool.pencil,
    CraftStrokeTool.chalk,
    CraftStrokeTool.wax,
  ];
  final path = Path()
    ..moveTo(10, 40)
    ..lineTo(90, 40);
  Future<Uint8List> render(
    CraftStrokeTool tool, {
    int seed = 23,
    double variation = .8,
    CraftLinePattern pattern = CraftLinePattern.solid,
    double progress = 1,
    Color color = const Color(0xFF79445F),
  }) => pixels(
    (c) => paintCraftStroke(
      c,
      path,
      color: color,
      seed: seed,
      progress: progress,
      style: CraftStrokeStyle(
        tool: tool,
        width: 12,
        pattern: pattern,
        dash: 8,
        gap: 12,
        variation: variation,
      ),
    ),
  );
  test('dry tools retain real gaps, seeded replay and distinct deposits for all patterns', () async {
    for (final pattern in CraftLinePattern.values) {
      final results = <Uint8List>[];
      for (final tool in tools) {
        final first = await render(tool, pattern: pattern);
        await render(tool, seed: 91, pattern: pattern);
        expect(await render(tool, pattern: pattern), first);
        expect(await render(tool, seed: 24, pattern: pattern), isNot(first));
        expect(
          await render(tool, variation: 0, seed: 24, pattern: pattern),
          await render(tool, variation: 0, seed: 91, pattern: pattern),
        );
        expect(
          await render(tool, progress: 0, pattern: pattern),
          await pixels((_) {}),
        );
        if (pattern != CraftLinePattern.solid) {
          // Middle of the first actual gap, clear of round cap/deposit bounds.
          final x = pattern == CraftLinePattern.dotted ? 22 : 24;
          for (var y = 32; y < 48; y++) {
            expect(first[(y * 100 + x) * 4 + 3], 0, reason: '$tool/$pattern');
          }
        }
        results.add(first);
      }
      expect(results[0], isNot(results[1]));
      expect(results[1], isNot(results[2]));
      expect(results[0], isNot(results[2]));
    }
  });
  test(
    'transparent dry ink never paints or erases an existing substrate',
    () async {
      final substrate = await pixels(
        (c) => c.drawColor(const Color(0xFF283F45), BlendMode.src),
      );
      for (final tool in tools) {
        final actual = await pixels((c) {
          c.drawColor(const Color(0xFF283F45), BlendMode.src);
          paintCraftStroke(
            c,
            path,
            color: const Color(0x0079445F),
            style: CraftStrokeStyle(tool: tool, width: 12),
          );
        });
        expect(actual, substrate);
        final translucent = await render(tool, color: const Color(0x4079445F));
        final opaque = await render(tool);
        expect(
          [for (var i = 3; i < opaque.length; i += 4) translucent[i]]
              .reduce((a, b) => a + b),
          lessThan(
            [for (var i = 3; i < opaque.length; i += 4) opaque[i]]
                .reduce((a, b) => a + b),
          ),
        );
      }
    },
  );
  test('dry instruments accept the full arc budget at minimum dash and dot spacing', () async {
    final longest = Path()
      ..moveTo(4, 40)
      ..lineTo(8196, 40);
    for (final tool in tools) {
      for (final pattern in CraftLinePattern.values) {
        final actual = await pixels(
          (c) => paintCraftStroke(
            c,
            longest,
            color: const Color(0xFF79445F),
            style: CraftStrokeStyle(
              tool: tool,
              pattern: pattern,
              width: .5,
              dash: .5,
              gap: .5,
              variation: 1,
            ),
          ),
        );
        expect(actual.any((v) => v > 0), isTrue, reason: '$tool/$pattern');
      }
    }
  });
  test('dry tools reject invalid later contours before painting and keep arc guard', () async {
    final blank = await pixels((_) {});
    for (final tool in tools) {
      final actual = await pixels((c) {
        final excessive = Path()
          ..addPath(path, Offset.zero)
          ..moveTo(0, 1)
          ..lineTo(8193, 1);
        expect(
          () => paintCraftStroke(
            c,
            excessive,
            color: const Color(0xFFFFFFFF),
            style: CraftStrokeStyle(tool: tool),
          ),
          throwsArgumentError,
        );
      });
      expect(actual, blank);
    }
  });
}
