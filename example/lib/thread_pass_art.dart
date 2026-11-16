part of 'living_material_art.dart';

// Each pair is above the cloth. The connecting sections between pairs are
// below it and intentionally absent from the visible path. Anchors stay fixed.
const _threadStations = [
  Offset(170, 215),
  Offset(230, 212),
  Offset(264, 185),
  Offset(326, 190),
  Offset(353, 221),
  Offset(418, 205),
];

double _strandWander(int strand, double time) {
  double value(int knot) {
    final bits = ((strand + 3) * 374761 + (knot + 7) * 668265) & 0x7fffffff;
    return ((bits ^ (bits >> 11)) % 997) / 996 * 2 - 1;
  }

  final p = time.clamp(0.0, 1.0) * 4;
  final index = p.floor().clamp(0, 3);
  final fraction = p - index;
  final eased = fraction * fraction * (3 - 2 * fraction);
  return value(index) * (1 - eased) + value(index + 1) * eased;
}

void _paintThreadPass(Canvas canvas, double progress) {
  for (var i = 0; i < 3; i++) {
    final a = _threadStations[i * 2], b = _threadStations[i * 2 + 1];
    final delta = b - a;
    final normal = Offset(-delta.dy, delta.dx) / delta.distance;
    final tightening = (progress * 3 - i).clamp(0.0, 1.0);
    final slack = math.pow(1 - tightening, 1.5).toDouble();
    final height = (62 + i * 9) * slack;
    final drift = _strandWander(i, progress);
    final mid = a + delta * .53 + normal * (height * .16 * drift);
    final c1 = a + delta * .14 - normal * height * (1 + drift * .2);
    final c2 = a + delta * .36 - normal * height * (.3 + drift * .15);
    final c3 = a + delta * .7 + normal * height * (.4 + drift * .18);
    final c4 = b - delta * .08 + normal * height * .45;
    final strand = Path()
      ..moveTo(a.dx, a.dy)
      ..cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, mid.dx, mid.dy)
      ..cubicTo(c3.dx, c3.dy, c4.dx, c4.dy, b.dx, b.dy);
    if (height > .5) {
      canvas.drawPath(
        strand.shift(Offset(1, 1 + height * .07)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = const Color(0x14000000),
      );
    }
    CraftStitchFrame.sample(strand, progress: 1).paint(
      canvas,
      thread: const Color(0xFF427B6D),
      width: 2,
      compression: .55,
    );
  }
}
