part of 'stuffed_shapes.dart';

/// Example-owned rounded side panel in a fixed oblique 2.5D projection.
/// Reuses the original pattern and existing bounded volume/fiber/thread painters.
/// This is not a rotatable mesh, physical cloth, or alpha-sprite renderer.
final class PillowDepthGeometry {
  /// Samples at most 320 contour stations and unions sixteen tapered sections.
  /// A 64-probe local-coverage heuristic tapers thin tips; four fixed smoothing
  /// passes avoid abrupt changes. Existing volume/nap limits still apply to the
  /// larger envelope; this does not guarantee support for every maximum cut.
  PillowDepthGeometry(this.front) {
    final cut = front.volume.outline;
    final center = cut.getBounds().center;
    final amount = .8 + 25 * front.filling;
    final offset = Offset(amount * .23, amount);
    final contours = <List<Offset>>[];
    var stations = 0;
    for (final metric in cut.computeMetrics()) {
      final count = math.max(3, (metric.length / 3).ceil());
      stations += count;
      if (stations > 320) {
        throw ArgumentError('Depth sweep exceeds 320 stations');
      }
      contours.add([
        for (var i = 0; i < count; i++)
          metric.getTangentForOffset(metric.length * i / count)!.position,
      ]);
    }
    final weights = <List<double>>[];
    for (final points in contours) {
      var values = [
        for (final p in points)
          () {
            var covered = 0;
            for (var i = 0; i < 64; i++) {
              final angle = i * math.pi / 32;
              if (cut.contains(
                p + Offset(math.cos(angle), math.sin(angle)) * 7,
              )) {
                covered++;
              }
            }
            final ratio = (covered / 32).clamp(.08, 1.0);
            return ratio * ratio;
          }(),
      ];
      for (var pass = 0; pass < 4; pass++) {
        values = [
          for (var i = 0; i < values.length; i++)
            (values[(i + values.length - 1) % values.length] +
                    2 * values[i] +
                    values[(i + 1) % values.length]) /
                4,
        ];
      }
      weights.add(values);
    }
    Offset station(Offset point, double t, double weight) {
      final scale =
          1 + .075 * front.filling * math.sin(math.pi * t) * weight - .06 * t;
      return center + (point - center) * scale + offset * (t * weight);
    }

    Path section(double t) {
      final result = Path()..fillType = cut.fillType;
      for (var c = 0; c < contours.length; c++) {
        result.addPolygon([
          for (var i = 0; i < contours[c].length; i++)
            station(contours[c][i], t, weights[c][i]),
        ], true);
      }
      return result;
    }

    var hull = Path.from(cut);
    for (var sectionIndex = 1; sectionIndex <= 16; sectionIndex++) {
      hull = Path.combine(
        PathOperation.union,
        hull,
        section(sectionIndex / 16),
      );
    }
    side = CraftVolume(
      hull,
      CraftVolumeProfile.rounded,
      height: 1 + 23 * front.filling,
      bevel: 8 + 16 * front.filling,
      seed: front.seed,
    );
    _visibleSide = Path.combine(PathOperation.difference, side.outline, cut);
    nap = CraftNap(
      side.outline,
      scale: 1.1,
      density: .8,
      direction: -.8,
      seed: front.seed,
    );
    join = CraftStitchFrame.sample(
      runningStitchPath(
        section(.5),
        dash: 2.5,
        gap: 1.8,
        irregularity: .12,
        seed: front.seed,
      ),
      progress: 1,
    );
  }

  /// Original recipe supplying the cut, filling and seed.
  final StuffedShapeGeometry front;

  /// Prepared projected rounded side envelope.
  late final CraftVolume side;

  /// Existing prepared nap on the larger projected envelope.
  late final CraftNap nap;

  /// Sewing along the mid-section; the opaque front hides its far side.
  late final CraftStitchFrame join;
  late final Path _visibleSide;

  /// Paints one continuous rounded cloth envelope and its visible mid-seam.
  /// The original front projection occludes the far side of that seam.
  void paint(
    Canvas canvas,
    MaterialTextures textures,
    CraftLight light, {
    required PillowFabric fabric,
    required Color color,
    bool sewing = true,
    double compression = .14,
  }) {
    if (color.a != 1 ||
        !compression.isFinite ||
        compression < 0 ||
        compression > 1) {
      throw ArgumentError('Expected opaque fabric and compression 0..1');
    }
    side.shadow(canvas, light);
    _paintPillowFabric(canvas, textures, side.outline, nap, fabric, color);
    side.shade(canvas, light);
    if (sewing) {
      canvas.save();
      try {
        canvas.clipPath(_visibleSide);
        join.paint(
          canvas,
          thread: Color.lerp(color, DemoPalette.paper, .8)!,
          width: .65,
          compression: compression,
          pucker: .12,
          light: light.planar,
        );
      } finally {
        canvas.restore();
      }
    }
  }
}
