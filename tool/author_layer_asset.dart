// Original synthetic sprite sheet. Runtime scenes import this PNG unchanged.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

import '../example/lib/imported_layers.dart';
import '../example/lib/showcase_theme.dart';

void main() {
  test('author the synthetic cabinet sprite sheet', () async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final textures = MaterialTextures();
    try {
      canvas.save();
      canvas.translate(20, 170);
      final body = Path()
        ..addRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(0, 0, 240, 140),
            const Radius.circular(8),
          ),
        );
      canvas.save();
      canvas.clipPath(body);
      canvas.drawPath(body, Paint()..color = DemoPalette.wood);
      textures.paint(
        canvas,
        body,
        material: CraftMaterial.wood,
        color: DemoPalette.wood,
        scale: 1,
        strength: .8,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(12, 14, 216, 112),
          const Radius.circular(6),
        ),
        Paint()..color = const Color(0xFF344C4C),
      );
      canvas.restore();
      canvas.restore();
      canvas.save();
      canvas.translate(300, 20);
      final lid = lidHitPath(const Size(240, 120));
      canvas.save();
      canvas.clipPath(lid);
      canvas.drawPath(lid, Paint()..color = const Color(0xFF7CA79A));
      textures.paint(
        canvas,
        lid,
        material: CraftMaterial.linen,
        color: const Color(0xFF7CA79A),
        scale: 1,
        strength: .8,
      );
      canvas.restore();
      canvas.drawPath(
        lid,
        Paint()
          ..color = const Color(0xFF496C62)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
      final sprig = Path()
        ..moveTo(92, 95)
        ..quadraticBezierTo(130, 72, 140, 25)
        ..quadraticBezierTo(135, 74, 95, 98)
        ..close();
      for (final leaf in [
        const Rect.fromLTWH(100, 52, 28, 12),
        const Rect.fromLTWH(132, 32, 27, 13),
        const Rect.fromLTWH(123, 70, 30, 12),
      ]) {
        sprig.addOval(leaf);
      }
      paintCraftRelief(canvas, sprig, depth: 2, strength: .9);
      for (final x in [16.0, 220.0]) {
        canvas.drawCircle(
          Offset(x, x == 16 ? 12 : 55),
          4,
          Paint()..color = DemoPalette.paper,
        );
        canvas.drawCircle(
          Offset(x, x == 16 ? 12 : 55),
          2,
          Paint()..color = DemoPalette.wood,
        );
      }
      canvas.restore();
      final picture = recorder.endRecording();
      final bitmap = await picture.toImage(600, 360);
      try {
        final bytes = await bitmap.toByteData(format: ui.ImageByteFormat.png);
        final file = File('example/assets/layers/cabinet.png');
        await file.parent.create(recursive: true);
        await file.writeAsBytes(bytes!.buffer.asUint8List());
      } finally {
        bitmap.dispose();
        picture.dispose();
      }
    } finally {
      textures.dispose();
    }
  });
}
