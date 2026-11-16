part of 'watercolor.dart';

/// A seeded wet front spreading from [origin] over a supplied paper silhouette.
///
/// This is an art-directed diffusion approximation, not a fluid solver. Progress
/// is explicit, finite and 0..1; no elapsed time or clock is retained. Pigment
/// grain is anchored to the complete outline while the wet front expands. Holes
/// remain unpainted. Completion is exactly [paintWatercolor] with the same recipe.
/// Origin defaults to the bounds center and must lie inside its inclusive bounds;
/// a cutout can mask it until the front reaches paper. Budgets match watercolor.
void paintWatercolorSpread(
  Canvas canvas,
  Path outline, {
  required Color pigment,
  required Color paper,
  required double progress,
  Offset? origin,
  Color? companion,
  int seed = 7,
  double opacity = .55,
  double granulation = .7,
}) {
  final bounds = _validateWatercolor(outline, opacity, granulation).bounds;
  final source = origin ?? bounds.center;
  if (!progress.isFinite ||
      progress < 0 ||
      progress > 1 ||
      !source.dx.isFinite ||
      !source.dy.isFinite ||
      (!bounds.isEmpty &&
          (source.dx < bounds.left ||
              source.dx > bounds.right ||
              source.dy < bounds.top ||
              source.dy > bounds.bottom))) {
    throw ArgumentError(
      'Expected progress 0..1 and finite origin within wash bounds',
    );
  }
  if (progress == 0 || bounds.isEmpty || opacity == 0) return;
  if (progress == 1) {
    paintWatercolor(
      canvas,
      outline,
      pigment: pigment,
      paper: paper,
      companion: companion,
      seed: seed,
      opacity: opacity,
      granulation: granulation,
    );
    return;
  }
  final farthest = [
    bounds.topLeft,
    bounds.topRight,
    bounds.bottomLeft,
    bounds.bottomRight,
  ].map((p) => (p - source).distance).reduce(math.max);
  // Lobes retain their phases as they grow; the final radius covers the paper.
  final front = _wetFront(source, farthest, progress, seed);
  final unit = math.min(bounds.width, bounds.height);
  canvas.save();
  canvas.clipPath(outline);
  // Soft low-density fringe, then denser pigment deposited behind the front.
  for (var layer = 4; layer >= 1; layer--) {
    canvas.drawPath(
      front,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = unit * .012 * layer
        ..color = pigment.withValues(
          alpha: pigment.a * opacity * (1 - progress) * .07,
        ),
    );
  }
  canvas.save();
  canvas.clipPath(front);
  paintWatercolor(
    canvas,
    outline,
    pigment: pigment,
    paper: paper,
    companion: companion,
    seed: seed,
    opacity: opacity * (.72 + .28 * progress),
    granulation: granulation,
  );
  canvas.restore();
  canvas.restore();
}

// Direction-dependent arrival times produce an elongated first contact and
// advancing lobes rather than scaling one circular aperture. Fixed 96 stations.
Path _wetFront(Offset origin, double reach, double progress, int seed) {
  final points = <Offset>[];
  final phase = (seed & 0xffff) * .73;
  for (var i = 0; i < 96; i++) {
    final angle = i * math.pi * 2 / 96;
    final waves =
        math.sin(angle * 3 + phase) * .55 +
        math.sin(angle * 7 - phase * .7) * .3 +
        math.cos(angle * 13 + phase) * .15;
    final delay = .1 * (waves + 1) / 2;
    final arrival = ((progress - delay) / (1 - delay)).clamp(0.0, 1.0);
    final speed = .65 + .55 * (1 + math.sin(angle * 2 + phase)) / 2;
    final nib =
        reach *
        .04 /
        math.sqrt(
          math.pow(math.cos(angle - .4) / 1.8, 2) +
              math.pow(math.sin(angle - .4) / .65, 2),
        );
    final radius =
        nib * math.min(1, progress * 35) +
        reach * (1.09 + .09 * waves) * math.pow(arrival, speed);
    points.add(origin + Offset(math.cos(angle), math.sin(angle)) * radius);
  }
  final first = (points.last + points.first) / 2;
  final path = Path()..moveTo(first.dx, first.dy);
  for (var i = 0; i < points.length; i++) {
    final end = (points[i] + points[(i + 1) % points.length]) / 2;
    path.quadraticBezierTo(points[i].dx, points[i].dy, end.dx, end.dy);
  }
  return path..close();
}
