import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

import 'support/raster.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'materials clip to supplied bounds and produce seed-stable visible grain',
    () async {
      final first = MaterialTextures();
      final second = MaterialTextures();
      final other = MaterialTextures(seed: 19);
      addTearDown(first.dispose);
      addTearDown(second.dispose);
      addTearDown(other.dispose);
      final outline = Path()..addRect(const Rect.fromLTWH(10, 10, 60, 50));
      for (final material in CraftMaterial.values) {
        Future<Uint8List> render(
          MaterialTextures textures, {
          double strength = 1,
        }) => pixels(
          (canvas) => textures.paint(
            canvas,
            outline,
            material: material,
            color: const Color(0xFFB8B09C),
            strength: strength,
          ),
        );
        final actual = await render(first);
        expect(actual, await render(second));
        expect(actual, isNot(await render(other)));
        expect(actual, isNot(await render(first, strength: 0)));
        // Outside the material remains transparent, including between tiles.
        expect(actual[3], 0);
        expect(actual[(79 * 100 + 99) * 4 + 3], 0);
        expect(actual[(30 * 100 + 30) * 4 + 3], 255);
      }
    },
  );

  test('texture ownership and work limits fail explicitly', () {
    final textures = MaterialTextures();
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final outline = Path()..addRect(const Rect.fromLTWH(0, 0, 80, 60));
    for (final scale in [0.0, double.nan, 100.0]) {
      expect(
        () => textures.paint(
          canvas,
          outline,
          material: CraftMaterial.linen,
          color: const Color(0xFFFFFFFF),
          scale: scale,
        ),
        throwsArgumentError,
      );
    }
    expect(
      () => textures.paint(
        canvas,
        Path()..addRect(const Rect.fromLTWH(0, 0, 3000, 20)),
        material: CraftMaterial.paper,
        color: const Color(0xFFFFFFFF),
      ),
      throwsArgumentError,
    );
    textures.dispose();
    textures.dispose();
    expect(
      () => textures.paint(
        canvas,
        outline,
        material: CraftMaterial.paper,
        color: const Color(0xFFFFFFFF),
      ),
      throwsStateError,
    );
    recorder.endRecording().dispose();
  });

  test('running spans follow arc lengths and retain actual gaps', () {
    final seam = Path()
      ..moveTo(0, 0)
      ..lineTo(25, 0);
    final spans = runningStitchPath(
      seam,
      dash: 6,
      gap: 4,
    ).computeMetrics().toList();
    expect(spans.length, 3);
    expect(spans.map((m) => m.length), [6.0, 6.0, 5.0]);
    expect(spans[1].getTangentForOffset(0)!.position.dx, closeTo(10, .001));
    expect(() => runningStitchPath(seam, dash: 0, gap: 0), throwsArgumentError);
    final excessive = Path()
      ..moveTo(0, 0)
      ..lineTo(9000, 0);
    expect(
      () => runningStitchPath(excessive, dash: 6, gap: 4),
      throwsArgumentError,
    );
  });

  test(
    'puncture study responds to compression and lighting without animating',
    () async {
      final seam = Path()
        ..moveTo(15, 35)
        ..lineTo(85, 35);
      Future<Uint8List> render(double compression, Offset light) =>
          pixels((canvas) {
            canvas.drawColor(const Color(0xFFB8B09C), BlendMode.src);
            paintRunningStitch(
              canvas,
              seam,
              thread: const Color(0xFF704136),
              compression: compression,
              light: light,
            );
          });
      final indented = await render(1, const Offset(-1, -1));
      expect(indented, isNot(await render(0, const Offset(-1, -1))));
      expect(indented, isNot(await render(1, const Offset(1, 1))));
    },
  );
}
