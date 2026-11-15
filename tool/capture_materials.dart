import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('capture unapproved material studies', () async {
    final textures = MaterialTextures();
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawColor(const Color(0xFFFAF7F0), BlendMode.src);
    for (var row = 0; row < 2; row++) {
      for (final material in CraftMaterial.values) {
        canvas.save();
        canvas.translate(material.index * 220.0, row * 200.0);
        final outline = pigmentOutline(
          const Rect.fromLTWH(12, 12, 196, 176),
          seed: 7,
          broad: true,
        );
        textures.paint(
          canvas,
          outline,
          material: material,
          color: const Color(0xFFB8B09C),
        );
        canvas.save();
        canvas.clipPath(outline);
        final seam = Path()
          ..addRRect(
            RRect.fromRectAndRadius(
              const Rect.fromLTWH(32, 32, 156, 136),
              const Radius.circular(24),
            ),
          );
        paintRunningStitch(
          canvas,
          seam,
          thread: const Color(0xFF704136),
          compression: row == 0 ? 0 : 1,
          width: 2,
        );
        canvas.restore();
        canvas.restore();
      }
    }
    final picture = recorder.endRecording();
    final image = await picture.toImage(1100, 400);
    try {
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      final file = File('build/studies/materials.png');
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes!.buffer.asUint8List());
    } finally {
      image.dispose();
      picture.dispose();
      textures.dispose();
    }
  });
}
