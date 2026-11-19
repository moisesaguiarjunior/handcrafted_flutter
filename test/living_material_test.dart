import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

import 'support/raster.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final ring = Path()
    ..fillType = PathFillType.evenOdd
    ..addRect(const Rect.fromLTWH(5, 5, 90, 70))
    ..addOval(const Rect.fromLTWH(42, 30, 16, 20));
  const pigment = Color(0xFF7B719D), paper = Color(0xFFFFFDF8);
  test(
    'spreading pigment grows spatially, replays exactly, preserves holes and finishes as the original wash',
    () async {
      Future<List<int>> render(double p, {int seed = 23, Offset? origin}) =>
          pixels(
            (c) => paintWatercolorSpread(
              c,
              ring,
              pigment: pigment,
              paper: paper,
              progress: p,
              seed: seed,
              origin: origin,
            ),
          );
      final blank = await render(0);
      expect(blank.every((v) => v == 0), isTrue);
      final early = await render(.025),
          middle = await render(.25),
          end = await render(1);
      int coverage(List<int> data) => [
        for (var i = 3; i < data.length; i += 4)
          if (data[i] > 0) i,
      ].length;
      expect(
        early[(40 * 100 + 10) * 4 + 3],
        0,
        reason: 'Distant paper stays dry before the pigment front reaches it',
      );
      expect(coverage(early), greaterThan(0));
      expect(coverage(early), lessThan(coverage(middle)));
      expect(coverage(middle), lessThan(coverage(end)));
      await render(.17, seed: 88);
      expect(middle, await render(.25));
      expect(middle, isNot(await render(.25, seed: 24)));
      expect(early, isNot(await render(.025, origin: const Offset(20, 20))));
      for (final data in [early, middle, end]) {
        expect(data[(40 * 100 + 50) * 4 + 3], 0);
        expect(data[(2 * 100 + 2) * 4 + 3], 0);
      }
      expect(
        end,
        await pixels(
          (c) => paintWatercolor(
            c,
            ring,
            pigment: pigment,
            paper: paper,
            seed: 23,
          ),
        ),
      );
    },
  );
  test('invalid spread input fails before drawing even at endpoints', () async {
    final blank = await pixels((_) {});
    for (final p in [-.1, 1.1, double.nan, double.infinity]) {
      final output = await pixels(
        (c) => expect(
          () => paintWatercolorSpread(
            c,
            ring,
            pigment: pigment,
            paper: paper,
            progress: p,
          ),
          throwsArgumentError,
        ),
      );
      expect(output, blank);
    }
    for (final origin in [
      const Offset(double.nan, 30),
      const Offset(200, 30),
    ]) {
      final output = await pixels(
        (c) => expect(
          () => paintWatercolorSpread(
            c,
            ring,
            pigment: pigment,
            paper: paper,
            progress: 1,
            origin: origin,
          ),
          throwsArgumentError,
        ),
      );
      expect(output, blank);
    }
    final transparent = await pixels(
      (c) => paintWatercolorSpread(
        c,
        ring,
        pigment: pigment,
        paper: paper,
        progress: .4,
        opacity: 0,
      ),
    );
    expect(transparent, blank);
  });
  test(
    'thread follows generated order without a puncture under its travelling tip',
    () async {
      final prepared = Path()
        ..moveTo(10, 40)
        ..lineTo(30, 40)
        ..moveTo(50, 40)
        ..lineTo(90, 40);
      final frame = CraftStitchFrame.sample(prepared, progress: .5);
      expect(frame.tip!.position.dx, closeTo(60, .001));
      expect(frame.path.computeMetrics().map((m) => m.length), [20.0, 10.0]);
      final image = await pixels(
        (c) => frame.paint(c, thread: pigment, width: 1.5, compression: 1),
      );
      expect(
        image[(43 * 100 + 60) * 4 + 3],
        0,
        reason: 'No moving hole at the thread tip',
      );
      expect(
        image[(42 * 100 + 50) * 4 + 3],
        greaterThan(0),
        reason: 'Actual anchor is compressed',
      );
      final original = frame.path;
      original.reset();
      prepared.reset();
      expect(frame.path.computeMetrics(), hasLength(2));
      expect(CraftStitchFrame.sample(original, progress: .5).tip, isNull);
    },
  );
  test(
    'every stitch family starts empty and finishes with unchanged static pixels',
    () async {
      final seam = Path()..addOval(const Rect.fromLTWH(18, 15, 60, 45));
      for (final kind in CraftStitchKind.values) {
        Future<List<int>> render(double p) => pixels(
          (c) => paintCraftStitch(
            c,
            seam,
            thread: pigment,
            kind: kind,
            pitch: 14,
            depth: 4,
            progress: p,
          ),
        );
        expect(await render(0), await pixels((_) {}));
        final prepared = craftStitchPath(seam, kind: kind, pitch: 14, depth: 4);
        final full = CraftStitchFrame.sample(prepared, progress: 1);
        expect(full.tip, isNull);
        expect(
          await render(1),
          await pixels((c) => full.paint(c, thread: pigment)),
        );
        expect(await render(.4), isNot(await render(1)));
      }
    },
  );
  test(
    'prepared thread guards output budgets and progress before painting',
    () {
      final dense = Path();
      for (var i = 0; i < 3073; i++) {
        dense
          ..moveTo(0, 0)
          ..lineTo(1, 1);
      }
      expect(
        () => CraftStitchFrame.sample(dense, progress: .5),
        throwsArgumentError,
      );
      final tooLong = Path()
        ..moveTo(-8000, 0)
        ..lineTo(8000, 0)
        ..lineTo(-8000, 1)
        ..lineTo(8000, 1);
      expect(
        () => CraftStitchFrame.sample(tooLong, progress: .5),
        throwsArgumentError,
      );
      for (final p in [-1.0, 2.0, double.nan]) {
        expect(
          () => CraftStitchFrame.sample(Path(), progress: p),
          throwsArgumentError,
        );
      }
    },
  );
}
