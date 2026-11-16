import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

import 'support/raster.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final seam = Path()
    ..moveTo(10, 40)
    ..quadraticBezierTo(45, 10, 90, 40);
  test(
    'six patterns produce distinct native pixels; running retains its painter',
    () async {
      final images = <List<int>>[];
      for (final kind in CraftStitchKind.values) {
        final image = await pixels(
          (c) => paintCraftStitch(
            c,
            seam,
            kind: kind,
            thread: const Color(0xFF82526A),
            pitch: 12,
            depth: 10,
            width: 2,
          ),
        );
        expect(image.any((v) => v > 0), isTrue);
        for (final earlier in images) {
          expect(image, isNot(earlier));
        }
        images.add(image);
      }
      final legacy = await pixels(
        (c) => paintRunningStitch(
          c,
          seam,
          thread: const Color(0xFF82526A),
          dash: 12 * .55,
          gap: 12 * .45,
          width: 2,
          compression: .6,
        ),
      );
      expect(images.first, legacy);
      final quiet = await pixels(
        (c) => paintCraftStitch(
          c,
          seam,
          kind: CraftStitchKind.chain,
          thread: const Color(0xFF82526A),
          compression: 0,
        ),
      );
      expect(quiet, isNot(images[CraftStitchKind.chain.index]));
    },
  );
  test(
    'blanket side flips only the transverse geometry; chain links close',
    () {
      final straight = Path()
        ..moveTo(10, 40)
        ..lineTo(90, 40);
      final plus = craftStitchPath(
        straight,
        kind: CraftStitchKind.blanket,
        depth: 10,
      );
      final minus = craftStitchPath(
        straight,
        kind: CraftStitchKind.blanket,
        depth: 10,
        side: -1,
      );
      expect(plus.getBounds().top, 40);
      expect(plus.getBounds().bottom, 50);
      expect(minus.getBounds().top, 30);
      expect(minus.getBounds().bottom, 40);
      final links = craftStitchPath(
        straight,
        kind: CraftStitchKind.chain,
      ).computeMetrics().toList();
      expect(links.length, 7);
      expect(links.every((m) => m.isClosed), isTrue);
      final closed = Path()..addOval(const Rect.fromLTWH(15, 15, 60, 45));
      expect(
        craftStitchPath(
          closed,
          kind: CraftStitchKind.chain,
        ).computeMetrics().every((m) => m.isClosed),
        isTrue,
      );
    },
  );
  test('short closed chain/cross use three cells and account for them before painting', () async {
    final tiny = Path()..addOval(const Rect.fromLTWH(40, 30, 10, 10));
    for (final kind in [CraftStitchKind.chain, CraftStitchKind.cross]) {
      final result = craftStitchPath(tiny, kind: kind, pitch: 48, depth: 4);
      expect(result.getBounds().width, greaterThan(5));
      expect(result.getBounds().height, greaterThan(5));
      expect(
        result.computeMetrics().length,
        kind == CraftStitchKind.chain ? 3 : 6,
      );
    }
    final crowded = Path()
      ..moveTo(0, 0)
      ..lineTo(3960, 0);
    for (var i = 0; i < 31; i++) {
      crowded.addOval(Rect.fromLTWH(10.0 + i * 3, 20, 1, 1));
    }
    final actual = await pixels(
      (c) => expect(
        () => paintCraftStitch(
          c,
          crowded,
          thread: const Color(0xFF112233),
          kind: CraftStitchKind.chain,
          pitch: 4,
          depth: 1,
        ),
        throwsArgumentError,
      ),
    );
    expect(actual, await pixels((_) {}));
  });
  test(
    'holes retain their seam topology and degenerate paths add no ink',
    () async {
      final outline = Path()
        ..fillType = PathFillType.evenOdd
        ..addRect(const Rect.fromLTWH(4, 4, 92, 72))
        ..addRect(const Rect.fromLTWH(40, 30, 20, 20));
      final inset = insetCraftPath(outline, distance: 8, sampleSpacing: 1);
      final image = await pixels((c) {
        c.clipPath(outline);
        paintCraftStitch(
          c,
          inset,
          kind: CraftStitchKind.cross,
          thread: const Color(0xFF334466),
          width: 1,
          depth: 4,
        );
      });
      expect(image[(40 * 100 + 50) * 4 + 3], 0);
      expect(image.any((v) => v > 0), isTrue);
      final degenerate = Path()
        ..moveTo(50, 40)
        ..lineTo(50, 40);
      for (final kind in CraftStitchKind.values) {
        final actual = await pixels(
          (c) => paintCraftStitch(
            c,
            degenerate,
            kind: kind,
            thread: const Color(0xFF334466),
          ),
        );
        expect(actual, await pixels((_) {}));
      }
    },
  );
  test(
    'invalid cells, generated length and parameters reject before painting',
    () async {
      final long = Path()
        ..moveTo(0, 20)
        ..lineTo(5000, 20);
      final expanded = Path()
        ..moveTo(0, 20)
        ..lineTo(4000, 20);
      final blank = await pixels((_) {});
      final actual = await pixels((c) {
        expect(
          () => paintCraftStitch(
            c,
            long,
            thread: const Color(0xFF112233),
            pitch: 4,
          ),
          throwsArgumentError,
        );
        expect(
          () => paintCraftStitch(
            c,
            expanded,
            thread: const Color(0xFF112233),
            pitch: 4,
            kind: CraftStitchKind.cross,
            depth: 32,
          ),
          throwsArgumentError,
        );
        expect(
          () => paintCraftStitch(
            c,
            seam,
            thread: const Color(0xFF112233),
            depth: double.nan,
          ),
          throwsArgumentError,
        );
        expect(
          () => paintCraftStitch(
            c,
            seam,
            thread: const Color(0xFF112233),
            side: 0,
          ),
          throwsArgumentError,
        );
        expect(
          () => paintCraftStitch(
            c,
            seam,
            thread: const Color(0xFF112233),
            width: 0,
          ),
          throwsArgumentError,
        );
      });
      expect(actual, blank);
    },
  );
}
