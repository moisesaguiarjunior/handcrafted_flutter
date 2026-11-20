import 'dart:math' as math;

import 'package:flutter/painting.dart';

import 'path_geometry.dart';

/// Prepared irregular matte fibers over a caller-painted substrate.
///
/// Unlike the fixed cotton/suede tiles, scale, density and direction are
/// independent geometry inputs. Length, curl and optional edge fringe extend
/// the finish without changing the substrate. Contrast/colors are paint-only.
/// Prepare outside paint; paths and batches remain private. No image, layer,
/// native mesh, clock or global cache is retained.
class CraftNap {
  /// Copies one closed cut, including holes, and prepares at most 8192 candidate
  /// fibers in four tonal batches. Bounds <=320px per axis, coordinates +/-8192,
  /// shared 32-contour/8192-length path budget. Optional fringe adds at most
  /// 4096 candidates and four paths. Curl uses three quadratics per admitted
  /// strand. More work throws before sampling, including at zero density.
  CraftNap(
    Path outline, {
    this.scale = 1,
    this.density = .7,
    this.direction = -.4,
    this.fiberLength = 1,
    this.curl = 0,
    this.edgeFuzz = 0,
    int seed = 71,
  }) {
    if (!scale.isFinite ||
        scale < .5 ||
        scale > 4 ||
        !density.isFinite ||
        density < 0 ||
        density > 1 ||
        !direction.isFinite ||
        !fiberLength.isFinite ||
        fiberLength < .25 ||
        fiberLength > 6 ||
        !curl.isFinite ||
        curl < 0 ||
        curl > 1 ||
        !edgeFuzz.isFinite ||
        edgeFuzz < 0 ||
        edgeFuzz > 1) {
      throw ArgumentError(
        'Expected scale.5..4, density/curl/edgeFuzz0..1, fiberLength.25..6 and finite direction',
      );
    }
    final metrics = checkedPathMetrics(outline);
    final bounds = outline.getBounds();
    if (metrics.any((m) => !m.isClosed) ||
        bounds.width > 320 ||
        bounds.height > 320 ||
        [
          bounds.left,
          bounds.top,
          bounds.right,
          bounds.bottom,
        ].any((v) => v.abs() > 8192)) {
      throw ArgumentError(
        'Expected closed nap cut <=320px, coordinates +/-8192',
      );
    }
    final count = (bounds.width * bounds.height / (scale * scale) * .18).ceil();
    if (count > 8192) throw ArgumentError('Nap exceeds 8192 candidate fibers');
    final fringeCounts = edgeFuzz == 0
        ? <int>[]
        : [
            for (final metric in metrics)
              (metric.length / (scale * 1.5)).ceil(),
          ];
    if (fringeCounts.fold<int>(0, (a, b) => a + b) > 4096) {
      throw ArgumentError('Nap exceeds 4096 fringe candidates');
    }
    _fringeBatches = edgeFuzz == 0 ? <Path>[] : List.generate(4, (_) => Path());
    _outline = Path.from(outline);
    _origin = bounds.topLeft;
    if (bounds.isEmpty || density == 0) return;
    final orientation = math.atan2(math.sin(direction), math.cos(direction));
    final random = math.Random(seed);
    final clumps = [
      for (var i = 0; i < 5; i++)
        Offset(random.nextDouble(), random.nextDouble()),
    ];
    for (var i = 0; i < count; i++) {
      final x = random.nextDouble(), y = random.nextDouble();
      var field = .35;
      for (final p in clumps) {
        final d = Offset(x, y) - p;
        field += .23 * math.exp(-d.distanceSquared * 24);
      }
      final accepted = random.nextDouble() < density * field.clamp(0, 1);
      final angle = orientation + (random.nextDouble() - .5) * 2.4;
      final length = scale * (.55 + random.nextDouble() * 1.6) * fiberLength;
      final bend = scale * (random.nextDouble() - .5) * .65;
      final tone = random.nextInt(4);
      if (!accepted) continue;
      final p = Offset(x * bounds.width, y * bounds.height);
      final along = Offset(math.cos(angle), math.sin(angle));
      final normal = Offset(-along.dy, along.dx);
      _fiber(_batches[tone], p, along, normal, length, bend);
    }
    for (var m = 0; m < fringeCounts.length; m++) {
      final metric = metrics[m], count = fringeCounts[m];
      for (var i = 0; i < count; i++) {
        final t = metric.getTangentForOffset(metric.length * (i + .3) / count)!;
        final accepted = random.nextDouble() < density;
        var outward = Offset(-t.vector.dy, t.vector.dx);
        if (_outline.contains(t.position + outward * .25)) outward = -outward;
        final angle = (random.nextDouble() - .5) * 1.4;
        final along = outward * math.cos(angle) + t.vector * math.sin(angle);
        final length =
            scale * fiberLength * edgeFuzz * (.45 + random.nextDouble() * .75);
        final bend = (random.nextDouble() - .5) * length * .35;
        final tone = random.nextInt(4);
        if (!accepted) continue;
        _fiber(
          _fringeBatches[tone],
          t.position - _origin - outward * .2,
          along,
          Offset(-along.dy, along.dx),
          length,
          bend,
        );
      }
    }
  }

