part of 'living_material_art.dart';

void _paintContact(
  Canvas canvas,
  double progress,
  double wetness,
  WatercolorExperiment experiment, {
  required bool showBrush,
  required bool fadeBrush,
}) {
  const pink = Color(0xFFC45D8B),
      blue = Color(0xFF326FA9),
      paper = Color(0xFFFFFDF8);
  final base = pigmentOutline(const Rect.fromLTWH(95, 85, 390, 220), seed: 52);
  final layered = experiment == WatercolorExperiment.layers;
  if (layered) {
    paintWatercolor(
      canvas,
      base,
      pigment: pink,
      companion: const Color(0xFFE7A4AE),
      paper: paper,
      seed: 52,
      opacity: .7,
    );
  }
  if (experiment == WatercolorExperiment.stroke) {
    _paintDraggedWash(canvas, progress, wetness);
    if (showBrush) {
      final position = _brushMetric.getTangentForOffset(
        _brushMetric.length * (progress / .72).clamp(0.0, 1.0),
      )!;
      final lift = fadeBrush ? ((progress - .72) / .23).clamp(0.0, 1.0) : 0.0;
      _brushAt(
        canvas,
        position.position + Offset(lift * 15, -lift * 35),
        .35 + position.angle * .18,
        1 - lift,
      );
    }
    return;
  }
  const contact = Offset(300, 190);
  final deposit = pigmentOutline(
    Rect.fromCenter(
      center: contact,
      width: 65 + 245 * wetness,
      height: 28 + 160 * wetness,
    ),
    seed: 31,
  );
  final localProgress = wetness == 0 ? math.min(1.0, progress * 8) : progress;
  paintWatercolorSpread(
    canvas,
    deposit,
    pigment: blue,
    paper: Colors.transparent,
    seed: 31,
    opacity: .68,
    origin: contact,
    progress: localProgress,
  );
  if (layered && wetness > 0 && progress > 0) {
    canvas.save();
    canvas.clipPath(base);
    // Art-directed color exchange only in the overlap. This is an RGB mixture,
    // not spectral pigment mixing or an implementation of fluid transport.
    final mixed = Color.lerp(pink, blue, .55)!;
    paintWatercolorSpread(
      canvas,
      deposit,
      pigment: mixed,
      companion: pink,
      paper: Colors.transparent,
      seed: 59,
      opacity: .38 * wetness,
      progress: math.pow(progress, .8).toDouble(),
      origin: contact,
    );
    canvas.restore();
  }
  if (showBrush) {
    final lift = fadeBrush ? (progress / .25).clamp(0.0, 1.0) : 0.0;
    _brushAt(canvas, contact + Offset(lift * 12, -lift * 25), .45, 1 - lift);
  }
}

void _brushAt(Canvas canvas, Offset position, double angle, double opacity) {
  if (opacity <= 0) return;
  canvas.save();
  canvas.translate(position.dx, position.dy);
  canvas.rotate(angle);
  final bristles = Path()
    ..moveTo(0, 2)
    ..quadraticBezierTo(-11, -9, -7, -29)
    ..lineTo(9, -29)
    ..quadraticBezierTo(9, -8, 0, 2)
    ..close();
  canvas.drawPath(
    bristles,
    Paint()..color = const Color(0xFF665143).withValues(alpha: opacity),
  );
  for (var i = -4; i <= 6; i += 2) {
    canvas.drawLine(
      Offset(i.toDouble(), -25),
      Offset(i * .15, -1),
      Paint()
        ..strokeWidth = .6
        ..color = const Color(0xFF2A6698).withValues(alpha: opacity * .75),
    );
  }
  canvas.drawLine(
    const Offset(1, -29),
    const Offset(3, -48),
    Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 13
      ..color = const Color(0xFFB8A786).withValues(alpha: opacity),
  );
  canvas.drawLine(
    const Offset(3, -48),
    const Offset(8, -112),
    Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 8
      ..color = const Color(0xFF925D43).withValues(alpha: opacity),
  );
  canvas.restore();
}

final _brushRoute = craftCurveThrough(const [
  Offset(90, 230),
  Offset(210, 125),
  Offset(355, 220),
  Offset(485, 125),
]);
final _brushMetric = _brushRoute.computeMetrics().single;
final _brushEdges = () {
  final random = math.Random(23);
  return List.generate(17, (_) => (random.nextDouble(), random.nextDouble()));
}();

// One connected swept silhouette, not a sequence of round pigment stamps.
// Fixed stations/seed keep the existing pigment field anchored while its edges
// widen according to local contact age. This is authored diffusion, not fluid.
Path _draggedOutline(double progress, double wetness) {
  if (progress <= 0) return Path();
  final travel = (progress / .72).clamp(0.0, 1.0);
  final left = <Offset>[], right = <Offset>[];
  final stations = <double>[
    for (var i = 0; i <= (travel * 128).floor(); i++) i / 128,
    if (travel * 128 != (travel * 128).floor()) travel,
  ];
  for (final fraction in stations) {
    final tangent = _brushMetric.getTangentForOffset(
      _brushMetric.length * fraction,
    )!;
    final normal = Offset(-tangent.vector.dy, tangent.vector.dx);
    final age = ((progress - fraction * .72) / (1 - fraction * .72)).clamp(
      0.0,
      1.0,
    );
    final index = (fraction * 16).floor().clamp(0, 15);
    final local = fraction * 16 - index;
    final mix = local * local * (3 - 2 * local);
    final a = _brushEdges[index], b = _brushEdges[index + 1];
    final edgeLeft = a.$1 * (1 - mix) + b.$1 * mix;
    final edgeRight = a.$2 * (1 - mix) + b.$2 * mix;
    final distance = fraction * _brushMetric.length;
    final endDistance = (1 - fraction) * _brushMetric.length;
    final taper = (math.min(distance, endDistance) / 22).clamp(0.0, 1.0);
    final width = (8 + wetness * 22 * math.sqrt(age)) * (.3 + .7 * taper);
    left.add(tangent.position + normal * width * (.85 + .25 * edgeLeft));
    right.add(tangent.position - normal * width * (.85 + .25 * edgeRight));
  }
  return Path()..addPolygon([...left, ...right.reversed], true);
}

void _paintDraggedWash(Canvas canvas, double progress, double wetness) {
  if (progress <= 0) return;
  const blue = Color(0xFF326FA9);
  final wet = _draggedOutline(progress, wetness);
  final finalOutline = _draggedOutline(1, wetness);
  canvas.save();
  try {
    canvas.clipPath(finalOutline);
    for (var i = 3; i >= 1; i--) {
      canvas.drawPath(
        wet,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = i * wetness * 1.2
          ..color = blue.withValues(alpha: .025),
      );
    }
    canvas.clipPath(wet);
    paintWatercolor(
      canvas,
      finalOutline,
      pigment: blue,
      paper: Colors.transparent,
      seed: 23,
      opacity: .78,
    );
  } finally {
    canvas.restore();
  }
}
