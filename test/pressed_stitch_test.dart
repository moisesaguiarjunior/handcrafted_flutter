import 'dart:typed_data';

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

import 'support/raster.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final seam = Path()
    ..moveTo(12, 40)
    ..lineTo(88, 40);
  const ink = Color(0xFFB28A51);
  Future<Uint8List> render({
    CraftReliefKind relief = CraftReliefKind.inset,
    Offset light = const Offset(0, -1),
    double compression = 1,
    double pucker = 0,
    Color color = ink,
  }) => pixels((c) {
    c.drawColor(const Color(0xFFF5E5C8), BlendMode.src);
    paintRunningStitch(
      c,
      seam,
      thread: color,
      dash: 12,
      gap: 8,
      width: 4,
      compression: compression,
      pucker: pucker,
      relief: relief,
      light: light,
    );
  });
  test(
    'pressed marks have dark upper and pale lower lips and actual gaps',
    () async {
      final result = await render(),
          reversed = await render(light: const Offset(0, 1));
      int red(Uint8List image, int x, int y) => image[(y * 100 + x) * 4];
      expect(red(result, 18, 37), lessThan(245));
      expect(red(result, 18, 42), greaterThan(245));
      expect(red(reversed, 18, 37), greaterThan(red(result, 18, 37)));
      expect(red(reversed, 18, 42), lessThan(red(result, 18, 42)));
      expect(red(result, 28, 40), 245);
      expect(result, isNot(await render(relief: CraftReliefKind.raised)));
      expect(result, isNot(await render(compression: 0)));
      expect(result, await render(pucker: 1));
    },
  );
  test(
    'inset frames and patterned painter share exact partial geometry',
    () async {
      final prepared = craftStitchPath(
        seam,
        kind: CraftStitchKind.basting,
        pitch: 16,
      );
      for (final progress in [0.0, .35, 1.0]) {
        final direct = await pixels(
          (c) => paintCraftStitch(
            c,
            seam,
            thread: ink,
            kind: CraftStitchKind.basting,
            pitch: 16,
            progress: progress,
            relief: CraftReliefKind.inset,
            width: 3,
          ),
        );
        final frame = await pixels(
          (c) => CraftStitchFrame.sample(
            prepared,
            progress: progress,
          ).paint(c, thread: ink, relief: CraftReliefKind.inset, width: 3),
        );
        expect(frame, direct);
        if (progress == 0) expect(frame.every((v) => v == 0), isTrue);
      }
    },
  );
  test(
    'transparent inset ink and invalid later geometry paint nothing',
    () async {
      final blank = await pixels((c) {
        paintRunningStitch(
          c,
          seam,
          thread: const Color(0x00B28A51),
          relief: CraftReliefKind.inset,
          compression: 1,
          pucker: 1,
        );
        for (final bad in [double.nan, -1.0, 2.0]) {
          expect(
            () => paintRunningStitch(
              c,
              seam,
              thread: ink,
              relief: CraftReliefKind.inset,
              compression: bad,
            ),
            throwsArgumentError,
          );
        }
        final invalid = Path()
          ..addPath(seam, Offset.zero)
          ..moveTo(0, 20)
          ..lineTo(8193, 20);
        expect(
          () => paintRunningStitch(
            c,
            invalid,
            thread: ink,
            relief: CraftReliefKind.inset,
          ),
          throwsArgumentError,
        );
        expect(
          () => paintCraftStitch(
            c,
            invalid,
            thread: ink,
            relief: CraftReliefKind.inset,
          ),
          throwsArgumentError,
        );
      });
      expect(blank.every((v) => v == 0), isTrue);
    },
  );
}
