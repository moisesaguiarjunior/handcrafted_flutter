import 'dart:math' as math;
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
}) => _raster(viewport.size, ratio, png, (canvas) {
  scene.paintViewport(canvas, viewport, stripHeight: stripHeight);
});

/// Deliberately wrong: prepare a fresh material/wash source in every strip.
/// Keep those owners alive until raster readback finishes, then dispose all.
Future<Uint8List> rasterRestartedStrips(
  SurfaceRecipe recipe,
  Rect viewport, {
  double ratio = 1,
  double stripHeight = 64,
}) async {
  final owners = <SurfaceProof>[];
  try {
    return await _raster(viewport.size, ratio, false, (canvas) {
      for (var top = 0.0; top < viewport.height; top += stripHeight) {
        final bounds = Rect.fromLTWH(
          viewport.left,
          viewport.top + top,
          viewport.width,
          math.min(stripHeight, viewport.height - top),
        );
        final owner = SurfaceProof(recipe: recipe, domain: bounds);
        owners.add(owner);
        canvas.save();
        canvas.translate(0, top);
        owner.paintViewport(canvas, bounds);
        canvas.restore();
      }
    });
  } finally {
    for (final owner in owners) {
      owner.dispose();
    }
  }
}

Future<Uint8List> _raster(
  Size size,
  double ratio,
  bool png,
  void Function(Canvas) paint,
) async {
  final recorder = ui.PictureRecorder();
  try {
    paint(Canvas(recorder)..scale(ratio));
  } catch (_) {
    recorder.endRecording().dispose();
    rethrow;
  }
  final picture = recorder.endRecording();
  try {
    final image = await picture.toImage(
      (size.width * ratio).ceil(),
      (size.height * ratio).ceil(),
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

/// Shared diagnostic budget: raster clipping is explicitly not pixel equality.
/// Bounds include the measured native/Chrome samples, not consumer acceptance.
double surfaceMeanLimit(SurfaceRecipe recipe) => switch (recipe) {
  SurfaceRecipe.featheredWash => .2,
  SurfaceRecipe.diamonds => .05,
  SurfaceRecipe.checker => .03,
  SurfaceRecipe.fibers => .01,
  SurfaceRecipe.watercolor => .1,
};

/// Same channel metrics and acceptance check for retained and restarted strips.
final class SurfaceRasterDelta {
  /// Compares equal-size nonempty RGBA readbacks.
  SurfaceRasterDelta(Uint8List expected, Uint8List actual) {
    if (expected.isEmpty || expected.length != actual.length) {
      throw ArgumentError('Expected matching nonempty RGBA buffers');
    }
    var sum = 0;
    for (var i = 0; i < expected.length; i++) {
      final difference = (expected[i] - actual[i]).abs();
      maximum = math.max(maximum, difference);
      if (difference > 0) changed++;
      sum += difference;
    }
    mean = sum / expected.length;
  }

  /// Largest absolute channel delta, out of 255.
  int maximum = 0;

  /// Number of changed channels, not pixels.
  int changed = 0;

  /// Mean absolute delta over all RGBA channels.
  late final double mean;

  /// The same bound must pass retained clips and fail source restart.
  bool withinFor(SurfaceRecipe recipe) =>
      maximum <= 10 && mean < surfaceMeanLimit(recipe);
}
