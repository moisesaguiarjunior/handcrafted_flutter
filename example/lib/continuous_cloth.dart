import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

import 'contact_poses.dart';
import 'showcase_theme.dart';

/// Bounded example-owned transport of a printed source along a curved band.
///
/// This is planar deformation with a rounded cross-section, not an isometric
/// fabric or out-of-plane fold. Inner/outer rails compress/stretch visually.
class ContinuousClothFrame {
  /// Samples the existing gesture without frame history or a second clock.
  ContinuousClothFrame(double progress, ClothCut cut) {
    final pose = ClothPose(progress, cut);
    width = pose.width;
    length = pose.upperLength + pose.lowerLength;
    final curve = Path()..moveTo(ClothPose.shoulder.dx, ClothPose.shoulder.dy);
    var point = ClothPose.shoulder;
    // Spatial integration only: each independent frame starts at the shoulder.
    // The broad bend keeps the inner radius above half of either cut's width.
    for (var i = 0; i < 80; i++) {
      final s = (i + .5) / 80;
      final t = ((s - .1) / .8).clamp(0.0, 1.0);
      final blend = t * t * (3 - 2 * t);
      final angle =
          pose.upper.rotation +
          (pose.lower.rotation - pose.upper.rotation) * blend;
      point += Offset(-math.sin(angle), math.cos(angle)) * (length / 80);
      curve.lineTo(point.dx, point.dy);
    }
    band = CraftBand(curve, width: width, height: 4, sampleSpacing: 2);
    stations = [for (var i = 0; i <= intervals; i++) band.at(i / intervals)];
  }

  /// Fixed source strip subdivision: 48 triangles, independent of view size.
  static const intervals = 24;

  /// Source width, before planar bending.
  late final double width;

  /// Source length; the centerline retains this length within sampling error.
  late final double length;

  /// Existing canonical contour, volume shader and shadow renderer.
  late final CraftBand band;

  /// Shared band stations used by both neighboring image patches.
  late final List<ui.Tangent> stations;

  /// Source coordinate transported through the same piecewise affine map.
  /// Valid range: x in 0..width and y in 0..length.
  Offset mapSource(Offset point) {
    if (!point.dx.isFinite ||
        !point.dy.isFinite ||
        point.dx < 0 ||
        point.dx > width ||
        point.dy < 0 ||
        point.dy > length) {
      throw ArgumentError('Expected a point inside the source textile');
    }
    final row = point.dy / length * intervals;
    final i = row.floor().clamp(0, intervals - 1);
    final v = row - i, u = point.dx / width;
    final a = railPoint(i, false), b = railPoint(i, true);
    final c = railPoint(i + 1, false), d = railPoint(i + 1, true);
    // Triangles are (a,b,c) and (b,d,c), exactly as in paint().
    return u + v <= 1
        ? a + (b - a) * u + (c - a) * v
        : d + (c - d) * (1 - u) + (b - d) * (1 - v);
  }

  /// Shared rail vertex; neighboring patches use the exact same values.
  Offset railPoint(int index, bool right) {
    final tangent = stations[index];
    final normal = Offset(tangent.vector.dy, -tangent.vector.dx);
    return tangent.position + normal * (right ? width / 2 : -width / 2);
  }

  /// Paints one cached material source through 48 clipped affine triangles.
  void paint(Canvas canvas, ClothPrint print, {bool guides = false}) {
    if (print.width != width || print.length != length || print.isDisposed) {
      throw ArgumentError('Expected a live print matching this cut');
    }
    final light = CraftLight(x: -1, y: -1, z: 1.6, softness: .7);
    band.shadow(canvas, light, lift: 4);
    canvas.save();
    try {
      canvas.clipPath(band.outline);
      for (var i = 0; i < intervals; i++) {
        final y = length * i / intervals, next = length * (i + 1) / intervals;
        final a = railPoint(i, false), b = railPoint(i, true);
        final c = railPoint(i + 1, false), d = railPoint(i + 1, true);
        _triangle(
          canvas,
          print,
          Offset(0, y),
          Offset(width, y),
          Offset(0, next),
          a,
          b,
          c,
        );
        _triangle(
          canvas,
          print,
          Offset(width, y),
          Offset(width, next),
          Offset(0, next),
          b,
          d,
          c,
        );
      }
      band.shade(canvas, light);
    } finally {
      canvas.restore();
    }
    if (guides) {
      for (final y in [0.0, length / 2, length]) {
        canvas.drawCircle(
          mapSource(Offset(width / 2, y)),
          4,
          Paint()..color = DemoPalette.indigo,
        );
      }
    }
  }
}

/// One opaque 2x source image; owner explicitly disposes it after unmounting.
class ClothPrint {
  /// Prepares material, printed marks and sewing only once for each cut.
  factory ClothPrint.prepare(MaterialTextures textures, ClothCut cut) {
    final pose = ClothPose(0, cut);
    final width = pose.width, length = pose.upperLength + pose.lowerLength;
    final recorder = ui.PictureRecorder();
    ui.Picture? picture;
    try {
      final canvas = Canvas(recorder)..scale(2);
      textures.paint(
        canvas,
        Path()..addRect(Rect.fromLTWH(0, 0, width, length)),
        material: CraftMaterial.linen,
        color: DemoPalette.sage,
        strength: .8,
      );
      for (var row = 0; row < 16; row++) {
        canvas.drawLine(
          Offset(12, row * 16.0),
          Offset(width - 12, row * 16.0),
          Paint()
            ..color = DemoPalette.paper.withValues(alpha: .5)
            ..strokeWidth = 2,
        );
      }
      final seam = craftStitchPath(
        Path()
          ..moveTo(7, 0)
          ..lineTo(7, length)
          ..moveTo(width - 7, 0)
          ..lineTo(width - 7, length),
        pitch: 8,
      );
      CraftStitchFrame.sample(
        seam,
        progress: 1,
      ).paint(canvas, thread: DemoPalette.cream, width: 1.25);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(3, length - 14, width - 6, 14),
          const Radius.circular(5),
        ),
        Paint()..color = DemoPalette.indigo,
      );
      picture = recorder.endRecording();
      return ClothPrint._(
        width,
        length,
        picture.toImageSync((width * 2).ceil(), (length * 2).ceil()),
      );
    } finally {
      if (recorder.isRecording) recorder.endRecording().dispose();
      picture?.dispose();
    }
  }

  ClothPrint._(this.width, this.length, this._image);

  /// Source width in material coordinates.
  final double width;

  /// Source length in material coordinates.
  final double length;
  final ui.Image _image;
  bool _disposed = false;

  /// Whether this owner has already released the source image.
  bool get isDisposed => _disposed;

  /// Releases only this image; the borrowed texture cache belongs to its caller.
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _image.dispose();
  }
}

void _triangle(
  Canvas canvas,
  ClothPrint print,
  Offset s0,
  Offset s1,
  Offset s2,
  Offset d0,
  Offset d1,
  Offset d2,
) {
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
      print._image,
      Rect.fromLTWH(
        0,
        0,
        print._image.width.toDouble(),
        print._image.height.toDouble(),
      ),
      Rect.fromLTWH(0, 0, print.width, print.length),
      Paint()..filterQuality = FilterQuality.low,
    );
  } finally {
    canvas.restore();
  }
}
