import 'package:flutter/painting.dart';

import 'path_geometry.dart';

/// Extracts visible running-stitch spans from a caller-supplied seam.
///
/// Uses logical pixel arc lengths, restarting at each contour. [dash] and [gap]
/// must be finite and at least 0.5. Rejects more than 32 contours or 8192 total
/// logical pixels with [ArgumentError]. A seam is not automatically inset;
/// callers derive it from the same outline and reserve thread/relief padding.
Path runningStitchPath(
  Path source, {
  required double dash,
  required double gap,
}) {
  return spanPath(pathSpans(checkedPathMetrics(source), dash: dash, gap: gap));
}

/// Paints a running stitch with optional illustrative puncture compression.
///
/// [compression] is 0..1, a shading strength, not physical depth or tension.
/// This does not displace the weave or simulate a needle. [width] is 0.5..8
/// logical pixels; [light] is a finite nonzero direction, normalized internally.
/// The caller owns clipping and must reserve width * 4 padding for relief.
/// Invalid parameters throw [ArgumentError] before any painting occurs.
void paintRunningStitch(
  Canvas canvas,
  Path seam, {
  required Color thread,
  double dash = 6,
  double gap = 4,
  double width = 1.5,
  double compression = 0,
  Offset light = const Offset(-1, -1),
}) {
  if (!width.isFinite ||
      width < .5 ||
      width > 8 ||
      !compression.isFinite ||
      compression < 0 ||
      compression > 1 ||
      !light.dx.isFinite ||
      !light.dy.isFinite ||
      !light.distance.isFinite ||
      light.distance == 0) {
    throw ArgumentError('Invalid width, compression or light direction');
  }
  final stitches = runningStitchPath(seam, dash: dash, gap: gap);
  final direction = light / light.distance;
  if (compression > 0) {
    for (final metric in stitches.computeMetrics()) {
      for (final distance in [0.0, metric.length]) {
        final tangent = metric.getTangentForOffset(distance);
        if (tangent == null) continue;
        final center = tangent.position;
        final radius = width * 2.8;
        // Dark near the light-facing lip, bright on its opposing inner slope.
        canvas.drawCircle(
          center,
          radius,
          Paint()
            ..shader = RadialGradient(
              colors: [
                Color.fromRGBO(25, 18, 12, .25 * compression),
                const Color(0x00000000),
              ],
            ).createShader(Rect.fromCircle(center: center, radius: radius)),
        );
        canvas.drawCircle(
          center - direction * width * .35,
          width * .85,
          Paint()..color = Color.fromRGBO(255, 255, 255, .5 * compression),
        );
        canvas.drawCircle(
          center,
          width * .65,
          Paint()..color = Color.fromRGBO(20, 14, 10, .65 * compression),
        );
      }
    }
  }
  canvas.drawPath(
    stitches.shift(-direction * width * .45),
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width * 1.3
      ..strokeCap = StrokeCap.round
      ..color = const Color(0x40000000),
  );
  canvas.drawPath(
    stitches,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..color = thread,
  );
  canvas.drawPath(
    stitches.shift(direction * width * .15),
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width * .3
      ..strokeCap = StrokeCap.round
      ..color = const Color(0x66FFFFFF),
  );
}
