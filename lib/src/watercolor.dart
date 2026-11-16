import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import 'package:flutter/painting.dart';

import 'path_geometry.dart';
import 'pigment_outline.dart';

part 'watercolor_spread.dart';

/// Layered pigment, blooms, tide marks and granular deposits inside [outline].
///
/// The supplied closed silhouette and its holes are preserved exactly for
/// clipping. [paper] is the underlying paper color; grain is composed separately
/// with `CraftSurface` or `MaterialTextures`. All palette values are host-owned.
/// [opacity] and [granulation] are 0..1. Bounds are at most 2048 logical pixels
/// per axis; contour/length limits match stitches. Inputs are checked before any
/// painting. Zero opacity paints nothing. No blur, clock or fluid solver is used.
///
/// This is a deterministic visual approximation on the same rendering engine,
/// not a simulation of pigment diffusion or drying over time.
void paintWatercolor(
  Canvas canvas,
  Path outline, {
  required Color pigment,
  required Color paper,
  Color? companion,
  int seed = 7,
  double opacity = .55,
  double granulation = .7,
}) {
  final (:bounds, :metrics) = _validateWatercolor(
    outline,
    opacity,
    granulation,
  );
  final second = companion ?? pigment;
  final amount = opacity * math.max(pigment.a, second.a);
  if (bounds.isEmpty || metrics.isEmpty || amount == 0) return;
  final random = math.Random(seed);
  final unit = math.min(bounds.width, bounds.height);
  Color ink(Color color, double strength) =>
      color.withValues(alpha: color.a * opacity * strength);
  Color exposedPaper(double strength) =>
      paper.withValues(alpha: paper.a * amount * strength);
  canvas.save();
  canvas.clipPath(outline);
  canvas.drawPath(outline, Paint()..color = ink(pigment, .24));
  // Overlapping puddles retain their own irregular boundaries.
  for (var i = 0; i < 8; i++) {
    final rect = Rect.fromCenter(
      center: Offset(
        bounds.left + random.nextDouble() * bounds.width,
        bounds.top + random.nextDouble() * bounds.height,
      ),
      width: bounds.width * (.22 + random.nextDouble() * .55),
      height: bounds.height * (.35 + random.nextDouble() * .65),
    );
    for (var layer = 0; layer < 5; layer++) {
      final inner = rect.deflate(layer * unit * .025);
      if (inner.isEmpty) continue;
      canvas.drawPath(
        pigmentOutline(inner, seed: seed + i),
        Paint()..color = ink(i.isEven ? pigment : second, .065),
      );
    }
  }
  // Pale backruns expose the supplied paper, with scalloped drying lines.
  for (var i = 0; i < 4; i++) {
    final bloom = pigmentOutline(
      Rect.fromCenter(
        center: Offset(
          bounds.left + random.nextDouble() * bounds.width,
          bounds.top + random.nextDouble() * bounds.height,
        ),
        width: unit * (.2 + random.nextDouble() * .55),
        height: unit * (.16 + random.nextDouble() * .38),
      ),
      seed: seed + i * 7,
    );
    canvas.drawPath(bloom, Paint()..color = exposedPaper(.12));
    canvas.drawPath(
      bloom,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = .5
        ..color = ink(pigment, .22),
    );
  }
  final deposits = Path(), pores = Path();
  final count = (bounds.width * bounds.height / 65).round().clamp(45, 650);
  for (var i = 0; i < count; i++) {
    final point = Offset(
      bounds.left + random.nextDouble() * bounds.width,
      bounds.top + random.nextDouble() * bounds.height,
    );
    (i.isEven ? deposits : pores).addOval(
      Rect.fromCircle(center: point, radius: .2 + random.nextDouble() * .55),
    );
  }
  canvas.drawPath(deposits, Paint()..color = ink(pigment, .45 * granulation));
  canvas.drawPath(pores, Paint()..color = exposedPaper(.4 * granulation));
  canvas.drawPath(
    outline,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..color = ink(pigment, .16),
  );
  final edgeHoles = Path();
  for (final metric in metrics) {
    for (var d = 0.0; d < metric.length; d += 2.2) {
      final point = metric.getTangentForOffset(d)!.position;
      edgeHoles.addOval(
        Rect.fromCircle(center: point, radius: .3 + random.nextDouble() * 1.6),
      );
    }
  }
  canvas.drawPath(edgeHoles, Paint()..color = exposedPaper(.5 * granulation));
  canvas.restore();
}

/// Internal shared preflight for static and explicitly spreading washes.
({Rect bounds, List<PathMetric> metrics}) _validateWatercolor(
  Path outline,
  double opacity,
  double granulation,
) {
  final metrics = checkedPathMetrics(outline);
  final bounds = outline.getBounds();
  if (!opacity.isFinite ||
      opacity < 0 ||
      opacity > 1 ||
      !granulation.isFinite ||
      granulation < 0 ||
      granulation > 1 ||
      bounds.width > 2048 ||
      bounds.height > 2048 ||
      metrics.any((m) => !m.isClosed)) {
    throw ArgumentError(
      'Expected a closed bounded wash and opacity/granulation 0..1',
    );
  }
  return (bounds: bounds, metrics: metrics);
}
