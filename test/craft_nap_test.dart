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
        const Rect.fromLTWH(8, 8, 84, 64),
        const Radius.circular(12),
      ),
    )
    ..addOval(const Rect.fromLTWH(38, 27, 24, 24));
  Future<Uint8List> render(CraftNap nap, {double contrast = 1}) =>
      pixels((c) => nap.paint(c, contrast: contrast));
  int occupied(Uint8List data) => [
    for (var i = 3; i < data.length; i += 4)
      if (data[i] > 0) 1,
  ].length;

  test('seeded non-woven fibers clip edges and holes; copied paths cannot mutate paint', () async {
    final source = cut();
    final nap = CraftNap(source, seed: 31);
    final a = await render(nap);
    expect(occupied(a), greaterThan(100));
    expect(await render(CraftNap(cut(), seed: 31)), a);
    expect(await render(CraftNap(cut(), seed: 32)), isNot(a));
    for (var y = 32; y <= 46; y++) {
      for (var x = 43; x <= 57; x++) {
        expect(a[(y * 100 + x) * 4 + 3], 0, reason: 'receiver hole at $x,$y');
      }
    }
    source.reset();
    nap.outline.reset();
    expect(await render(nap), a);
    for (final p in [
      const Offset(2, 2),
      const Offset(50, 39),
      const Offset(99, 79),
    ]) {
      expect(a[(p.dy.toInt() * 100 + p.dx.toInt()) * 4 + 3], 0);
    }
  });
  test(
    'scale density direction and contrast independently change actual deposits',
    () async {
      final base = await render(CraftNap(cut()));
      expect(await render(CraftNap(cut(), scale: 2)), isNot(base));
      expect(await render(CraftNap(cut(), direction: 1.4)), isNot(base));
      final sparse = await render(CraftNap(cut(), density: .2));
      final dense = await render(CraftNap(cut(), density: 1));
      expect(occupied(dense), greaterThan(occupied(sparse)));
      expect(await render(CraftNap(cut()), contrast: .2), isNot(base));
      expect(occupied(await render(CraftNap(cut()), contrast: 0)), 0);
      expect(occupied(await render(CraftNap(cut(), density: 0))), 0);
    },
  );
  test(
    'geometry translates with the cut without changing its local grain',
    () async {
      final nap = CraftNap(cut(), seed: 19);
      final moved = CraftNap(cut().shift(const Offset(200, 110)), seed: 19);
      final translated = await pixels((c) {
        c.translate(-200, -110);
        moved.paint(c);
      });
      expect(translated, await pixels((c) => nap.paint(c)));
    },
  );
  test('invalid recipes and excessive work fail before painting, even at zero density', () async {
    for (final value in [double.nan, double.infinity, -.1]) {
      expect(() => CraftNap(cut(), density: value), throwsArgumentError);
    }
    expect(() => CraftNap(cut(), scale: .49), throwsArgumentError);
    expect(() => CraftNap(cut(), direction: double.nan), throwsArgumentError);
    expect(() => CraftNap(Path()..lineTo(20, 20)), throwsArgumentError);
    expect(
      () => CraftNap(
        Path()..addRect(const Rect.fromLTWH(0, 0, 320, 320)),
        scale: .5,
        density: 0,
      ),
      throwsArgumentError,
    );
    expect(
      () => CraftNap(Path()..addRect(const Rect.fromLTWH(0, 0, 321, 10))),
      throwsArgumentError,
    );
    final empty = CraftNap(Path());
    await expectLater(
      pixels((c) => empty.paint(c, contrast: double.nan)),
      throwsArgumentError,
    );
    expect(occupied(await render(empty)), 0);
    // Every documented small swatch supports the full control range.
    final largest = CraftNap(
      Path()..addRect(const Rect.fromLTWH(0, 0, 100, 100)),
      scale: .5,
      density: 1,
    );
    expect(occupied(await render(largest)), greaterThan(1000));
  });
}
