part of 'craft_stroke.dart';

// Distance-anchored deposits retain the same prefix during reveal. Dotted
// instruments keep the existing width + gap phase; other patterns reuse spans.
// At most 8224 deposits (8192 arc units plus 32 contours), four draws each.
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
      : math.max(2.0, style.width * .2);
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
    ..color = color.withValues(alpha: color.a * baseAlpha);
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
        ..color = color.withValues(alpha: color.a * baseAlpha);
      canvas.drawLine(
        center - forward * length / 2,
        center + forward * length / 2,
        paint,
      );
    }
    for (var lane = 0; lane < 3; lane++) {
      final index = (d * 16).floor() * 7 + lane * 101;
      final a = _dryNoise(index, grainSeed);
      final b = _dryNoise(index + 53, grainSeed);
      final jitter = (a - .5) * style.variation;
      final across = ((lane - 1) * .2 + jitter * .6).clamp(-.33, .33);
      final start = center + normal * (style.width * across);
      final grainWidth = switch (style.tool) {
        CraftStrokeTool.pencil => style.width * .075,
        CraftStrokeTool.chalk => style.width * (.03 + b * .055),
        _ => style.width * .13,
      };
      final grainLength = switch (style.tool) {
        CraftStrokeTool.pencil => length * (.65 + jitter * .3),
        CraftStrokeTool.chalk => length * (.12 + a * .25),
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
