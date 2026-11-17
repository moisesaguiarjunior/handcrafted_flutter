import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

/// Original layered motifs for relief studies, drawn in a 200x200 design box.
///
/// Each motif is several cuts, so pressing or raising it leaves more than one
/// edge: a main body, finer grooves and counter-relief details. All geometry
/// is example-owned; the package supplies only [paintCraftRelief].
enum ReliefMotif {
  /// A fan-shaped ginkgo leaf with radiating veins.
  ginkgo,

  /// A hot-air balloon with gore seams, ropes and a basket.
  balloon,

  /// Two peaks with snow caps under a sun.
  mountains,

  /// A whale with throat grooves and a small spout.
  whale,

  /// A small house with a heart window and a tree.
  house,

  /// A snail whose shell spirals inward.
  snail,
}

/// One cut of a motif. [counter] reverses the caller's relief kind.
typedef _Cut = ({Path path, bool counter, double depth, double fill});

/// Paints [motif] fitted and centered in [bounds].
///
/// [kind] applies to the main body; counter cuts use the opposite kind.
void paintReliefMotif(
  Canvas canvas,
  ReliefMotif motif,
  Rect bounds, {
  CraftReliefKind kind = CraftReliefKind.inset,
  Offset light = const Offset(-1, -1),
  double strength = .9,
  double depthScale = 1,
}) {
  if (bounds.isEmpty) return;
  final scale = math.min(bounds.width, bounds.height) / 200;
  final transform = Matrix4.identity()
    ..translateByDouble(
      bounds.center.dx - 100 * scale,
      bounds.center.dy - 100 * scale,
      0,
      1,
    )
    ..scaleByDouble(scale, scale, 1, 1);
  final opposite = kind == CraftReliefKind.inset
      ? CraftReliefKind.raised
      : CraftReliefKind.inset;
  for (final cut in _cuts[motif]!) {
    final depth = (cut.depth * depthScale * scale.clamp(.6, 1.6)).clamp(
      .3,
      8.0,
    );
    final effective = cut.counter ? opposite : kind;
    // Raised cuts catch light; pressed cuts sit in shade. The tone keeps edges
    // parallel to the light readable, where directional rims fade out.
    final tone = effective == CraftReliefKind.raised
        ? Color.fromRGBO(255, 255, 255, cut.fill)
        : Color.fromRGBO(30, 16, 8, cut.fill * 1.1);
    paintCraftRelief(
      canvas,
      cut.path.transform(transform.storage),
      kind: cut.counter ? opposite : kind,
      depth: depth,
      strength: strength,
      light: light,
      fill: cut.fill == 0 ? null : tone,
    );
  }
}

final Map<ReliefMotif, List<_Cut>> _cuts = {
  for (final motif in ReliefMotif.values) motif: _build(motif),
};

_Cut _cut(
  Path path, {
  bool counter = false,
  double depth = 2.4,
  double fill = 0,
}) => (path: path, counter: counter, depth: depth, fill: fill);

/// A thin lens along a quadratic curve, tapering to points at both ends.
Path _sliver(Offset from, Offset to, {double bend = 0, double width = 2.4}) {
  final mid = Offset.lerp(from, to, .5)!;
  final along = to - from;
  final normal = Offset(-along.dy, along.dx) / math.max(along.distance, 1e-6);
  final control = mid + normal * bend;
  Offset at(double t) =>
      from * ((1 - t) * (1 - t)) + control * (2 * t * (1 - t)) + to * (t * t);
  const steps = 18;
  final left = <Offset>[], right = <Offset>[];
  for (var i = 0; i <= steps; i++) {
    final t = i / steps;
    final tangent = at(math.min(1, t + .01)) - at(math.max(0, t - .01));
    final n =
        Offset(-tangent.dy, tangent.dx) / math.max(tangent.distance, 1e-6);
    final half = width / 2 * math.sin(math.pi * t);
    left.add(at(t) + n * half);
    right.add(at(t) - n * half);
  }
  final path = Path()..moveTo(left.first.dx, left.first.dy);
  for (final p in left.skip(1)) {
    path.lineTo(p.dx, p.dy);
  }
  for (final p in right.reversed.skip(1)) {
    path.lineTo(p.dx, p.dy);
  }
  return path..close();
}

Path _poly(List<Offset> points) => Path()..addPolygon(points, true);

Path _circle(Offset center, double radius) =>
    Path()..addOval(Rect.fromCircle(center: center, radius: radius));

Path _cloud(Offset c, double s) {
  var cloud = Path();
  for (final (dx, dy, r) in const [
    (-.6, .15, .42),
    (-.1, -.2, .58),
    (.48, 0.0, .46),
    (0.0, .25, .45),
  ]) {
    cloud = Path.combine(
      PathOperation.union,
      cloud,
      _circle(c + Offset(dx * s, dy * s), r * s),
    );
  }
  return cloud;
}

List<_Cut> _build(ReliefMotif motif) => switch (motif) {
  ReliefMotif.ginkgo => _ginkgo(),
  ReliefMotif.balloon => _balloon(),
  ReliefMotif.mountains => _mountains(),
  ReliefMotif.whale => _whale(),
  ReliefMotif.house => _house(),
  ReliefMotif.snail => _snail(),
};

