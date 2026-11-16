import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

import 'support/raster.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final curve = Path()
    ..moveTo(12, 55)
    ..cubicTo(25, 3, 65, 70, 87, 20);
  test(
    'open cord, ribbon and embroidered texture change actual pixels',
    () async {
      Future<List<int>> render(
        CraftTrimKind kind, {
        double texture = 1,
        double relief = 1,
      }) => pixels(
        (c) => paintCraftTrim(
          c,
          curve,
          color: const Color(0xFFB09161),
          kind: kind,
          width: 12,
          pitch: 4,
          texture: texture,
          relief: relief,
        ),
      );
      final rope = await render(CraftTrimKind.rope);
      expect(rope.any((v) => v > 0), isTrue);
      expect(rope, isNot(await render(CraftTrimKind.rope, texture: 0)));
      expect(rope, isNot(await render(CraftTrimKind.rope, relief: 0)));
      expect(rope, isNot(await render(CraftTrimKind.ribbon)));
      expect(rope, isNot(await render(CraftTrimKind.embroidered)));
      expect(rope, await render(CraftTrimKind.rope));
    },
  );
  test('nominal gap reserves band radius and respects holes', () {
    final outline = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(const Rect.fromLTWH(0, 0, 100, 80))
      ..addRect(const Rect.fromLTWH(40, 30, 20, 20));
    final flush = contourTrimPath(outline, width: 8);
    final inset = contourTrimPath(outline, width: 8, gap: 10);
    expect(flush.getBounds().left, closeTo(4.5, .01));
    expect(inset.getBounds().left, closeTo(14.5, .01));
    expect(inset.contains(const Offset(35, 40)), isFalse);
    expect(inset.contains(const Offset(20, 40)), isTrue);
    expect(outline.getBounds(), const Rect.fromLTWH(0, 0, 100, 80));
    expect(
      contourTrimPath(
        Path()..addRect(const Rect.fromLTWH(0, 0, 8, 8)),
        width: 8,
      ).computeMetrics(),
      isEmpty,
    );
  });
  test(
    'details fit the round band without relief, including open ends',
    () async {
      final straight = Path()
        ..moveTo(20, 40)
        ..lineTo(75, 40);
      for (final kind in CraftTrimKind.values) {
        final image = await pixels(
          (c) => paintCraftTrim(
            c,
            straight,
            color: const Color(0xFF998877),
            kind: kind,
            width: 12,
            pitch: 4,
            relief: 0,
          ),
        );
        for (var y = 0; y < 80; y++) {
          for (var x = 0; x < 100; x++) {
            if (x < 13 || x > 82 || y < 33 || y > 47) {
              expect(image[(y * 100 + x) * 4 + 3], 0);
            }
          }
        }
      }
    },
  );
  test(
    'invalid work is rejected before any pixels, including texture zero',
    () async {
      final tooDense = Path()
        ..moveTo(0, 40)
        ..lineTo(5000, 40);
      final blank = await pixels((_) {});
      final rejected = await pixels((c) {
        expect(
          () => paintCraftTrim(
            c,
            tooDense,
            color: const Color(0xFFFFFFFF),
            pitch: 2,
            texture: 0,
          ),
          throwsArgumentError,
        );
        expect(
          () => paintCraftTrim(
            c,
            curve,
            color: const Color(0xFFFFFFFF),
            light: Offset.zero,
          ),
          throwsArgumentError,
        );
        expect(
          () => paintCraftTrim(
            c,
            curve,
            color: const Color(0xFFFFFFFF),
            width: double.nan,
          ),
          throwsArgumentError,
        );
      });
      expect(rejected, blank);
      expect(() => contourTrimPath(curve), throwsArgumentError);
      expect(() => contourTrimPath(Path(), gap: -1), throwsArgumentError);
    },
  );
}
