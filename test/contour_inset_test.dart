import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

import 'support/raster.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'rectangle offset has requested margins and zero keeps exact source',
    () {
      final source = Path()..addRect(const Rect.fromLTWH(10, 10, 80, 60));
      final inset = insetCraftPath(source, distance: 8);
      final bounds = inset.getBounds();
      expect(bounds.left, closeTo(18, .3));
      expect(bounds.top, closeTo(18, .3));
      expect(bounds.right, closeTo(82, .3));
      expect(bounds.bottom, closeTo(62, .3));
      expect(insetCraftPath(source, distance: 40).computeMetrics(), isEmpty);
      final copy = insetCraftPath(source, distance: 0);
      copy.reset();
      expect(source.getBounds(), const Rect.fromLTWH(10, 10, 80, 60));
    },
  );

  test(
    'holes enlarge with even-odd and nonzero orientation stays meaningful',
    () {
      Path shape(PathFillType rule) => Path()
        ..fillType = rule
        ..addRect(const Rect.fromLTWH(0, 0, 100, 80))
        ..addRect(const Rect.fromLTWH(35, 25, 30, 30));
      final hole = insetCraftPath(shape(PathFillType.evenOdd), distance: 6);
      expect(hole.contains(const Offset(30, 40)), isFalse);
      expect(hole.contains(const Offset(20, 40)), isTrue);
      expect(hole.contains(const Offset(50, 40)), isFalse);
      final filled = insetCraftPath(shape(PathFillType.nonZero), distance: 6);
      expect(filled.contains(const Offset(50, 40)), isTrue);
      final reversed = Path()
        ..addRect(const Rect.fromLTWH(0, 0, 100, 80))
        ..moveTo(35, 25)
        ..lineTo(35, 55)
        ..lineTo(65, 55)
        ..lineTo(65, 25)
        ..close();
      expect(
        insetCraftPath(reversed, distance: 6).contains(const Offset(50, 40)),
        isFalse,
      );
    },
  );

  test(
    'concave neck collapses into two closed islands instead of bridging',
    () {
      final source = Path()
        ..moveTo(0, 0)
        ..lineTo(35, 0)
        ..lineTo(35, 27)
        ..lineTo(65, 27)
        ..lineTo(65, 0)
        ..lineTo(100, 0)
        ..lineTo(100, 60)
        ..lineTo(65, 60)
        ..lineTo(65, 33)
        ..lineTo(35, 33)
        ..lineTo(35, 60)
        ..lineTo(0, 60)
        ..close();
      final inset = insetCraftPath(source, distance: 5);
      expect(inset.contains(const Offset(50, 30)), isFalse);
      expect(inset.contains(const Offset(15, 30)), isTrue);
      expect(inset.contains(const Offset(85, 30)), isTrue);
      expect(inset.computeMetrics(), hasLength(2));
      expect(inset.computeMetrics().every((m) => m.isClosed), isTrue);
    },
  );

  test(
    'organic stitch and puncture ink remains inside original material',
    () async {
      final outline = pigmentOutline(
        const Rect.fromLTWH(2, 2, 96, 76),
        seed: 23,
        broad: true,
      );
      final seam = insetCraftPath(outline, distance: 9);
      final ink = await pixels(
        (canvas) => paintRunningStitch(
          canvas,
          seam,
          thread: const Color(0xFFFFFFFF),
          width: 1.5,
          compression: 1,
        ),
      );
      var visible = 0;
      for (var y = 0; y < 80; y++) {
        for (var x = 0; x < 100; x++) {
          if (ink[(y * 100 + x) * 4 + 3] > 0) {
            visible++;
            expect(outline.contains(Offset(x + .5, y + .5)), isTrue);
          }
        }
      }
      expect(visible, greaterThan(50));
    },
  );

  test('closed input, finite ranges and sample work budgets are enforced', () {
    final open = Path()
      ..moveTo(0, 0)
      ..lineTo(50, 50);
    expect(() => insetCraftPath(open, distance: 5), throwsArgumentError);
    final source = Path()..addRect(const Rect.fromLTWH(0, 0, 100, 80));
    for (final value in [double.nan, -1.0, 129.0]) {
      expect(
        () => insetCraftPath(source, distance: value),
        throwsArgumentError,
      );
    }
    expect(
      () => insetCraftPath(source, distance: 5, sampleSpacing: .01),
      throwsArgumentError,
    );
    final tooMany = Path()..addRect(const Rect.fromLTWH(0, 0, 1000, 1000));
    expect(() => insetCraftPath(tooMany, distance: 5), throwsArgumentError);
    expect(insetCraftPath(Path(), distance: 5).computeMetrics(), isEmpty);
  });
}
