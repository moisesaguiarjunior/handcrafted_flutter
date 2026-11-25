import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

/// Bounded example raster, with one owner for the returned 2x image.
ui.Image recordMaterialPrint(Size size, void Function(Canvas) paint) {
  if (!size.width.isFinite ||
      !size.height.isFinite ||
      size.isEmpty ||
      size.width > 320 ||
      size.height > 320) {
    throw ArgumentError('Expected a source up to 320 units per axis');
  }
  final recorder = ui.PictureRecorder();
  ui.Picture? picture;
  try {
    paint(Canvas(recorder)..scale(2));
    picture = recorder.endRecording();
    return picture.toImageSync(
      (size.width * 2).ceil(),
      (size.height * 2).ceil(),
    );
  } finally {
    if (recorder.isRecording) recorder.endRecording().dispose();
    picture?.dispose();
  }
}

/// Existing shared affine transport; overlay uses the same source coordinates.
void paintImageTriangle(
  Canvas canvas,
  ui.Image image,
  Size sourceSize,
  Offset s0,
  Offset s1,
  Offset s2,
  Offset d0,
  Offset d1,
  Offset d2, {
  void Function(Canvas)? overlay,
}) {
  final sx = s1 - s0, sy = s2 - s0, dx = d1 - d0, dy = d2 - d0;
  final determinant = sx.dx * sy.dy - sy.dx * sx.dy;
  final a = (dx.dx * sy.dy - dy.dx * sx.dy) / determinant;
  final b = (dx.dy * sy.dy - dy.dy * sx.dy) / determinant;
  final c = (-dx.dx * sy.dx + dy.dx * sx.dx) / determinant;
  final d = (-dx.dy * sy.dx + dy.dy * sx.dx) / determinant;
  final matrix = Matrix4.identity()
    ..setEntry(0, 0, a)
    ..setEntry(1, 0, b)
    ..setEntry(0, 1, c)
    ..setEntry(1, 1, d)
    ..setEntry(0, 3, d0.dx - a * s0.dx - c * s0.dy)
    ..setEntry(1, 3, d0.dy - b * s0.dx - d * s0.dy);
  canvas.save();
  try {
    // Shared internal edges must not be antialiased independently.
    canvas.clipPath(
      Path()
        ..moveTo(d0.dx, d0.dy)
        ..lineTo(d1.dx, d1.dy)
        ..lineTo(d2.dx, d2.dy)
        ..close(),
      doAntiAlias: false,
    );
    canvas.transform(matrix.storage);
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Offset.zero & sourceSize,
      Paint()..filterQuality = FilterQuality.low,
    );
    overlay?.call(canvas);
  } finally {
    canvas.restore();
  }
}
