import 'dart:math' as math;

import 'package:flutter/painting.dart';

import 'path_geometry.dart';

/// Surface marks composed over an existing paper fill/grain.
enum PaperFinish {
  /// Fine laid lines with wider chain-line spacing.
  laid,

  /// Short visible fibers and inclusions.
  recycled,

  /// Directional flutes with a narrow highlight and contact tone.
  corrugated,

  /// Small irregular pits suggesting watercolor-paper tooth.
  coldPress,

  /// Broad soft sheen for coated cardstock; direction follows the bounds.
  satin,
}

/// Paints a bounded seeded paper finish without replacing its substrate.
///
/// [ink] and [highlight] supply the caller's tones. Strength is 0..1 and scale
/// 0.5..4. Outline must be closed, have bounds up to 2048 per axis and obey shared
/// path limits. All marks clip to it, including holes. No image/cache/timer is
/// allocated. Random marks cap at 900; directional strokes cap at 2200. Colors and
/// zero strength are composable; this does not model optical or physical paper.
void paintPaperFinish(
  Canvas canvas,
  Path outline, {
  required PaperFinish finish,
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
    throw ArgumentError('Expected strength 0..1 and scale 0.5..4');
  }
  final metrics = checkedPathMetrics(outline), bounds = outline.getBounds();
  if (metrics.any((m) => !m.isClosed) ||
      bounds.width > 2048 ||
      bounds.height > 2048) {
    throw ArgumentError(
      'Expected closed paper with bounds up to 2048 per axis',
    );
  }
  if (strength == 0 || bounds.isEmpty || (ink.a == 0 && highlight.a == 0)) {
    return;
  }
  final random = math.Random(seed);
  final dark = Paint()
    ..color = ink.withValues(alpha: ink.a * strength * .35)
    ..strokeWidth = .6 * scale
    ..strokeCap = StrokeCap.round;
  final light = Paint()
    ..color = highlight.withValues(alpha: highlight.a * strength * .45)
    ..strokeWidth = .8 * scale
    ..strokeCap = StrokeCap.round;
  canvas.save();
  try {
    canvas.clipPath(outline);
    switch (finish) {
      case PaperFinish.satin:
        canvas.drawRect(
          bounds,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                highlight.withValues(alpha: highlight.a * strength * .5),
                highlight.withValues(alpha: 0),
                ink.withValues(alpha: ink.a * strength * .15),
                highlight.withValues(alpha: highlight.a * strength * .22),
              ],
              stops: const [0, .44, .7, 1],
            ).createShader(bounds),
        );
      case PaperFinish.laid:
        for (var i = 0; i < (bounds.height / (4 * scale)).ceil(); i++) {
          final y = bounds.top + (2 + i * 4) * scale;
          if (y >= bounds.bottom) continue;
          canvas.drawLine(
            Offset(bounds.left, y),
            Offset(bounds.right, y),
            dark,
          );
          canvas.drawLine(
            Offset(bounds.left, y + scale),
            Offset(bounds.right, y + scale),
            light,
          );
        }
        for (var i = 0; i < (bounds.width / (40 * scale)).ceil(); i++) {
          final x = bounds.left + (20 + i * 40) * scale;
          if (x >= bounds.right) continue;
          canvas.drawLine(
            Offset(x, bounds.top),
            Offset(x, bounds.bottom),
            dark,
          );
        }
      case PaperFinish.corrugated:
        final shade = Paint()
          ..color = ink.withValues(alpha: ink.a * strength * .12);
        for (var i = 0; i < (bounds.width / (12 * scale)).ceil(); i++) {
          final x = bounds.left + i * 12 * scale;
          canvas.drawRect(
            Rect.fromLTWH(x, bounds.top, 5 * scale, bounds.height),
            shade,
          );
          canvas.drawLine(
            Offset(x + 5 * scale, bounds.top),
            Offset(x + 5 * scale, bounds.bottom),
            dark,
          );
          canvas.drawLine(
            Offset(x + 7 * scale, bounds.top),
            Offset(x + 7 * scale, bounds.bottom),
            light,
          );
        }
      case PaperFinish.recycled:
      case PaperFinish.coldPress:
        final count =
            (bounds.width *
                    bounds.height /
                    ((finish == PaperFinish.recycled ? 250 : 110) *
                        scale *
                        scale))
                .round()
                .clamp(1, 900);
        for (var i = 0; i < count; i++) {
          final point = Offset(
            bounds.left + random.nextDouble() * bounds.width,
            bounds.top + random.nextDouble() * bounds.height,
          );
          if (finish == PaperFinish.recycled) {
            final angle = random.nextDouble() * math.pi;
            final direction =
                Offset(math.cos(angle), math.sin(angle)) *
                scale *
                (1 + random.nextDouble() * 3);
            canvas.drawLine(point, point + direction, i.isEven ? dark : light);
          } else {
            final pit = Rect.fromCenter(
              center: point,
              width: scale * (1 + random.nextDouble() * 2.5),
              height: scale * (1 + random.nextDouble() * 1.5),
            );
            canvas.drawOval(pit.shift(Offset(scale * .5, scale * .6)), light);
            canvas.drawOval(pit, dark);
          }
        }
    }
  } finally {
    canvas.restore();
  }
}
