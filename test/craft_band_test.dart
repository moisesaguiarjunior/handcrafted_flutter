import 'dart:typed_data';

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

import 'support/raster.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  Path curve() => Path()
    ..moveTo(12, 50)
    ..cubicTo(35, 3, 62, 65, 87, 25);
  Future<Uint8List> render(CraftBand band, CraftLight light) => pixels((c) {
    c.drawColor(const Color(0xFFFFFAF2), BlendMode.src);
    c.drawPath(band.outline, Paint()..color = const Color(0xFFECCBA3));
    band.shade(c, light);
  });
  test(
    'curved cross-section responds to light on both sides of the bend',
    () async {
      final band = CraftBand(curve(), width: 18);
      final a = await render(band, CraftLight(x: -1, y: -1));
      final b = await render(band, CraftLight(x: 1, y: 1));
      expect(a, isNot(b));
      for (final progress in [.2, .8]) {
        final t = band.at(progress), n = Offset(-t.vector.dy, t.vector.dx);
        final point = t.position + n * 7;
        final i = (point.dy.floor() * 100 + point.dx.floor()) * 4;
        expect(
          (a[i] - b[i]).abs(),
          greaterThan(2),
          reason: 'station $progress',
        );
      }
      expect(await render(band, CraftLight(x: -1, y: -1)), a);
    },
  );
  test(
    'copied curves and rails do not mutate prepared paint or distance mapping',
    () async {
      final source = curve();
      final band = CraftBand(source, width: 18);
      final original = await render(band, CraftLight());
      final expected = source
          .computeMetrics()
          .single
          .getTangentForOffset(source.computeMetrics().single.length * .5)!
          .position;
      source.reset();
      band.outline.reset();
      band.centerline.reset();
      band.rail(3).reset();
      expect((band.at(.5).position - expected).distance, lessThan(.001));
      expect(await render(band, CraftLight()), original);
      expect(band.at(0).position, const Offset(12, 50));
      expect(
        (band.at(1).position - const Offset(87, 25)).distance,
        lessThan(.001),
      );
    },
  );
  test(
    'rails stay within the same prepared body and support existing stitches',
    () {
      final band = CraftBand(curve(), width: 18);
      for (final offset in [-6.0, 6.0]) {
        final rail = band.rail(offset), metric = rail.computeMetrics().single;
        for (var i = 1; i < 20; i++) {
          expect(
            band.outline.contains(
              metric.getTangentForOffset(metric.length * i / 20)!.position,
            ),
            isTrue,
          );
        }
        expect(
          runningStitchPath(rail, dash: 5, gap: 3).computeMetrics().length,
          greaterThan(1),
        );
      }
    },
  );
  test('invalid or excessive band work fails during preparation', () {
    for (final path in [
      Path(),
      Path()..addOval(const Rect.fromLTWH(0, 0, 30, 30)),
      Path()
        ..moveTo(0, 0)
        ..lineTo(3, 3)
        ..moveTo(4, 4)
        ..lineTo(6, 6),
      Path()
        ..moveTo(0, 0)
        ..lineTo(7000, 0),
    ]) {
      expect(() => CraftBand(path), throwsArgumentError);
    }
    expect(() => CraftBand(curve(), width: double.nan), throwsArgumentError);
    expect(() => CraftBand(curve(), height: 0), throwsArgumentError);
    final band = CraftBand(curve());
    expect(() => band.at(-.1), throwsArgumentError);
    expect(() => band.rail(30), throwsArgumentError);
  });
  test(
    'volume profile height and bevel vary separately from the cut',
    () async {
      final cut = Path()..addOval(const Rect.fromLTWH(10, 10, 70, 55));
      Future<Uint8List> sample(double h, double bevel) => pixels((c) {
        c.drawColor(const Color(0xFFFFFAF2), BlendMode.src);
        c.drawPath(cut, Paint()..color = const Color(0xFF83B7CC));
        CraftVolume(
          cut,
          CraftVolumeProfile.sheet,
          height: h,
          bevel: bevel,
        ).shade(c, CraftLight());
      });
      expect(await sample(2, 3), isNot(await sample(5, 3)));
      expect(await sample(2, 3), isNot(await sample(2, 9)));
      expect(
        () => CraftVolume(cut, CraftVolumeProfile.sheet, height: -1),
        throwsArgumentError,
      );
      expect(
        () => CraftVolume(cut, CraftVolumeProfile.sheet, bevel: 33),
        throwsArgumentError,
      );
    },
  );
}
