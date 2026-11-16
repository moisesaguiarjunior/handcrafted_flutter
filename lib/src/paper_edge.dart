import 'dart:math' as math;

import 'package:flutter/painting.dart';

import 'path_geometry.dart';

/// Independent silhouette treatments for paper recipes.
enum PaperEdge {
  /// A straight rectangular cut.
  cut,

  /// Seeded angular tears.
  torn,

  /// Soft, uneven handmade waves.
  deckle,

  /// Regular inward semicircular postage notches.
  postage,
}

/// Creates a closed edge entirely within [bounds], without painting fibers.
///
/// [depth] is maximum inward intrusion (0..12), at most pitch / 3.
/// [pitch] is 8..64 logical pixels. Bounds must be finite, at most 2048 on either
/// axis and within +/-8192 coordinates. Work is capped at 1024 edge periods.
/// Generated paths also obey the shared 32-contour / 8192-length limit.
/// Empty bounds produce an empty path; negative dimensions throw. Insufficient
/// corner room (depth * 3 > narrower dimension) produces an empty path. Zero depth or
/// cut produces a rectangle. Seed affects torn/deckle geometry only.
Path paperOutline(
  Rect bounds, {
  PaperEdge edge = PaperEdge.cut,
  int seed = 7,
  double depth = 3,
  double pitch = 12,
}) {
  if (![
        bounds.left,
        bounds.top,
        bounds.right,
        bounds.bottom,
      ].every((v) => v.isFinite && v.abs() <= 8192) ||
      bounds.width < 0 ||
      bounds.height < 0 ||
      bounds.width > 2048 ||
      bounds.height > 2048 ||
      !depth.isFinite ||
      depth < 0 ||
      depth > 12 ||
      !pitch.isFinite ||
      pitch < 8 ||
      pitch > 64 ||
      depth > pitch / 3) {
    throw ArgumentError(
      'Expected bounded rectangle, depth 0..12 <= pitch/3 and pitch 8..64',
    );
  }
  if (bounds.isEmpty) return Path();
  if (edge == PaperEdge.cut || depth == 0) return Path()..addRect(bounds);
  if (depth * 3 > math.min(bounds.width, bounds.height)) return Path();
  final corners = [
    bounds.topLeft,
    bounds.topRight,
    bounds.bottomRight,
    bounds.bottomLeft,
    bounds.topLeft,
  ];
  final counts = [
    for (var i = 0; i < 4; i++)
      math.max(1, ((corners[i + 1] - corners[i]).distance / pitch).floor()),
  ];
  if (counts.fold<int>(0, (n, count) => n + count) > 1024)
    throw ArgumentError('Paper edge exceeds 1024 periods');
  final random = math.Random(seed);
  final path = Path()..moveTo(bounds.left, bounds.top);
  for (var side = 0; side < 4; side++) {
    final delta = corners[side + 1] - corners[side];
    final along = delta / delta.distance, inward = Offset(-along.dy, along.dx);
    final step = delta.distance / counts[side];
    for (var i = 0; i < counts[side]; i++) {
      final start = corners[side] + along * (i * step),
          end = start + along * step;
      final midpoint = start + along * (step / 2);
      switch (edge) {
        case PaperEdge.cut:
          break;
        case PaperEdge.torn:
          final point =
              midpoint +
              along * ((random.nextDouble() - .5) * step * .2) +
              inward * (depth * (.2 + .8 * random.nextDouble()));
          path.lineTo(point.dx, point.dy);
          path.lineTo(end.dx, end.dy);
        case PaperEdge.deckle:
          final control =
              midpoint + inward * (depth * (.4 + .6 * random.nextDouble()));
          path.quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);
        case PaperEdge.postage:
          final before = midpoint - along * depth,
              after = midpoint + along * depth;
          path.lineTo(before.dx, before.dy);
          path.arcToPoint(
            after,
            radius: Radius.circular(depth),
            clockwise: false,
          );
          path.lineTo(end.dx, end.dy);
      }
    }
  }
  path.close();
  checkedPathMetrics(path);
  return path;
}

/// Draws clipped short fiber hairs along a supplied closed paper edge.
///
/// Keep silhouette and texture ownership independent. [strength] is 0..1;
/// [length] is 0..4 logical pixels. At most 4096 short strokes are recorded.
/// This is a visual fringe inside the material, not displaced or simulated fiber.
void paintPaperEdgeFibers(
  Canvas canvas,
  Path outline, {
  required Color fiber,
  int seed = 7,
  double strength = .6,
  double length = 2,
}) {
  if (!strength.isFinite ||
      strength < 0 ||
      strength > 1 ||
      !length.isFinite ||
      length < 0 ||
      length > 4)
    throw ArgumentError('Expected strength 0..1 and length 0..4');
  final metrics = checkedPathMetrics(outline);
  if (metrics.any((m) => !m.isClosed))
    throw ArgumentError('Expected closed paper contours');
  if (strength == 0 || length == 0 || fiber.a == 0) return;
  final random = math.Random(seed);
  final paint = Paint()
    ..color = fiber.withValues(alpha: fiber.a * strength)
    ..strokeWidth = .6
    ..strokeCap = StrokeCap.round;
  canvas.save();
  try {
    canvas.clipPath(outline);
    for (final metric in metrics) {
      for (var distance = 0.0; distance < metric.length; distance += 4) {
        final tangent = metric.getTangentForOffset(distance);
        if (tangent == null) continue;
        final normal = Offset(-tangent.vector.dy, tangent.vector.dx);
        final reach = length * (.4 + .6 * random.nextDouble());
        final center =
            tangent.position + tangent.vector * (random.nextDouble() - .5);
        canvas.drawLine(
          center - normal * reach,
          center + normal * reach,
          paint,
        );
      }
    }
  } finally {
    canvas.restore();
  }
}
