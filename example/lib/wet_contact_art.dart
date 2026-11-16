part of 'living_material_art.dart';

void _paintContact(
  Canvas canvas,
  double progress,
  double wetness,
  WatercolorExperiment experiment,
) {
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
    final route = craftCurveThrough(const [
      Offset(90, 230),
      Offset(210, 125),
      Offset(355, 220),
      Offset(485, 125),
    ]);
    final metric = route.computeMetrics().single;
    for (var i = 0; i < 16; i++) {
      final time = i / 15 * .72;
      final age = Interval(time, 1).transform(progress);
      if (age == 0) continue;
      final point = metric
          .getTangentForOffset(metric.length * i / 15)!
          .position;
      final deposit = pigmentOutline(
        Rect.fromCenter(
          center: point,
          width: 60 + wetness * 85,
          height: 30 + wetness * 65,
        ),
        seed: 23 + i,
      );
      paintWatercolorSpread(
        canvas,
        deposit,
        pigment: blue,
        paper: Colors.transparent,
        seed: 23 + i,
        opacity: .27,
        origin: point,
        progress: wetness == 0 ? math.min(1.0, age * 7) : age,
      );
    }
    final position = metric.getTangentForOffset(
      metric.length * (progress / .72).clamp(0.0, 1.0),
    )!;
    final lift = ((progress - .72) / .23).clamp(0.0, 1.0);
    _brushAt(
      canvas,
      position.position + Offset(lift * 15, -lift * 35),
      .45,
      1 - lift,
    );
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
  final lift = (progress / .25).clamp(0.0, 1.0);
  _brushAt(canvas, contact + Offset(lift * 12, -lift * 25), .45, 1 - lift);
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