List<_Cut> _ginkgo() {
  const base = Offset(100, 132);
  const center = Offset(100, 150);
  double radius(double a) {
    final fromTop = (a + math.pi / 2) / (math.pi / 180);
    final notch = math.exp(-math.pow(fromTop / 6, 2)) * 34;
    return 100 + math.sin(a * 18) * 2.4 - notch;
  }

  Offset rim(double a) => center + Offset(math.cos(a), math.sin(a)) * radius(a);
  const start = -math.pi * .8, end = -math.pi * .2;
  final blade = Path()..moveTo(base.dx, base.dy);
  final first = rim(start);
  blade.quadraticBezierTo(base.dx - 14, base.dy - 18, first.dx, first.dy);
  for (var i = 1; i <= 90; i++) {
    final p = rim(start + (end - start) * i / 90);
    blade.lineTo(p.dx, p.dy);
  }
  blade
    ..quadraticBezierTo(base.dx + 14, base.dy - 18, base.dx, base.dy)
    ..close();
  return [
    _cut(_sliver(base, const Offset(84, 196), bend: -8, width: 5), depth: 1.3),
    _cut(blade, depth: 3.2, fill: .16),
    for (var i = 0; i < 17; i++)
      if ((i - 8).abs() > 0)
        _cut(
          _sliver(
            base + const Offset(0, -6),
            rim(start + .1 + (end - start - .2) * i / 16) +
                (base - rim(start + .1 + (end - start - .2) * i / 16)) * .1,
            bend: (i - 8) * .6,
            width: 2,
          ),
          depth: 1.1,
        ),
  ];
}

List<_Cut> _balloon() {
  final envelope = Path()
    ..moveTo(88, 142)
    ..cubicTo(36, 112, 40, 18, 100, 16)
    ..cubicTo(160, 18, 164, 112, 112, 142)
    ..close();
  return [
    _cut(_cloud(const Offset(38, 158), 20), depth: 1.6),
    _cut(_cloud(const Offset(166, 54), 15), depth: 1.4),
    _cut(envelope, depth: 3.4, fill: .16),
    for (final (end, bend) in const [
      (Offset(92, 141), 34.0),
      (Offset(97, 141), 12.0),
      (Offset(103, 141), -12.0),
      (Offset(108, 141), -34.0),
    ])
      _cut(
        _sliver(const Offset(100, 18), end, bend: bend, width: 3),
        counter: true,
        depth: 1.2,
      ),
    _cut(
      _sliver(const Offset(89, 143), const Offset(92, 166), width: 2),
      depth: 1,
    ),
    _cut(
      _sliver(const Offset(111, 143), const Offset(108, 166), width: 2),
      depth: 1,
    ),
    _cut(
      Path()..addRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(88, 164, 24, 19),
          const Radius.circular(3),
        ),
      ),
      depth: 2.4,
    ),
    _cut(
      _sliver(const Offset(90, 172), const Offset(110, 172), width: 1.6),
      counter: true,
      depth: .8,
    ),
  ];
}

List<_Cut> _mountains() {
  Path cap(Offset apex, Offset left, Offset right) {
    final l = Offset.lerp(apex, left, .32)!, r = Offset.lerp(apex, right, .32)!;
    return _poly([
      apex,
      r,
      Offset.lerp(l, r, .78)! + const Offset(0, -7),
      Offset.lerp(l, r, .55)! + const Offset(0, 4),
      Offset.lerp(l, r, .3)! + const Offset(0, -6),
      l,
    ]);
  }

  const backApex = Offset(78, 58), frontApex = Offset(136, 86);
  const backLeft = Offset(6, 168), backRight = Offset(152, 168);
  const frontLeft = Offset(70, 168), frontRight = Offset(196, 168);
  return [
    _cut(_circle(const Offset(150, 46), 20), depth: 2.6, fill: .16),
    _cut(_poly([backApex, backRight, backLeft]), depth: 3, fill: .1),
    _cut(cap(backApex, backLeft, backRight), counter: true, depth: 1.4),
    _cut(_poly([frontApex, frontRight, frontLeft]), depth: 3.4, fill: .18),
    _cut(cap(frontApex, frontLeft, frontRight), counter: true, depth: 1.4),
    for (final (y, from, to) in const [
      (180.0, 30.0, 120.0),
      (188.0, 70.0, 176.0),
    ])
      _cut(_sliver(Offset(from, y), Offset(to, y), bend: 3, width: 3)),
  ];
}

