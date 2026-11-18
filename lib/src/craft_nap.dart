import 'dart:math' as math;

import 'package:flutter/painting.dart';

import 'path_geometry.dart';

/// Prepared short, irregular matte fibers over a caller-painted substrate.
///
/// Unlike the fixed cotton/suede tiles, scale, density and direction are
/// independent geometry inputs. Contrast and colors change without rebuilding.
/// Prepare outside paint; paths and batches remain private. No image, layer,
/// native mesh, clock or global cache is retained.
class CraftNap {
  /// Copies one closed cut, including holes, and prepares at most 8192 candidate
  /// fibers in four tonal batches. Bounds <=320px per axis, coordinates +/-8192,
  /// shared 32-contour/8192-length path budget. More work throws before sampling.
  CraftNap(
    Path outline, {
    this.scale = 1,
    this.density = .7,
    this.direction = -.4,
    int seed = 71,
  }) {
    if (!scale.isFinite ||
        scale < .5 ||
        scale > 4 ||
        !density.isFinite ||
        density < 0 ||
        density > 1 ||
        !direction.isFinite) {
      throw ArgumentError(
        'Expected scale.5..4, density0..1 and finite direction',
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
    _outline = Path.from(outline);
    _origin = bounds.topLeft;
    if (bounds.isEmpty || density == 0) return;
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
      final angle = direction + (random.nextDouble() - .5) * 2.4;
      final length = scale * (.55 + random.nextDouble() * 1.6);
      final bend = scale * (random.nextDouble() - .5) * .65;
      final tone = random.nextInt(4);
      if (!accepted) continue;
      final p = Offset(x * bounds.width, y * bounds.height);
      final along = Offset(math.cos(angle), math.sin(angle));
      final normal = Offset(-along.dy, along.dx);
      final end = p + along * length;
      final control = p + along * (length * .5) + normal * bend;
      _batches[tone]
        ..moveTo(p.dx, p.dy)
        ..quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);
    }
  }

  /// Fiber dimensions in logical pixels per recipe unit, .5..4.
  final double scale;

  /// Fraction of the fixed seeded candidates admitted, 0..1.
  final double density;

  /// Mean fiber direction, radians in the current canvas coordinate system.
  final double direction;
  late final Path _outline;
  late final Offset _origin;
  final _batches = List.generate(4, (_) => Path());

  /// Copied cut; modifying the returned path cannot change prepared fibers.
  Path get outline => Path.from(_outline);

  /// Paints four clipped tonal batches over the existing opaque or translucent
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
      for (var i = 0; i < _batches.length; i++) {
        final color = i.isEven ? highlight : ink;
        canvas.drawPath(
          _batches[i],
          Paint()
            ..color = color.withValues(
              alpha: color.a * contrast * (i < 2 ? .25 : .14),
            )
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeWidth = scale * (i < 2 ? .45 : .65),
        );
      }
    } finally {
      canvas.restore();
    }
  }
}
