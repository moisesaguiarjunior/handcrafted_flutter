import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

import 'support/raster.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final cut = Path()
    ..fillType = PathFillType.evenOdd
    ..addRect(const Rect.fromLTWH(10, 10, 80, 60))
    ..addOval(const Rect.fromLTWH(38, 28, 24, 24));
  test(
    'foam finishes are distinct, seeded and clip holes independently of grain',
    () async {
      Future<List<int>> render(
        FoamFinish finish, {
        int seed = 7,
        double strength = 1,
      }) => pixels(
        (c) => paintFoamFinish(
          c,
          cut,
          finish: finish,
          ink: const Color(0xFF62433C),
          seed: seed,
          strength: strength,
        ),
      );
      final results = <List<int>>[];
      for (final finish in FoamFinish.values) {
        final actual = await render(finish);
        expect(actual, await render(finish));
        expect(actual, isNot(await render(finish, seed: 19)));
        expect(await render(finish, strength: 0), await pixels((_) {}));
        expect(actual[3], 0);
        expect(actual[(40 * 100 + 50) * 4 + 3], 0);
        expect(actual.any((v) => v != 0), isTrue);
        for (final previous in results) {
          expect(actual, isNot(previous));
        }
        results.add(actual);
      }
    },
  );
  test('invalid foam work paints nothing even when contrast is zero', () async {
    final blank = await pixels((_) {});
    final rejected = await pixels((c) {
      for (final shape in [
        Path()
          ..moveTo(5, 5)
          ..lineTo(20, 20),
        Path()..addRect(const Rect.fromLTWH(0, 0, 2500, 20)),
      ]) {
        expect(
          () => paintFoamFinish(
            c,
            shape,
            finish: FoamFinish.pebbled,
            ink: const Color(0xFF000000),
            strength: 0,
          ),
          throwsArgumentError,
        );
      }
      expect(
        () => paintFoamFinish(
          c,
          cut,
          finish: FoamFinish.grooved,
          ink: const Color(0xFF000000),
          scale: double.nan,
        ),
        throwsArgumentError,
      );
    });
    expect(rejected, blank);
  });
}