  void _fiber(
    Path path,
    Offset p,
    Offset along,
    Offset normal,
    double length,
    double bend,
  ) {
    path.moveTo(p.dx, p.dy);
    if (curl == 0) {
      final end = p + along * length;
      final control = p + along * (length * .5) + normal * bend;
      path.quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);
    } else {
      for (var j = 1; j <= 3; j++) {
        final t = j / 3;
        final end =
            p +
            along * (length * t) +
            normal * (math.sin(t * math.pi * 1.7) * curl * length * .28);
        final u = (j - .5) / 3;
        final control =
            p +
            along * (length * u) +
            normal * (math.sin(u * math.pi * 1.7) * curl * length * .28 + bend);
        path.quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);
      }
    }
  }

  /// Fiber dimensions in logical pixels per recipe unit, .5..4.
  final double scale;

  /// Fraction of the fixed seeded candidates admitted, 0..1.
  final double density;

  /// Mean fiber direction, radians in the current canvas coordinate system.
  final double direction;

  /// Length multiplier independent of candidate spacing, .25..6. Default 1
  /// retains the original short-fiber geometry and random sequence.
  final double fiberLength;

  /// Curvature of three connected strand sections, 0..1. Default 0 keeps the
  /// original single quadratic. This is geometry, not animated hair physics.
  final double curl;

  /// Optional outward fringe length fraction, 0..1. Default 0 clips everything
  /// to the cut; positive values intentionally paint beyond outer/hole edges.
  final double edgeFuzz;

  /// Conservative logical paint extent including opt-in fringe and stroke width.
  /// Hosts reserve this margin; it does not expand touch or semantics bounds.
  Rect get paintBounds => edgeFuzz == 0
      ? _outline.getBounds()
      : _outline.getBounds().inflate(scale * (fiberLength * edgeFuzz * 3 + .7));

  late final Path _outline;
  late final Offset _origin;
  final _batches = List.generate(4, (_) => Path());
  late final List<Path> _fringeBatches;

  /// Copied cut; modifying the returned path cannot change prepared fibers.
  Path get outline => Path.from(_outline);

  /// Paints four clipped tonal batches, plus opt-in un-clipped fringe batches,
  /// over the existing opaque or translucent
  /// substrate. Zero contrast paints nothing. Colors retain their supplied alpha;
  /// this matte finish adds no directional specular highlight or bevel.
  void paint(
    Canvas canvas, {
    Color ink = const Color(0xFF443F3A),
    Color highlight = const Color(0xFFFFFFFF),
    double contrast = .6,
  }) {
    if (!contrast.isFinite || contrast < 0 || contrast > 1) {
      throw ArgumentError('Expected nap contrast0..1');
    }
    if (contrast == 0 || density == 0) return;
    canvas.save();
    try {
      canvas.clipPath(_outline);
      canvas.translate(_origin.dx, _origin.dy);
      _paintBatches(canvas, _batches, ink, highlight, contrast);
    } finally {
      canvas.restore();
    }
    if (_fringeBatches.isNotEmpty) {
      canvas.save();
      try {
        canvas.translate(_origin.dx, _origin.dy);
        _paintBatches(canvas, _fringeBatches, ink, highlight, contrast);
      } finally {
        canvas.restore();
      }
    }
  }

  void _paintBatches(
    Canvas canvas,
    List<Path> batches,
    Color ink,
    Color highlight,
    double contrast,
  ) {
    for (var i = 0; i < batches.length; i++) {
      final color = i.isEven ? highlight : ink;
      canvas.drawPath(
        batches[i],
        Paint()
          ..color = color.withValues(
            alpha: color.a * contrast * (i < 2 ? .25 : .14),
          )
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = scale * (i < 2 ? .45 : .65),
      );
    }
  }
}
