import 'dart:typed_data';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';
import 'support/raster.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  Path cut() => Path()
    ..fillType = PathFillType.evenOdd
    ..addRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(20, 20, 60, 60),
        const Radius.circular(9),
      ),
    )
    ..addOval(const Rect.fromLTWH(40, 40, 20, 20));
  Future<Uint8List> render(CraftNap nap) =>
      pixels((c) => nap.paint(c, contrast: 1));
  test(
    'long curled strands retain determinism and remain independently configurable',
    () async {
      final source = cut();
      final base = await render(CraftNap(source));
      final long = await render(CraftNap(source, fiberLength: 4));
      expect(long, isNot(base));
      final curly = await render(CraftNap(source, fiberLength: 4, curl: .8));
      expect(curly, isNot(long));
      final finish = CraftNap(source, fiberLength: 4, curl: .8, edgeFuzz: 1);
      final fuzzy = await render(finish);
      expect(fuzzy, isNot(curly));
      expect(
        await render(CraftNap(source, fiberLength: 4, curl: .8, edgeFuzz: 1)),
        fuzzy,
      );
      expect(
        await render(
          CraftNap(source, fiberLength: 4, curl: .8, edgeFuzz: 1, seed: 72),
        ),
        isNot(fuzzy),
      );
      source.reset();
      finish.outline.reset();
      expect(await render(finish), fuzzy);
      expect(
        fuzzy[(50 * 100 + 50) * 4 + 3],
        0,
        reason: 'Fringe must not fill a wide hole',
      );
    },
  );

  test(
    'opt-in fringe paints beyond the cut but within its declared extent',
    () async {
      final outline = cut();
      for (final length in [.25, 6.0]) {
        final finish = CraftNap(
          outline,
          scale: 1.25,
          fiberLength: length,
          curl: 1,
          edgeFuzz: 1,
          density: 1,
        );
        final ink = await render(finish);
        final clipped = await render(
          CraftNap(
            outline,
            scale: 1.25,
            fiberLength: length,
            curl: 1,
            density: 1,
          ),
        );
        var outward = 0;
        for (var y = 0; y < 80; y++) {
          for (var x = 0; x < 100; x++) {
            final alpha = ink[(y * 100 + x) * 4 + 3];
            if (alpha == 0) continue;
            expect(
              finish.paintBounds.inflate(1).contains(Offset(x + .5, y + .5)),
              isTrue,
            );
            if (!outline.contains(Offset(x + .5, y + .5)) &&
                clipped[(y * 100 + x) * 4 + 3] == 0) {
              outward++;
            }
          }
        }
        expect(outward, greaterThan(0));
      }
    },
  );

  test(
    'a retained fluffy finish composes over every existing substrate',
    () async {
      final textures = MaterialTextures(seed: 71);
      final finish = CraftNap(cut(), fiberLength: 4, curl: .7, edgeFuzz: .8);
      try {
        for (final material in CraftMaterial.values) {
          final plain = await pixels(
            (c) => textures.paint(
              c,
              cut(),
              material: material,
              color: const Color(0xFF9FC5DC),
            ),
          );
          final fluffy = await pixels((c) {
            textures.paint(
              c,
              cut(),
              material: material,
              color: const Color(0xFF9FC5DC),
            );
            finish.paint(c, contrast: 1);
          });
          expect(fluffy, isNot(plain), reason: material.name);
        }
      } finally {
        textures.dispose();
      }
    },
  );

  test('overflow honors caller clips and restores canvas state', () async {
    final finish = CraftNap(cut(), fiberLength: 6, curl: 1, edgeFuzz: 1);
    await pixels((c) {
      c.translate(2, 3);
      c.clipRect(const Rect.fromLTWH(30, 30, 40, 40));
      final transform = c.getTransform(), count = c.getSaveCount();
      finish.paint(c);
      expect(c.getTransform(), transform);
      expect(c.getSaveCount(), count);
    });
  });

  test(
    'invalid lengths curls fringes and excessive fringe work fail even when hidden',
    () {
      for (final value in [double.nan, double.infinity, -.1, 1.1]) {
        expect(() => CraftNap(cut(), curl: value), throwsArgumentError);
        expect(() => CraftNap(cut(), edgeFuzz: value), throwsArgumentError);
      }
      for (final value in [double.nan, .24, 6.1]) {
        expect(() => CraftNap(cut(), fiberLength: value), throwsArgumentError);
      }
      final many = Path();
      for (var i = 0; i < 32; i++) {
        many.addRect(Rect.fromLTWH(0, i.toDouble(), 100, .4));
      }
      expect(
        () => CraftNap(many, edgeFuzz: 1, scale: .5, density: 0),
        throwsArgumentError,
      );
    },
  );
}
