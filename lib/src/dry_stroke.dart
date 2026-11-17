part of 'craft_stroke.dart';

// Distance-anchored deposits retain the same prefix during reveal. Dotted
// instruments keep the existing width + gap phase; other patterns reuse spans.
// At most 8224 deposits (8192 arc units plus 32 contours), eight draws each.
// No erasing, substrate-colored speckles, blur, image cache or saveLayer.
void _paintDryStroke(
  Canvas canvas,
  PathSpan span,
  Color color,
  CraftStrokeStyle style,
  int seed,
) {
  final dotted = style.pattern == CraftLinePattern.dotted;
  final step = dotted
      ? style.width + style.gap
      : math.max(
          1.0,
          math.max(2.0, style.width * .2) * (1 - style.dryCoverage * .5),
        );
  final baseAlpha = switch (style.tool) {
    CraftStrokeTool.pencil => .12,
    CraftStrokeTool.chalk => .08,
    _ => .36,
  };
  final paint = Paint()..style = PaintingStyle.stroke;
  final grainSeed = style.variation == 0 ? 0 : seed & 0xffff;
  paint
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..strokeWidth = style.width * .65
    ..color = color.withValues(
      alpha: color.a * (baseAlpha + style.dryCoverage * .1),
    );
  if (!dotted) {
    canvas.drawPath(
      spanPath([span], preserveClosed: style.pattern == CraftLinePattern.solid),
      paint,
    );
  }
  for (var d = span.start; d < span.end; d += step) {
    final tangent = span.metric.getTangentForOffset(d);
    if (tangent == null) continue;
    final forward = tangent.vector;
    final normal = Offset(-forward.dy, forward.dx);
    final center = tangent.position;
    final length = math.min(style.width * .3, step * .7);
    if (dotted) {
      paint
        ..strokeWidth = style.width * .65
        ..color = color.withValues(
          alpha: color.a * (baseAlpha + style.dryCoverage * .1),
        );
      canvas.drawLine(
        center - forward * length / 2,
        center + forward * length / 2,
        paint,
      );
    }
    final lanes = 3 + (style.dryCoverage * 4).round();
    for (var lane = 0; lane < lanes; lane++) {
      final index = (d * 16).floor() * 7 + lane * 101;
      final a = _dryNoise(index, grainSeed);
      final b = _dryNoise(index + 53, grainSeed);
      final jitter = (a - .5) * style.variation;
      final across = style.dryCoverage == 0
          ? ((lane - 1) * .2 + jitter * .6).clamp(-.33, .33)
          : ((lane / (lanes - 1) - .5) * .7 + jitter * .3).clamp(-.45, .45);
      final start =
          center +
          normal * (style.width * across) +
          forward * ((a - .5) * step * .8 * style.dryCoverage);
      final grainWidth = switch (style.tool) {
        CraftStrokeTool.pencil => style.width * .075,
        CraftStrokeTool.chalk =>
          style.width * (.03 + b * .055 + style.dryCoverage * .04),
        _ => style.width * .13,
      };
      final grainLength = switch (style.tool) {
        CraftStrokeTool.pencil => length * (.65 + jitter * .3),
        CraftStrokeTool.chalk =>
          length * (.12 + a * .25 + style.dryCoverage * (1 + a) * .8),
        _ => length * (.8 + jitter * .3),
      };
      paint
        ..strokeWidth = math.max(.12, grainWidth)
        ..color = color.withValues(
          alpha:
              color.a *
              ((style.tool == CraftStrokeTool.chalk ? .6 : .38) + jitter * .4),
        );
      canvas.drawLine(
        start - forward * grainLength / 2,
        start + forward * grainLength / 2,
        paint,
      );
    }
  }
}

// Integer arithmetic stays below JS's exact-integer boundary before bit masks.
double _dryNoise(int index, int seed) {
  var value = (index * 374761 + seed * 668265) & 0x7fffffff;
  value = ((value ^ (value >> 13)) * 12741) & 0x7fffffff;
  return (value ^ (value >> 16)) / 0x7fffffff;
}
