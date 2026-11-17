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
    'one translucent yarn keeps its alpha as sampling density changes',
    () async {
      final path = Path()
        ..moveTo(8, 40)
        ..lineTo(96, 40);
      for (final pitch in [2.0, 6.0, 16.0]) {
        final image = await pixels(
          (c) => paintCraftTrim(
            c,
            path,
            color: const Color(0xFFFFFFFF),
            width: 32,
            pitch: pitch,
            relief: 0,
            texture: 0,
            strandColors: const [
              Color(0x400000FF),
              Color(0x00000000),
              Color(0x00000000),
            ],
          ),
        );
        var maxAlpha = 0;
        for (var i = 3; i < image.length; i += 4) {
          if (image[i] > maxAlpha) maxAlpha = image[i];
        }
        expect(
          maxAlpha,
          inInclusiveRange(63, 65),
          reason: 'Alpha-64 yarn, pitch $pitch',
        );
      }
    },
  );
  test(
    'three strands alternate the visible owner at successive crossings',
    () async {
      const colors = [Color(0xFFDD3311), Color(0xFF22BB55), Color(0xFF3355DD)];
      // One 88px repeat for a 20px braid; the three first crossings have a
      // cyclic over/under order. A fixed global strand order cannot satisfy it.
      final path = Path()
        ..moveTo(8, 40)
        ..lineTo(96, 40);
      final image = await pixels(
        (c) => paintCraftTrim(
          c,
          path,
          color: const Color(0xFFFFFFFF),
          width: 20,
          pitch: 6,
          relief: 0,
          texture: 0,
          strandColors: colors,
        ),
      );
      for (final point in [(15, 43, 0), (30, 37, 1), (45, 43, 2)]) {
        final offset = (point.$2 * 100 + point.$1) * 4;
        expect(image[offset + point.$3], greaterThan(150));
        for (var channel = 0; channel < 3; channel++) {
          if (channel != point.$3) {
            expect(
              image[offset + point.$3],
              greaterThan(image[offset + channel]),
            );
          }
        }
        expect(image[offset + 3], 255);
      }
      expect(
        image[(30 * 100 + 24) * 4 + 3],
        0,
        reason: 'There is no flat backing filling gaps between the yarn.',
      );
    },
  );
  test('transparent strands leave no backing or opaque shading', () async {
    final actual = await pixels(
      (c) => paintCraftTrim(
        c,
        curve,
        color: const Color(0xFFFFFFFF),
        width: 16,
        strandColors: const [Color(0x00112233), Color(0x00445566)],
      ),
    );
    expect(actual, await pixels((_) {}));
  });
  test(
    'twisted strand colors survive zero grain and respond to palette order',
    () async {
      const colors = [Color(0xFFE274A7), Color(0xFF73D6E0), Color(0xFFF5D698)];
      Future<List<int>> render(List<Color>? strands) => pixels(
        (c) => paintCraftTrim(
          c,
          curve,
          color: const Color(0xFF999999),
          width: 14,
          pitch: 6,
          texture: 0,
          strandColors: strands,
        ),
      );
      final actual = await render(colors);
      expect(actual, await render(colors));
      expect(actual, isNot(await render(null)));
      expect(actual, isNot(await render(colors.reversed.toList())));
      final blank = await pixels((_) {});
      final rejected = await pixels((c) {
        for (final palette in [
          <Color>[],
          [colors.first],
          List.filled(7, colors.first),
        ]) {
          expect(
            () => paintCraftTrim(
              c,
              curve,
              color: colors.first,
              strandColors: palette,
            ),
            throwsArgumentError,
          );
        }
        expect(
          () => paintCraftTrim(
            c,
            curve,
            color: colors.first,
            kind: CraftTrimKind.ribbon,
            strandColors: colors,
          ),
          throwsArgumentError,
        );
        expect(
          () => paintCraftTrim(
            c,
            Path()
              ..moveTo(0, 0)
              ..lineTo(2000, 0),
            color: colors.first,
            pitch: 2,
            strandColors: colors,
          ),
          throwsArgumentError,
        );
      });
      expect(rejected, blank);
    },
  );
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
  test(
    'degenerate contours paint no dot, alone or mixed with a curve',
    () async {
      final dot = Path()
        ..moveTo(40, 40)
        ..lineTo(40, 40);
      final mixed = Path.from(curve)..addPath(dot, Offset.zero);
      Future<List<int>> render(Path path) => pixels(
        (c) =>
            paintCraftTrim(c, path, color: const Color(0xFFB09161), width: 12),
      );
      expect(await render(dot), await pixels((_) {}));
      expect(await render(mixed), await render(curve));
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
