import 'dart:typed_data';
import 'dart:math' as math;

import 'package:flutter/painting.dart';

/// Uneven wet perimeter, with broad lobes and small capillary interruptions.
/// Deterministic for identical inputs on the tested toolchain. Geometry is fitted
/// to [rect]. Empty bounds yield an empty path; non-finite bounds throw
/// [ArgumentError]. [broad] selects a squarer silhouette. No time is read.
Path pigmentOutline(Rect rect, {required int seed, bool broad = false}) {
  if (![
    rect.left,
    rect.top,
    rect.right,
    rect.bottom,
  ].every((v) => v.isFinite)) {
    throw ArgumentError.value(rect, 'rect', 'Bounds must be finite');
  }
  if (rect.isEmpty) return Path();
  const count = 48;
  final points = <Offset>[];
  for (var i = 0; i < count; i++) {
    final a = i * math.pi * 2 / count;
    final r =
        1 +
        .065 * math.sin(a * 5 + seed) +
        .038 * math.sin(a * 11 + seed * .7) +
        .016 * math.cos(a * 23 + seed);
    double axis(double n) =>
        broad ? n.sign * math.pow(n.abs(), .47).toDouble() : n;
    points.add(
      rect.center +
          Offset(
            axis(math.cos(a)) * rect.width * .47 * r,
            axis(math.sin(a)) * rect.height * .45 * r,
          ),
    );
  }
  final path = Path();
  final start = (points.last + points.first) / 2;
  path.moveTo(start.dx, start.dy);
  for (var i = 0; i < count; i++) {
    final end = (points[i] + points[(i + 1) % count]) / 2;
    path.quadraticBezierTo(points[i].dx, points[i].dy, end.dx, end.dy);
  }
  path.close();
  final bounds = path.getBounds();
  final sx = rect.width / bounds.width;
  final sy = rect.height / bounds.height;
  return path.transform(
    Float64List.fromList([
      sx,
      0,
      0,
      0,
      0,
      sy,
      0,
      0,
      0,
      0,
      1,
      0,
      rect.left - bounds.left * sx,
      rect.top - bounds.top * sy,
      0,
      1,
    ]),
  );
}
