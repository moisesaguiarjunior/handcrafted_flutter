part of 'craft_trim.dart';

// Align the sampling grid to crossing intervals and whole closed repeats.
// The same plan is used to validate the budget before any painting.
({double turns, int chunks, int steps, int samples}) _braidPlan(
  ui.PathMetric metric,
  double width,
  double pitch,
  int strands,
) {
  if (metric.length == 0) return (turns: 0, chunks: 0, steps: 0, samples: 0);
  final period = math.max(width * 4.4, pitch * strands * 2);
  final turns = metric.isClosed
      ? (metric.length / period).round().clamp(1, 4096).toDouble()
      : metric.length / period;
  final chunks = math.max(1, (turns * strands * 2).ceil());
  final steps = math.max(3, (metric.length / chunks / (pitch / 4)).ceil());
  return (
    turns: turns,
    chunks: chunks,
    steps: steps,
    samples: chunks * steps + 1,
  );
}

class _CordSection {
  const _CordSection(
    this.path,
    this.fibers,
    this.color,
    this.depth,
    this.order,
  );
  final Path path;
  final List<Path> fibers;
  final Color color;
  final double depth;
  final int order;
}

void _paintBraidedCord(
  Canvas canvas,
  List<ui.PathMetric> metrics,
  List<Color> colors, {
  required double width,
  required double pitch,
  required double relief,
  required double texture,
  required Offset light,
}) {
  final sections = <_CordSection>[];
  final shadows = <({Path path, Color color})>[];
  final diameter = width * math.min(.55, 1.05 / colors.length);
  final radius = (width - diameter) / 2;
  double depth(double phase) => colors.length == 2
      ? math.cos(phase)
      : math.sin(2 * phase) + .12 * math.cos(phase);
  metricLoop:
  for (final metric in metrics) {
    if (metric.length == 0) continue;
    final plan = _braidPlan(metric, width, pitch, colors.length);
    final centers = <Offset>[], normals = <Offset>[];
    for (var i = 0; i < plan.samples; i++) {
      final tangent = metric.getTangentForOffset(
        metric.length * i / (plan.samples - 1),
      );
      if (tangent == null) continue metricLoop;
      centers.add(tangent.position);
      normals.add(Offset(-tangent.vector.dy, tangent.vector.dx));
    }
    for (var strand = 0; strand < colors.length; strand++) {
      double phase(num i) =>
          math.pi *
          2 *
          (plan.turns * i / (plan.samples - 1) + strand / colors.length);
      final points = [
        for (var i = 0; i < plan.samples; i++)
          centers[i] + normals[i] * math.sin(phase(i)) * radius,
      ];
      if (relief > 0) {
        shadows.add((
          path: Path()..addPolygon(points, false),
          color: colors[strand],
        ));
      }
      for (var chunk = 0; chunk < points.length - 1; chunk++) {
        final start = chunk, end = chunk + 1;
        final from = start, to = end;
        final path = Path(), fibers = [Path(), Path(), Path()];
        for (var i = from; i <= to; i++) {
          final p = points[i];
          final tangent =
              points[math.min(i + 1, points.length - 1)] -
              points[math.max(0, i - 1)];
          final n = tangent.distance == 0
              ? Offset.zero
              : Offset(-tangent.dy, tangent.dx) / tangent.distance;
          if (i == from) {
            path.moveTo(p.dx, p.dy);
          } else {
            path.lineTo(p.dx, p.dy);
          }
          for (var fiber = 0; fiber < fibers.length; fiber++) {
            final offset =
                (fiber - 1) * .22 + .04 * math.sin(i * 2.3 + strand * 1.7);
            final q = p + n * diameter * offset;
            if (i == from) {
              fibers[fiber].moveTo(q.dx, q.dy);
            } else {
              fibers[fiber].lineTo(q.dx, q.dy);
            }
          }
        }
        sections.add(
          _CordSection(
            path,
            fibers,
            colors[strand],
            depth(phase((start + end) / 2)),
            sections.length,
          ),
        );
      }
    }
  }
  // Stable ties preserve arc order; nearer strands cover farther ones at crossings.
  sections.sort((a, b) {
    final z = a.depth.compareTo(b.depth);
    return z == 0 ? a.order.compareTo(b.order) : z;
  });
  Paint stroke(Color color, double size) => Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = size
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;
  // Ground shadow is painted once per continuous strand, never per sample.
  // Overlapping sampled shadows would darken the yarn as sampling gets denser.
  for (final shadow in shadows) {
    canvas.drawPath(
      shadow.path.shift(-light * diameter * .2),
      stroke(
        Color.fromRGBO(25, 20, 18, .23 * relief * shadow.color.a),
        diameter * 1.18,
      ),
    );
  }
  for (final section in sections) {
    final c = section.color;
    final edge = Color.lerp(
      c,
      const Color(0xFF302720).withValues(alpha: c.a),
      relief * .16,
    )!;
    canvas.drawPath(section.path, stroke(edge, diameter));
    canvas.drawPath(
      section.path.shift(light * diameter * .035),
      stroke(c, diameter * .92),
    );
    if (relief > 0) {
      canvas.drawPath(
        section.path.shift(light * diameter * .23),
        stroke(
          Color.fromRGBO(255, 255, 255, .18 * relief * c.a),
          diameter * .24,
        ),
      );
    }
    if (texture > 0) {
      for (var i = 0; i < section.fibers.length; i++) {
        canvas.drawPath(
          section.fibers[i],
          stroke(
            i == 0
                ? Color.fromRGBO(30, 23, 18, .27 * texture * c.a)
                : Color.fromRGBO(255, 255, 255, .45 * texture * c.a),
            diameter * .045,
          ),
        );
      }
    }
  }
}
