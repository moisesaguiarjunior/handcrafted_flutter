import 'dart:typed_data';
import 'dart:math' as math;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

import 'support/raster.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final seam = Path()
    ..moveTo(12, 40)
    ..lineTo(88, 40);
  Path prepare({double irregularity = .8, int seed = 83}) => runningStitchPath(
    seam,
    dash: 7,
    gap: 4,
    irregularity: irregularity,
    seed: seed,
  );
  Future<Uint8List> render(Path path) => pixels(
    (c) => c.drawPath(
      path,
      Paint()
        ..color = const Color(0xFFFFFFFF)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    ),
  );

  test('hand sewing changes angle and bow with stable gaps and seed', () async {
    final hand = prepare();
    expect(await render(hand), await render(prepare()));
    expect(await render(hand), isNot(await render(prepare(seed: 84))));
    expect(await render(hand), isNot(await render(prepare(irregularity: 0))));
    expect(hand.getBounds().top, lessThan(40));
    expect(hand.getBounds().bottom, greaterThan(40));
    final metrics = hand.computeMetrics().toList();
    final regular = prepare(irregularity: 0).computeMetrics().toList();
    expect(metrics.length, regular.length);
    for (var i = 0; i < metrics.length; i++) {
      final a = metrics[i].getTangentForOffset(0)!.position;
      final b = metrics[i].getTangentForOffset(metrics[i].length)!.position;
      expect(a.dx, greaterThanOrEqualTo(12 + i * 11 - .01));
      expect(b.dx, lessThanOrEqualTo(12 + i * 11 + 7 + .01));
      expect(a.dy, inInclusiveRange(38.5, 41.5));
      expect(b.dy, inInclusiveRange(38.5, 41.5));
    }
    expect(
      await render(prepare(irregularity: 0)),
      await render(prepare(irregularity: 0, seed: 900)),
    );
  });

  test(
    'small irregularity follows the full original curve without shortcuts',
    () {
      const center = Offset(50, 40);
      final source = Path()
        ..addOval(Rect.fromCircle(center: center, radius: 30));
      final result = runningStitchPath(
        source,
        dash: 300,
        gap: 4,
        irregularity: .001,
        seed: 83,
      );
      final metric = result.computeMetrics().single;
      expect(metric.length, closeTo(2 * math.pi * 30, .05));
      for (var d = 0.0; d < metric.length; d += .25) {
        final point = metric.getTangentForOffset(d)!.position;
        expect(((point - center).distance - 30).abs(), lessThan(.02));
      }
    },
  );

  test(
    'gathering shades cloth beyond the hole and never invents a tip hole',
    () async {
      final path = prepare();
      Future<Uint8List> sample(
        double pucker, {
        double progress = 1,
        double compression = 1,
      }) => pixels((c) {
        CraftStitchFrame.sample(path, progress: progress).paint(
          c,
          thread: const Color(0xFFFFEEDD),
          width: 1.5,
          compression: compression,
          pucker: pucker,
        );
      });
      final flat = await sample(0), gathered = await sample(1);
      expect(gathered, isNot(flat));
      var extra = 0;
      for (var i = 3; i < flat.length; i += 4) {
        if (flat[i] == 0 && gathered[i] > 0) extra++;
      }
      expect(extra, greaterThan(100));
      expect((await sample(1, progress: 0)).every((v) => v == 0), isTrue);
      expect(await sample(1, compression: 0), await sample(0, compression: 0));
      // A partial end is a moving tip, not a fabric puncture: pucker may only
      // originate at the start of this long single stitch.
      final long = Path()
        ..moveTo(15, 40)
        ..lineTo(85, 40);
      final partial = await pixels(
        (c) => CraftStitchFrame.sample(
          long,
          progress: .5,
        ).paint(c, thread: const Color(0xFFFFFFFF), width: 1, pucker: 1),
      );
      expect(partial[(45 * 100 + 50) * 4 + 3], 0);
      expect(partial[(45 * 100 + 15) * 4 + 3], greaterThan(0));
    },
  );

  test(
    'invalid gathering and irregular work reject before any paint',
    () async {
      final image = await pixels((c) {
        for (final bad in [-.1, 1.1, double.nan, double.infinity]) {
          expect(
            () => paintRunningStitch(
              c,
              seam,
              thread: const Color(0xFFFFFFFF),
              pucker: bad,
            ),
            throwsArgumentError,
          );
          expect(
            () => paintRunningStitch(
              c,
              seam,
              thread: const Color(0xFFFFFFFF),
              irregularity: bad,
            ),
            throwsArgumentError,
          );
          expect(
            () => CraftStitchFrame.sample(
              prepare(),
              progress: 1,
            ).paint(c, thread: const Color(0xFFFFFFFF), pucker: bad),
            throwsArgumentError,
          );
          expect(
            () => paintCraftStitch(
              c,
              seam,
              thread: const Color(0xFFFFFFFF),
              pucker: bad,
            ),
            throwsArgumentError,
          );
        }
        expect(
          () => paintRunningStitch(
            c,
            Path()
              ..moveTo(0, 40)
              ..lineTo(1100, 40),
            dash: .5,
            gap: .5,
            thread: const Color(0xFFFFFFFF),
            irregularity: 1,
          ),
          throwsArgumentError,
        );
      });
      expect(image.every((v) => v == 0), isTrue);
      // Existing regular dense paths keep their previous contract.
      expect(
        runningStitchPath(
          Path()
            ..moveTo(0, 0)
            ..lineTo(1100, 0),
          dash: .5,
          gap: .5,
        ).computeMetrics().length,
        1100,
      );
    },
  );

  test(
    'pucker painting is clipped by the supplied substrate, including holes',
    () async {
      final outline = Path()
        ..fillType = PathFillType.evenOdd
        ..addRect(const Rect.fromLTWH(8, 8, 84, 64))
        ..addRect(const Rect.fromLTWH(44, 30, 12, 20));
      final result = await pixels((c) {
        c.save();
        c.clipPath(outline);
        paintRunningStitch(
          c,
          seam,
          thread: const Color(0xFFFFFFFF),
          compression: 1,
          pucker: 1,
          irregularity: 1,
        );
        c.restore();
      });
      expect(result[(40 * 100 + 50) * 4 + 3], 0);
      expect(result[3], 0);
      expect(result.any((v) => v > 0), isTrue);
    },
  );
}