List<_Cut> _whale() {
  final body = Path()
    ..moveTo(18, 112)
    ..cubicTo(22, 64, 108, 52, 148, 92)
    ..cubicTo(156, 100, 166, 100, 172, 92)
    ..lineTo(176, 104)
    ..cubicTo(150, 140, 64, 150, 18, 112)
    ..close();
  final fluke = Path()
    ..moveTo(168, 96)
    ..cubicTo(176, 78, 186, 64, 198, 60)
    ..cubicTo(194, 76, 188, 86, 180, 94)
    ..cubicTo(190, 96, 196, 104, 198, 116)
    ..cubicTo(186, 112, 176, 108, 168, 100)
    ..close();
  return [
    _cut(fluke, depth: 2.8, fill: .12),
    _cut(body, depth: 3.4, fill: .16),
    _cut(_circle(const Offset(48, 98), 4), counter: true, depth: 1.2),
    for (var i = 0; i < 4; i++)
      _cut(
        _sliver(
          Offset(26 + i * 4.0, 116 + i * 4.0),
          Offset(96 + i * 6.0, 126 + i * 5.0),
          bend: -4,
          width: 2.2,
        ),
        counter: true,
        depth: 1,
      ),
    _cut(
      _sliver(const Offset(58, 62), const Offset(40, 34), bend: 6, width: 4),
      depth: 1.6,
    ),
    _cut(
      _sliver(const Offset(60, 62), const Offset(76, 34), bend: -6, width: 4),
      depth: 1.6,
    ),
    for (final (from, to) in const [
      (Offset(10, 170), Offset(70, 170)),
      (Offset(84, 170), Offset(190, 170)),
      (Offset(40, 182), Offset(150, 182)),
    ])
      _cut(_sliver(from, to, bend: 4, width: 3), depth: 1.2),
  ];
}

List<_Cut> _house() {
  Path heart(Offset c, double s) => Path()
    ..moveTo(c.dx, c.dy + s * .9)
    ..cubicTo(
      c.dx - s * 1.4,
      c.dy,
      c.dx - s * .7,
      c.dy - s * 1.1,
      c.dx,
      c.dy - s * .35,
    )
    ..cubicTo(
      c.dx + s * .7,
      c.dy - s * 1.1,
      c.dx + s * 1.4,
      c.dy,
      c.dx,
      c.dy + s * .9,
    )
    ..close();
  return [
    _cut(Path()..addRect(const Rect.fromLTWH(112, 44, 14, 34)), depth: 2.2),
    _cut(
      Path()..addRect(const Rect.fromLTWH(46, 96, 92, 76)),
      depth: 3,
      fill: .14,
    ),
    _cut(
      _poly(const [Offset(34, 100), Offset(92, 40), Offset(150, 100)]),
      depth: 3.4,
      fill: .2,
    ),
    _cut(heart(const Offset(70, 124), 11), counter: true, depth: 1.6),
    _cut(
      Path()
        ..moveTo(98, 172)
        ..lineTo(98, 140)
        ..arcToPoint(const Offset(122, 140), radius: const Radius.circular(12))
        ..lineTo(122, 172)
        ..close(),
      counter: true,
      depth: 1.8,
    ),
    _cut(
      _sliver(const Offset(170, 172), const Offset(168, 128), width: 5),
      depth: 1.6,
    ),
    _cut(_circle(const Offset(168, 112), 20), depth: 2.6, fill: .14),
    _cut(_sliver(const Offset(14, 178), const Offset(192, 178), width: 4)),
  ];
}

List<_Cut> _snail() {
  const c = Offset(116, 104);
  final spiral = <Offset>[];
  for (var i = 0; i <= 120; i++) {
    final t = i / 120;
    final angle = t * math.pi * 4.2 + math.pi * .2;
    final r = 40 * (1 - t) + 4;
    spiral.add(c + Offset(math.cos(angle), math.sin(angle)) * r);
  }
  // A tapering ribbon along the spiral, as one closed cut.
  final left = <Offset>[], right = <Offset>[];
  for (var i = 0; i < spiral.length; i++) {
    final a = spiral[math.max(0, i - 1)],
        b = spiral[math.min(spiral.length - 1, i + 1)];
    final d = b - a;
    final n = Offset(-d.dy, d.dx) / math.max(d.distance, 1e-6);
    final half = 2.2 * (1 - i / spiral.length) + .4;
    left.add(spiral[i] + n * half);
    right.add(spiral[i] - n * half);
  }
  final ribbon = _poly([...left, ...right.reversed]);
  final body = Path()
    ..moveTo(26, 152)
    ..cubicTo(30, 132, 40, 112, 50, 104)
    ..cubicTo(60, 98, 66, 110, 64, 128)
    ..cubicTo(70, 140, 120, 142, 184, 146)
    ..cubicTo(190, 150, 188, 158, 180, 160)
    ..lineTo(36, 162)
    ..cubicTo(28, 162, 24, 158, 26, 152)
    ..close();
  return [
    _cut(
      _sliver(const Offset(50, 104), const Offset(38, 70), bend: 5, width: 3),
      depth: 1.4,
    ),
    _cut(
      _sliver(const Offset(57, 104), const Offset(62, 68), bend: -5, width: 3),
      depth: 1.4,
    ),
    _cut(_circle(const Offset(38, 70), 4), depth: 1.6),
    _cut(_circle(const Offset(62, 68), 4), depth: 1.6),
    _cut(body, depth: 2.8, fill: .1),
    _cut(_circle(c, 46), depth: 3.6, fill: .16),
    _cut(ribbon, counter: true, depth: 1.3),
    _cut(_circle(const Offset(48, 118), 2.6), counter: true, depth: 1),
  ];
}
