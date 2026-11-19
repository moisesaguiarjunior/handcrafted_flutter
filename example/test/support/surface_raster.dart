import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:handcrafted_example/surface_proofs.dart';

/// Synthetic raster readback; always disposes its native recording and image.
Future<Uint8List> rasterSurface(
  SurfaceProof scene,
  Rect viewport, {
  double ratio = 1,
  double? stripHeight,
  bool png = false,
}) async {
  final recorder = ui.PictureRecorder();
  scene.paintViewport(
    Canvas(recorder)..scale(ratio),
    viewport,
    stripHeight: stripHeight,
  );
  final picture = recorder.endRecording();
  try {
    final image = await picture.toImage(
      (viewport.width * ratio).ceil(),
      (viewport.height * ratio).ceil(),
    );
    try {
      final data = await image.toByteData(
        format: png ? ui.ImageByteFormat.png : ui.ImageByteFormat.rawRgba,
      );
      if (data == null) throw StateError('Raster readback failed');
      return Uint8List.fromList(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      );
    } finally {
      image.dispose();
    }
  } finally {
    picture.dispose();
  }
}
