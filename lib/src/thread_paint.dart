import 'package:flutter/painting.dart';

/// Shared pre-paint validation for existing and patterned thread.
void validateThreadPaint(double width, double compression, Offset light) {
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
}

/// Paints already prepared thread geometry; caller validates its work budget.
void paintThreadGeometry(
  Canvas canvas,
  Path stitches, {
  required Color thread,
  required double width,
  required double compression,
  required Offset light,
  Iterable<Offset>? punctures,
}) {
  final direction = light / light.distance;
  if (compression > 0) {
    final anchors =
        punctures ??
        stitches.computeMetrics().expand(
          (metric) => [0.0, metric.length]
              .map((distance) => metric.getTangentForOffset(distance)?.position)
              .whereType<Offset>(),
        );
    for (final center in anchors) {
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
