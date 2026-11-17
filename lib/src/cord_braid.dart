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

class _CordVertex {
  const _CordVertex(this.point, this.color);
  final Offset point;
  final int color;
}

class _CordFace {
  const _CordFace(this.first, this.last, this.depth, this.order, {this.cap});
  final List<_CordVertex> first, last;
  final List<_CordVertex>? cap;
  final double depth;
  final int order;
  int get vertexCount => cap?.length ?? (first.length - 1) * 6;
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
  final faces = <_CordFace>[];
  final shadows = <({Path path, Color color})>[];
  final diameter = width * math.min(.55, 1.05 / colors.length);
  final radius = (width - diameter) / 2;
  final yarnRadius = diameter / 2;
  final inner = 1.0 - math.min(.6 / yarnRadius, .35);
  final profile = <double>[-1.0, -inner, -.5, -.25, 0.0, .25, .5, inner, 1.0];
  double depth(double phase) => colors.length == 2
      ? math.cos(phase)
      : math.sin(2 * phase) + .12 * math.cos(phase);
  Color tone(Color c, double u, double phase, Offset normal, int strand) {
    final alignment = normal.dx * light.dx + normal.dy * light.dy;
    final shade =
        relief *
        (.1 * math.sqrt(math.max(0, 1 - u * u)) +
            .09 * alignment * u -
            .18 * u.abs());
    final fiber =
        texture *
        (.055 * math.cos(u * math.pi * 4 + .22 * math.sin(phase * 3 + strand)) +
            .018 * math.sin(phase * 37 + strand * 1.7));
    final amount = shade + fiber;
    return Color.lerp(
      c,
      (amount >= 0 ? const Color(0xFFFFFFFF) : const Color(0xFF302720))
          .withValues(alpha: c.a),
      amount.abs(),
    )!;
  }

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
      final c = colors[strand];
      if (c.a == 0) continue;
      double phase(num i) =>
          math.pi *
          2 *
          (plan.turns * i / (plan.samples - 1) + strand / colors.length);
      final points = [
        for (var i = 0; i < plan.samples; i++)
          centers[i] + normals[i] * math.sin(phase(i)) * radius,
      ];
      if (relief > 0) {
        shadows.add((path: Path()..addPolygon(points, false), color: c));
      }
      final rows = <List<_CordVertex>>[];
      final yarnNormals = <Offset>[];
      for (var i = 0; i < points.length; i++) {
        final last = points.length - 1;
        final before = metric.isClosed && (i == 0 || i == last)
            ? points[last - 1]
            : points[math.max(0, i - 1)];
        final after = metric.isClosed && (i == 0 || i == last)
            ? points[1]
            : points[math.min(last, i + 1)];
        final t = after - before;
        final normal = t.distance == 0
            ? normals[i]
            : Offset(-t.dy, t.dx) / t.distance;
        yarnNormals.add(normal);
        rows.add([
          for (final u in profile)
            _CordVertex(
              points[i] + normal * yarnRadius * u,
              tone(
                c,
                u,
                phase(i),
                normal,
                strand,
              ).withValues(alpha: u.abs() == 1 ? 0 : c.a).toARGB32(),
            ),
        ]);
      }
      for (var i = 0; i < rows.length - 1; i++) {
        faces.add(
          _CordFace(rows[i], rows[i + 1], depth(phase(i + .5)), faces.length),
        );
      }
      if (!metric.isClosed) {
        for (final endpoint in [0, points.length - 1]) {
          final normal = yarnNormals[endpoint];
          final tangent =
              Offset(normal.dy, -normal.dx) * (endpoint == 0 ? -1 : 1);
          final p = points[endpoint], cap = <_CordVertex>[];
          _CordVertex ring(double angle, double r, bool outer) {
            final u = math.cos(angle);
            return _CordVertex(
              p + (normal * u + tangent * math.sin(angle)) * r,
              tone(
                c,
                u * inner,
                phase(endpoint),
                normal,
                strand,
              ).withValues(alpha: outer ? 0 : c.a).toARGB32(),
            );
          }

          final center = _CordVertex(
            p,
            tone(c, 0, phase(endpoint), normal, strand).toARGB32(),
          );
          for (var i = 0; i < 8; i++) {
            final a = math.pi * i / 8, b = math.pi * (i + 1) / 8;
            final ia = ring(a, yarnRadius * inner, false),
                ib = ring(b, yarnRadius * inner, false);
            final oa = ring(a, yarnRadius, true),
                ob = ring(b, yarnRadius, true);
            cap.addAll([center, ia, ib, ia, oa, ob, ia, ob, ib]);
          }
          faces.add(
            _CordFace(
              const [],
              const [],
              depth(phase(endpoint)),
              faces.length,
              cap: cap,
            ),
          );
        }
      }
    }
  }
  if (faces.isEmpty) return;
  faces.sort((a, b) {
    final z = a.depth.compareTo(b.depth);
    return z == 0 ? a.order.compareTo(b.order) : z;
  });
  final count = faces.fold<int>(0, (sum, face) => sum + face.vertexCount);
  final positions = Float32List(count * 2), packed = Int32List(count);
  var vertex = 0;
  void emit(_CordVertex v) {
    positions[vertex * 2] = v.point.dx;
    positions[vertex * 2 + 1] = v.point.dy;
    packed[vertex++] = v.color;
  }

  for (final face in faces) {
    final cap = face.cap;
    if (cap != null) {
      for (final v in cap) {
        emit(v);
      }
    } else {
      for (var i = 0; i < face.first.length - 1; i++) {
        final a = face.first[i],
            b = face.last[i],
            c = face.last[i + 1],
            d = face.first[i + 1];
        emit(a);
        emit(b);
        emit(c);
        emit(a);
        emit(c);
        emit(d);
      }
    }
  }
  // A shared-edge mesh covers each yarn once. Repeated round-capped strokes
  // would accumulate alpha and darken a translucent yarn as sampling increases.
  final mesh = ui.Vertices.raw(
    ui.VertexMode.triangles,
    positions,
    colors: packed,
  );
  try {
    for (final shadow in shadows) {
      canvas.drawPath(
        shadow.path.shift(-light * diameter * .2),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = diameter * 1.18
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = Color.fromRGBO(25, 20, 18, .23 * relief * shadow.color.a),
      );
    }
    canvas.drawVertices(mesh, BlendMode.dst, Paint());
  } finally {
    mesh.dispose();
  }
}
