part of 'living_material_art.dart';

// Original example seam: the existing package prepares the visible spans once.
final _finishingSeam = Path()
  ..moveTo(395, 205)
  ..cubicTo(450, 115, 322, 70, 240, 112)
  ..cubicTo(147, 158, 186, 265, 286, 268)
  ..cubicTo(340, 272, 381, 242, 395, 205)
  ..close();
final _finishingStitches = craftStitchPath(
  _finishingSeam,
  pitch: _finishingSeam.computeMetrics().single.length / 16,
).computeMetrics().take(16).toList();

void _paintThreadFinish(Canvas canvas, double progress, int remaining) {
  const color = Color(0xFF427B6D);
  final existing = _finishingStitches.length - remaining;
  final settled = Path();
  for (var i = 0; i < _finishingStitches.length; i++) {
    final metric = _finishingStitches[i];
    final phase = i < existing
        ? 1.0
        : (progress * remaining - (i - existing)).clamp(0.0, 1.0);
    if (phase <= 0) continue;
    // The last portion of each interval is hidden transit beneath the cloth.
    if (phase >= .82) {
      settled.addPath(metric.extractPath(0, metric.length), Offset.zero);
      continue;
    }
    final front = phase / .82;
    final a = metric.getTangentForOffset(0)!;
    final b = metric.getTangentForOffset(metric.length)!;
    final delta = b.position - a.position;
    final normal = Offset(-delta.dy, delta.dx) / delta.distance;
    final tighten = ((front - .35) / .65).clamp(0.0, 1.0);
    final height = 40 * math.pow(1 - tighten, 1.5).toDouble();
    final wander = _strandWander(i, front);
    final c1 = a.position + delta * .28 - normal * height * (1 + .2 * wander);
    final c2 = b.position - delta * .22 + normal * height * (.55 + .2 * wander);
    final loose = Path()
      ..moveTo(a.position.dx, a.position.dy)
      ..cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, b.position.dx, b.position.dy);
    // A growing path has a moving bare thread tip, not a needle or a new hole.
    final frame = CraftStitchFrame.sample(
      loose,
      progress: (front / .48).clamp(0.0, 1.0),
    );
    canvas.drawPath(
      frame.path.shift(Offset(1, 1 + height * .05)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = const Color(0x14000000),
    );
    frame.paint(canvas, thread: color, width: 2.1, compression: .6);
  }
  CraftStitchFrame.sample(
    settled,
    progress: 1,
  ).paint(canvas, thread: color, width: 2.1, compression: .6);
}

// Optional authored prop for the full reveal only; hidden on return phases.
void _paintStudyNeedle(Canvas canvas, Offset eye, Offset direction) {
  final along = direction / direction.distance;
  final across = Offset(-along.dy, along.dx);
  final tip = eye + along * 18;
  canvas.drawLine(
    eye,
    tip,
    Paint()
      ..color = const Color(0xFF737D86)
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round,
  );
  canvas.drawLine(
    eye + across * .45,
    tip,
    Paint()
      ..color = const Color(0xFFEAF0EF)
      ..strokeWidth = .65,
  );
  canvas.drawOval(
    Rect.fromCenter(center: eye + along * 2, width: 2, height: 2),
    Paint()..color = const Color(0xFF505B62),
  );
}
