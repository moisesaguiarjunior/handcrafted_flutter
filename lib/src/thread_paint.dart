import 'package:flutter/painting.dart';

import 'craft_relief.dart';

/// Shared pre-paint validation for existing and patterned thread.
void validateThreadPaint(
  double width,
  double compression,
  Offset light, {
  double pucker = 0,
}) {
  if (!width.isFinite ||
      width < .5 ||
      width > 8 ||
      !compression.isFinite ||
      compression < 0 ||
      compression > 1 ||
      !pucker.isFinite ||
      pucker < 0 ||
      pucker > 1 ||
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
  double pucker = 0,
  CraftReliefKind relief = CraftReliefKind.raised,
}) {
  final direction = light / light.distance;
  if (relief == CraftReliefKind.inset) {
    // Pressed marks have lit lips, not raised thread or needle punctures.
    // Reuse prepared geometry; no broad shadow is drawn around the seam.
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    if (compression > 0 && thread.a > 0) {
      canvas.drawPath(
        stitches.shift(-direction * width * .23),
        stroke
          ..strokeWidth = width
          ..color = Color.fromRGBO(255, 255, 255, .5 * compression * thread.a),
      );
      canvas.drawPath(
        stitches.shift(direction * width * .2),
        stroke
          ..strokeWidth = width
          ..color = Color.fromRGBO(50, 31, 20, .18 * compression * thread.a),
      );
    }
    canvas.drawPath(
      stitches,
      stroke
        ..strokeWidth = width * .78
        ..color = thread,
    );
    return;
  }
  if (compression > 0) {
    final anchors =
        punctures ??
        stitches.computeMetrics().expand(
          (metric) => [0.0, metric.length]
              .map((distance) => metric.getTangentForOffset(distance)?.position)
              .whereType<Offset>(),
        );
    for (final center in anchors) {
      if (pucker > 0) {
        final reach = width * (3 + 4 * pucker);
        final strength = pucker * compression;
        canvas.drawCircle(
          center,
          reach,
          Paint()
            ..shader = RadialGradient(
              colors: [
                Color.fromRGBO(30, 20, 15, .065 * strength),
                const Color(0x00000000),
              ],
              stops: const [0, 1],
            ).createShader(Rect.fromCircle(center: center, radius: reach)),
        );
        // Paired short creases suggest fabric being drawn toward each hole.
        for (final sign in [-1.0, 1.0]) {
          final axis = Offset(-direction.dy, direction.dx) * sign;
          final crease = Path()
            ..moveTo(center.dx, center.dy)
            ..quadraticBezierTo(
              center.dx + axis.dx * reach * .4 + direction.dx * width,
              center.dy + axis.dy * reach * .4 + direction.dy * width,
              center.dx + axis.dx * reach * .8,
              center.dy + axis.dy * reach * .8,
            );
          final bounds = Rect.fromCircle(center: center, radius: reach);
          canvas.drawPath(
            crease,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = width * .6
              ..shader = RadialGradient(
                colors: [
                  Color.fromRGBO(35, 22, 15, .065 * strength),
                  const Color(0x00000000),
                ],
              ).createShader(bounds),
          );
          canvas.drawPath(
            crease.shift(-direction * width * .45),
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = width * .5
              ..shader = RadialGradient(
                colors: [
                  Color.fromRGBO(255, 255, 255, .18 * strength),
                  const Color(0x00FFFFFF),
                ],
              ).createShader(bounds),
          );
        }
      }
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
