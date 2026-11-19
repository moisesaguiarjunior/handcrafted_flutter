import 'dart:collection';
import 'dart:ui' show Canvas, PictureRecorder;
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
  test(
    'asymmetric profiles drive the cut, edge rails and shaded silhouette',
    () async {
      final source = Path()
        ..moveTo(10, 38)
        ..lineTo(90, 38);
      final keys = [
        const CraftBandWidth(progress: 0, positive: 6, negative: 5),
        const CraftBandWidth(progress: .5, positive: 22, negative: 9),
        const CraftBandWidth(progress: 1, positive: 8, negative: 4),
      ];
      final band = CraftBand(source, widthProfile: keys);
      keys.clear(); // The prepared contract does not retain the caller's list.
      expect(band.outline.contains(const Offset(50, 57)), isTrue);
      expect(band.outline.contains(const Offset(50, 27)), isFalse);
      expect(band.outline.contains(const Offset(15, 57)), isFalse);
      final edge = band.edge(inset: 2).computeMetrics().single;
      expect(edge.getTangentForOffset(0)!.position, const Offset(10, 42));
      final before = await render(band, CraftLight(x: -1));
      final after = await render(band, CraftLight(x: 1));
      expect(before, isNot(after));
      // The extended profile is both painted and shaded, not merely outlined.
      final i = (58 * 100 + 50) * 4;
      expect(before.sublist(i, i + 3), isNot(after.sublist(i, i + 3)));
      expect(() => band.rail(-5), throwsArgumentError);
      expect(() => band.edge(inset: 7), throwsArgumentError);
    },
  );
  test(
    'smooth closed bands join without a cap and preserve the interior hole',
    () async {
      final loop = Path()..addOval(const Rect.fromLTWH(20, 15, 60, 50));
      final band = CraftBand(
        loop,
        widthProfile: const [
          CraftBandWidth(progress: 0, positive: 5, negative: 7),
          CraftBandWidth(progress: .5, positive: 8, negative: 4),
          CraftBandWidth(progress: 1, positive: 5, negative: 7),
        ],
      );
      expect(band.outline.contains(const Offset(50, 40)), isFalse);
      expect(band.outline.contains(const Offset(80, 40)), isTrue);
      expect(band.edge().computeMetrics().single.isClosed, isTrue);
      expect(band.rail(1).computeMetrics().single.isClosed, isTrue);
      expect(band.at(1).position, band.at(0).position);
      expect(band.at(1).vector, band.at(0).vector);
      final raster = await render(band, CraftLight());
      final middle = (40 * 100 + 50) * 4;
      expect(raster.sublist(middle, middle + 4), [255, 250, 242, 255]);
    },
  );
  test(
    'profile shadow follows the wide edge; lift and softness leave surface unchanged',
    () async {
      final band = CraftBand(
        Path()
          ..moveTo(10, 30)
          ..lineTo(85, 30),
        height: 1,
        widthProfile: const [
          CraftBandWidth(progress: 0, positive: 5, negative: 5),
          CraftBandWidth(progress: .5, positive: 23, negative: 5),
          CraftBandWidth(progress: 1, positive: 5, negative: 5),
        ],
      );
      Future<Uint8List> shadow({double lift = 0, double softness = 1}) =>
          pixels((c) {
            c.drawColor(const Color(0xFFFFFFFF), BlendMode.src);
            band.shadow(
              c,
              CraftLight(x: 0, y: -1),
              lift: lift,
              softness: softness,
            );
          });
      final contact = await shadow();
      final wide = (54 * 100 + 47) * 4, narrow = (54 * 100 + 12) * 4;
      expect(contact[wide], lessThan(contact[narrow]));
      final surface = await render(band, CraftLight());
      expect(await shadow(lift: 12), isNot(contact));
      expect(await shadow(softness: 3), isNot(contact));
      expect(await render(band, CraftLight()), surface);
      final recorder = PictureRecorder();
      try {
        expect(
          () => band.shadow(Canvas(recorder), CraftLight(), softness: 0),
          throwsArgumentError,
        );
      } finally {
        recorder.endRecording().dispose();
      }
    },
  );
  test('width keys reject discontinuous joins and excessive preparation', () {
    final source = curve();
    expect(
      () => CraftBand(source, widthProfile: _OversizedWidths()),
      throwsArgumentError,
    );
    for (final keys in [
      [
        const CraftBandWidth(progress: .1, positive: 5, negative: 5),
        const CraftBandWidth(progress: 1, positive: 5, negative: 5),
      ],
      [
        const CraftBandWidth(progress: 0, positive: double.nan, negative: 5),
        const CraftBandWidth(progress: 1, positive: 5, negative: 5),
      ],
      [
        const CraftBandWidth(progress: 0, positive: 95, negative: 5),
        const CraftBandWidth(progress: 1, positive: 5, negative: 5),
      ],
      [
        const CraftBandWidth(progress: 0, positive: 1, negative: 5),
        const CraftBandWidth(progress: 1, positive: 5, negative: 5),
      ],
      [
        for (var i = 0; i < 129; i++)
          CraftBandWidth(progress: i / 128, positive: 5, negative: 5),
      ],
    ]) {
      expect(() => CraftBand(source, widthProfile: keys), throwsArgumentError);
    }
    expect(
      () => CraftBand(
        Path()..addOval(const Rect.fromLTWH(20, 15, 60, 50)),
        widthProfile: const [
          CraftBandWidth(progress: 0, positive: 5, negative: 5),
          CraftBandWidth(progress: 1, positive: 6, negative: 5),
        ],
      ),
      throwsArgumentError,
    );
  });
  test('invalid or excessive band work fails during preparation', () {
    for (final path in [
      Path(),
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

class _OversizedWidths extends ListBase<CraftBandWidth> {
  @override
  int get length => 129;
  @override
  set length(int value) =>
      throw StateError('Must reject length before mutation');
  @override
  CraftBandWidth operator [](int index) =>
      throw StateError('Must reject length before reading');
  @override
  void operator []=(int index, CraftBandWidth value) =>
      throw StateError('Must reject length before mutation');
}
