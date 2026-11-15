import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

import 'support/raster.dart';

int alpha(Uint8List image, int x, int y) => image[(y * 100 + x) * 4 + 3];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('smooth curves pass through waypoints and preserve endpoints', () {
    const points = [
      Offset(10, 40),
      Offset(30, 15),
      Offset(65, 60),
      Offset(90, 40),
    ];
    final curved = craftCurveThrough(points).computeMetrics().single;
    expect(curved.getTangentForOffset(0)!.position, points.first);
    expect(
      (curved.getTangentForOffset(curved.length)!.position - points.last)
          .distance,
      lessThan(.01),
    );
    for (final point in points) {
      var closest = double.infinity;
      for (var d = 0.0; d <= curved.length; d += .2) {
        final distance =
            (curved.getTangentForOffset(d)!.position - point).distance;
        if (distance < closest) closest = distance;
      }
      expect(closest, lessThan(.3));
    }
    final straight = craftCurveThrough(
      points,
      curvature: 0,
    ).computeMetrics().single;
    final polylineLength =
        (points[1] - points[0]).distance +
        (points[2] - points[1]).distance +
        (points[3] - points[2]).distance;
    expect(straight.length, closeTo(polylineLength, .01));
    expect(curved.length, greaterThan(straight.length));
  });

  test(
    'global arc-length reveal traverses contours instead of trimming each',
    () {
      final source = Path()
        ..moveTo(0, 0)
        ..lineTo(10, 0)
        ..moveTo(0, 20)
        ..lineTo(30, 20);
      final half = trimCraftPath(
        source,
        progress: .5,
      ).computeMetrics().toList();
      expect(half.map((m) => m.length), [10.0, 10.0]);
      expect(half.last.getTangentForOffset(10)!.position, const Offset(10, 20));
      expect(source.computeMetrics().map((m) => m.length), [10.0, 30.0]);
      expect(trimCraftPath(source, progress: 0).computeMetrics(), isEmpty);
      final withZero = Path()
        ..moveTo(0, 0)
        ..lineTo(0, 0)
        ..moveTo(10, 20)
        ..lineTo(30, 20);
      expect(
        trimCraftPath(withZero, progress: .5).computeMetrics().single.length,
        closeTo(10, .001),
      );
      final closed = Path()..addOval(const Rect.fromLTWH(10, 10, 20, 20));
      expect(
        trimCraftPath(closed, progress: 1).computeMetrics().single.isClosed,
        isTrue,
      );
      expect(
        trimCraftPath(closed, progress: .5).computeMetrics().single.isClosed,
        isFalse,
      );
      final ring = Path()
        ..fillType = ui.PathFillType.evenOdd
        ..addRect(const Rect.fromLTWH(0, 0, 60, 60))
        ..addRect(const Rect.fromLTWH(20, 20, 20, 20));
      final fullRing = trimCraftPath(ring, progress: 1);
      expect(fullRing.contains(const Offset(10, 10)), isTrue);
      expect(fullRing.contains(const Offset(30, 30)), isFalse);
    },
  );

  test('completion retains tiny contours after ordinary contours', () {
    for (final side in [1e-12, 1e-15]) {
      final source = Path()
        ..addRect(const Rect.fromLTWH(0, 0, 100, 100))
        ..addRect(Rect.fromLTWH(0, 0, side, side));
      final original = source.computeMetrics().toList();
      expect(original, hasLength(2));
      expect(original.last.length, greaterThan(0));
      final completed = trimCraftPath(
        source,
        progress: 1,
      ).computeMetrics().toList();
      final stitches = runningStitchPath(
        source,
        dash: 9999,
        gap: 1,
      ).computeMetrics().toList();
      for (final result in [completed, stitches]) {
        expect(result, hasLength(2));
        expect(result.map((m) => m.length), original.map((m) => m.length));
      }
      expect(completed.every((m) => m.isClosed), isTrue);
    }
  });

  test('patterns leave real gaps, and marker ink is translucent', () async {
    final path = Path()
      ..moveTo(10, 40)
      ..lineTo(90, 40);
    Future<Uint8List> render(
      CraftLinePattern pattern, {
      CraftStrokeTool tool = CraftStrokeTool.pen,
    }) => pixels(
      (canvas) => paintCraftStroke(
        canvas,
        path,
        color: const Color(0xFF79445F),
        style: CraftStrokeStyle(
          pattern: pattern,
          tool: tool,
          width: 4,
          dash: 8,
          gap: pattern == CraftLinePattern.dotted ? 6 : 8,
        ),
      ),
    );
    final solid = await render(CraftLinePattern.solid);
    final dashed = await render(CraftLinePattern.dashed);
    final dotted = await render(CraftLinePattern.dotted);
    expect(alpha(solid, 22, 40), 255);
    expect(alpha(dashed, 22, 40), 0);
    expect(alpha(dashed, 30, 40), 255);
    expect(alpha(dotted, 10, 40), greaterThan(0));
    expect(alpha(dotted, 15, 40), 0);
    final marker = await render(
      CraftLinePattern.solid,
      tool: CraftStrokeTool.marker,
    );
    expect(alpha(marker, 30, 40), inInclusiveRange(170, 176));
  });

  test('reveal keeps pattern phase and brush prefix stable', () async {
    final path = Path()
      ..moveTo(10, 40)
      ..lineTo(90, 40);
    for (final tool in CraftStrokeTool.values) {
      for (final pattern in CraftLinePattern.values) {
        Future<Uint8List> render(double progress) => pixels(
          (canvas) => paintCraftStroke(
            canvas,
            path,
            progress: progress,
            color: const Color(0xFF79445F),
            style: CraftStrokeStyle(
              tool: tool,
              pattern: pattern,
              width: 6,
              dash: 8,
              gap: 8,
            ),
          ),
        );
        final empty = await render(0);
        expect(empty.every((byte) => byte == 0), isTrue);
        final half = await render(.5);
        final full = await render(1);
        expect(half, isNot(full));
        expect(alpha(half, 70, 40), 0);
        for (var y = 34; y < 46; y++) {
          for (var x = 10; x < 35; x++) {
            final offset = (y * 100 + x) * 4;
            expect(
              half.sublist(offset, offset + 4),
              full.sublist(offset, offset + 4),
            );
          }
        }
      }
    }
  });

  test(
    'curved brush ink is seeded, variable and independent of call order',
    () async {
      final path = craftCurveThrough(const [
        Offset(10, 40),
        Offset(30, 20),
        Offset(65, 60),
        Offset(90, 40),
      ]);
      Future<Uint8List> render(
        int seed, {
        double variation = .7,
        CraftLinePattern pattern = CraftLinePattern.solid,
      }) => pixels(
        (canvas) => paintCraftStroke(
          canvas,
          path,
          seed: seed,
          color: const Color(0xFF79445F),
          style: CraftStrokeStyle(
            tool: CraftStrokeTool.brush,
            pattern: pattern,
            width: 10,
            variation: variation,
          ),
        ),
      );
      for (final pattern in CraftLinePattern.values) {
        final first = await render(5, pattern: pattern);
        await render(99, pattern: pattern);
        expect(first, await render(5, pattern: pattern));
        expect(first, isNot(await render(6, pattern: pattern)));
      }
      expect(await render(5), isNot(await render(5, variation: 0)));
      expect(await render(5, variation: 0), await render(6, variation: 0));
    },
  );

  test(
    'invalid recipes, progress and excessive work fail before any ink',
    () async {
      final path = Path()
        ..moveTo(10, 40)
        ..lineTo(90, 40);
      final output = await pixels((canvas) {
        for (final style in [
          const CraftStrokeStyle(width: 0),
          const CraftStrokeStyle(width: 33),
          const CraftStrokeStyle(width: double.nan),
          const CraftStrokeStyle(dash: .1),
          const CraftStrokeStyle(gap: double.infinity),
          const CraftStrokeStyle(variation: -1),
          const CraftStrokeStyle(variation: 2),
        ]) {
          expect(
            () => paintCraftStroke(
              canvas,
              path,
              style: style,
              color: const Color(0xFFFFFFFF),
            ),
            throwsArgumentError,
          );
        }
        for (final progress in [-.1, 1.1, double.nan, double.infinity]) {
          expect(
            () => paintCraftStroke(
              canvas,
              path,
              progress: progress,
              color: const Color(0xFFFFFFFF),
            ),
            throwsArgumentError,
          );
        }
        final tooLong = Path()
          ..moveTo(0, 0)
          ..lineTo(8193, 0);
        final many = Path();
        for (var i = 0; i < 33; i++) {
          many.moveTo(0, i.toDouble());
          many.lineTo(2, i.toDouble());
        }
        for (final source in [tooLong, many]) {
          expect(
            () => paintCraftStroke(
              canvas,
              source,
              color: const Color(0xFFFFFFFF),
            ),
            throwsArgumentError,
          );
          expect(
            () => trimCraftPath(source, progress: .5),
            throwsArgumentError,
          );
          expect(
            () => runningStitchPath(source, dash: 4, gap: 4),
            throwsArgumentError,
          );
        }
      });
      expect(output.every((byte) => byte == 0), isTrue);
    },
  );

  test('curve rejects degenerate, nonfinite and unbounded inputs', () {
    for (final points in [
      <Offset>[],
      [Offset.zero],
      [Offset.zero, Offset.zero],
      [Offset.zero, const Offset(double.nan, 1)],
      [Offset.zero, const Offset(8193, 1)],
      [const Offset(-8192, 0), const Offset(8192, 0)],
      List.generate(65, (i) => Offset(i.toDouble(), 0)),
    ]) {
      expect(() => craftCurveThrough(points), throwsArgumentError);
    }
    for (final curvature in [-1.0, 2.0, double.nan]) {
      expect(
        () => craftCurveThrough(const [
          Offset.zero,
          Offset(20, 20),
        ], curvature: curvature),
        throwsArgumentError,
      );
    }
  });
}
