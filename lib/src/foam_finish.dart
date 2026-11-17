import 'dart:math' as math;

import 'package:flutter/painting.dart';

import 'path_geometry.dart';

/// Embossed marks over EVA's independently owned fine-pore substrate.
enum FoamFinish {
  /// Dense paired cells, useful for rougher cut foam.
  pebbled,

  /// Broad low-contrast color islands.
  mottled,

  /// Long directional pressed grooves.
  grooved,

  /// Small irregular crossed impressions.
  crosshatched,
}

/// Paints a seeded finish over EVA, without replacing the substrate or shape.
///
/// [strength] is 0..1, [scale] 0.5..4. Closed outlines follow shared path limits
/// and bounds up to 2048 per axis. Marks clip to holes as well as outer edges.
/// At most 900 motifs (four draws each) or 512 groove pairs are painted. All
/// validation precedes painting, even for zero strength. No cache/layer/clock is
/// allocated. Compose existing raised relief on each layer for a beveled edge;
/// these are illustrative finishes, not foam deformation or a thickness solver.
void paintFoamFinish(
  Canvas canvas,
  Path outline, {
  required FoamFinish finish,
  required Color ink,
  Color highlight = const Color(0xFFFFFFFF),
  int seed = 7,
  double strength = .6,
  double scale = 1,
}) {
  if (!strength.isFinite ||
      strength < 0 ||
      strength > 1 ||
      !scale.isFinite ||
      scale < .5 ||
      scale > 4) {
    throw ArgumentError('Expected foam strength 0..1 and scale 0.5..4');
  }
  final metrics = checkedPathMetrics(outline);
  final bounds = outline.getBounds();
  if (metrics.any((m) => !m.isClosed) ||
      bounds.width > 2048 ||
      bounds.height > 2048) {
    throw ArgumentError('Expected closed foam with bounds up to 2048 per axis');
  }
  if (strength == 0 || bounds.isEmpty) return;
  final random = math.Random(seed);
  final dark = Paint()
    ..color = ink.withValues(alpha: ink.a * strength * .12)
    ..strokeWidth = .7 * scale
    ..strokeCap = StrokeCap.round;
  final light = Paint()
    ..color = highlight.withValues(alpha: highlight.a * strength * .18)
    ..strokeWidth = .8 * scale
    ..strokeCap = StrokeCap.round;
  canvas.save();
  try {
    canvas.clipPath(outline);
    if (finish == FoamFinish.grooved) {
      final count = (bounds.width / (8 * scale)).ceil().clamp(1, 512);
      for (var i = 0; i < count; i++) {
        final x = bounds.left + i * 8 * scale;
        final bend = (random.nextDouble() - .5) * 28 * scale;
        final groove = Path()
          ..moveTo(x, bounds.top)
          ..cubicTo(
            x + bend,
            bounds.top + bounds.height * .33,
            x - bend,
            bounds.top + bounds.height * .67,
            x,
            bounds.bottom,
          );
        dark.style = PaintingStyle.stroke;
        light.style = PaintingStyle.stroke;
        canvas.drawPath(groove, dark);
        canvas.drawPath(groove.shift(Offset(scale, 0)), light);
      }
      return;
    }
    final count =
        (bounds.width *
                bounds.height /
                ((finish == FoamFinish.mottled ? 500 : 60) * scale * scale))
            .round()
            .clamp(1, 900);
    for (var i = 0; i < count; i++) {
      final p = Offset(
        bounds.left + random.nextDouble() * bounds.width,
        bounds.top + random.nextDouble() * bounds.height,
      );
      switch (finish) {
        case FoamFinish.pebbled:
          final radius = scale * (.35 + random.nextDouble() * .9);
          canvas.drawCircle(p + Offset(.6 * scale, .7 * scale), radius, light);
          canvas.drawCircle(p, radius * .85, dark);
        case FoamFinish.mottled:
          final patch = Rect.fromCenter(
            center: p,
            width: scale * (18 + random.nextDouble() * 28),
            height: scale * (12 + random.nextDouble() * 20),
          );
          for (var ring = 0; ring < 4; ring++) {
            canvas.drawOval(
              patch.deflate(ring * scale),
              Paint()
                ..color = (i.isEven ? ink : highlight).withValues(
                  alpha: (i.isEven ? ink.a : highlight.a) * strength * .015,
                ),
            );
          }
        case FoamFinish.crosshatched:
          final d = Offset(scale * (1 + random.nextDouble() * 3), scale * 2);
          canvas.drawLine(p - d, p + d, dark);
          canvas.drawLine(
            p + Offset(-d.dx, d.dy),
            p + Offset(d.dx, -d.dy),
            dark,
          );
          canvas.drawLine(
            p - d + Offset(0, scale),
            p + d + Offset(0, scale),
            light,
          );
        case FoamFinish.grooved:
          break;
      }
    }
  } finally {
    canvas.restore();
  }
}
