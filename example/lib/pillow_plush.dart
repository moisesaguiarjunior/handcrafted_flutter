part of 'stuffed_shapes.dart';

/// Two example finishes on the same padded body, not measured textile models.
enum PlushFabric {
  /// Fine, mostly aligned short fibers.
  shortPile,

  /// Small irregular curled clusters.
  sherpa,
}

/// Retains the canonical padded volume and original seeded textile paths.
final class PlushPillowGeometry {
  /// Uses the same validated closed cut and volume budget as CraftVolume.
  PlushPillowGeometry(Path cut, {this.filling = .85, int seed = 71}) {
    if (!filling.isFinite || filling < 0 || filling > 1) {
      throw ArgumentError('Expected filling 0..1');
    }
    volume = CraftVolume(
      cut,
      CraftVolumeProfile.padded,
      height: 1 + 23 * filling,
      seed: seed,
    );
    final outline = volume.outline;
    nap = CraftNap(outline, scale: .65, density: 1, seed: seed);
    final bounds = volume.bounds;
    final candidates = (bounds.width * bounds.height * .5).ceil();
    if (candidates > 8192) {
      throw ArgumentError('Plush study exceeds 8192 tuft candidates');
    }
    final random = math.Random(seed);
    for (var i = 0; i < candidates; i++) {
      final p = Offset(
        bounds.left + random.nextDouble() * bounds.width,
        bounds.top + random.nextDouble() * bounds.height,
      );
      final radius = .3 + random.nextDouble() * .55;
      if (!outline.contains(p)) continue;
      final tuft = _tufts[i % _tufts.length];
      // Small overlapping lobes, not white outlined loops or a printed motif.
      for (var j = 0; j < 3; j++) {
        final center =
            p +
            Offset(
              (random.nextDouble() - .5) * radius,
              (random.nextDouble() - .5) * radius,
            );
        tuft.addOval(
          Rect.fromCenter(
            center: center,
            width: radius * (1.1 + random.nextDouble() * .5),
            height: radius * (1 + random.nextDouble() * .6),
          ),
        );
      }
    }
    for (final metric in outline.computeMetrics()) {
      final count = (metric.length / .7).ceil();
      for (var i = 0; i < count; i++) {
        final tangent = metric.getTangentForOffset(metric.length * i / count)!;
        final point = tangent.position;
        var normal = Offset(-tangent.vector.dy, tangent.vector.dx);
        if (outline.contains(point + normal)) normal = -normal;
        final tip = point + normal * (.2 + random.nextDouble() * .5);
        final end = point + tangent.vector * .35;
        _fuzz
          ..moveTo(point.dx, point.dy)
          ..quadraticBezierTo(tip.dx, tip.dy, end.dx, end.dy);
      }
    }
    seam = CraftStitchFrame.sample(
      runningStitchPath(
        insetCraftPath(outline, distance: 1.2),
        dash: 1.7,
        gap: 1.4,
        irregularity: .18,
        seed: seed,
      ),
      progress: 1,
    );
  }

  /// Visual padding amount; no pressure, stretch or stuffing mass is simulated.
  final double filling;

  /// Shared retained normals, mesh and light/shadow implementation.
  late final CraftVolume volume;

  /// Existing fine matte fibers, reused for both finishes.
  late final CraftNap nap;

  /// Prepared faint junction detail, independent of the textile.
  late final CraftStitchFrame seam;
  final _tufts = List.generate(4, (_) => Path());
  final _fuzz = Path();

  /// Paints on an opaque board. No images, clocks or native resources are held.
  void paint(
    Canvas canvas,
    CraftLight light, {
    required PlushFabric fabric,
    required Color color,
    bool sewing = true,
  }) {
    if (color.a != 1) throw ArgumentError('Expected opaque plush color');
    volume.shadow(canvas, light);
    if (fabric == PlushFabric.sherpa) {
      canvas.drawPath(
        _fuzz,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = .35
          ..strokeCap = StrokeCap.round
          ..color = Color.lerp(color, Colors.white, .08)!,
      );
    }
    canvas.save();
    try {
      final outline = volume.outline;
      canvas.clipPath(outline);
      canvas.drawPath(outline, Paint()..color = color);
      if (fabric == PlushFabric.sherpa) {
        final length = math.sqrt(
          light.x * light.x + light.y * light.y + light.z * light.z,
        );
        final directional =
            light.direct / (light.ambient + light.direct + 1e-9);
        final glint =
            Offset(light.x / length, light.y / length) * (.28 * directional);
        for (var i = 0; i < _tufts.length; i++) {
          final path = _tufts[i];
          canvas.drawPath(
            path,
            Paint()
              ..color = Color.lerp(
                color,
                DemoPalette.ink,
                .24,
              )!.withValues(alpha: .48),
          );
          canvas.drawPath(
            path.shift(glint),
            Paint()
              ..color = Color.lerp(
                color,
                Colors.white,
                .6,
              )!.withValues(alpha: .5),
          );
        }
      }
      nap.paint(
        canvas,
        ink: Color.lerp(color, DemoPalette.ink, .084)!,
        highlight: Color.lerp(color, Colors.white, .3)!,
        contrast: fabric == PlushFabric.sherpa ? .32 : .75,
      );
      volume.shade(canvas, light);
      if (sewing) {
        // The seam lives at the junction, without a dark puncture outline.
        seam.paint(
          canvas,
          thread: Color.lerp(color, Colors.white, .065)!,
          width: .5,
          compression: 0,
          pucker: 0,
          light: light.planar,
        );
      }
    } finally {
      canvas.restore();
    }
  }
}

/// Separate opt-in specimen: the approved original stays untouched.
class PlushPillow extends StatefulWidget {
  /// All geometry inputs are explicit; relighting/fabric changes only repaint.
  const PlushPillow({
    super.key,
    this.shape = PillowShape.star,
    this.fabric = PlushFabric.shortPile,
    this.filling = .85,
    this.color = const Color(0xFF9FC5DC),
    this.light,
    this.size = 230,
    this.sewing = false,
  });

  /// Original example silhouette.
  final PillowShape shape;

  /// Independent prepared-finish selection.
  final PlushFabric fabric;

  /// Padding amount, 0..1.
  final double filling;

  /// Opaque substrate tone.
  final Color color;

  /// Incoming local light, no scene clock.
  final CraftLight? light;

  /// Display area, independent of native text and controls.
  final double size;

  /// Optional subtle seam at the perimeter junction.
  final bool sewing;

  @override
  State<PlushPillow> createState() => _PlushPillowState();
}

class _PlushPillowState extends State<PlushPillow> {
  late PlushPillowGeometry geometry = _prepare();
  PlushPillowGeometry _prepare() =>
      PlushPillowGeometry(pillowCut(widget.shape), filling: widget.filling);
  @override
  void didUpdateWidget(PlushPillow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.shape != widget.shape ||
        oldWidget.filling != widget.filling) {
      geometry = _prepare();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.size.isFinite || widget.size <= 0 || widget.color.a != 1) {
      throw ArgumentError('Expected positive finite size and opaque fabric');
    }
    return ExcludeSemantics(
      child: IgnorePointer(
        child: RepaintBoundary(
          child: SizedBox.square(
            dimension: widget.size,
            child: CustomPaint(painter: _PlushPillowPainter(geometry, widget)),
          ),
        ),
      ),
    );
  }
}

class _PlushPillowPainter extends CustomPainter {
  _PlushPillowPainter(this.geometry, this.specimen);
  final PlushPillowGeometry geometry;
  final PlushPillow specimen;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    try {
      canvas.scale(size.width / 132, size.height / 132);
      canvas.translate(10, 10);
      geometry.paint(
        canvas,
        specimen.light ?? plushPillowLight(),
        fabric: specimen.fabric,
        color: specimen.color,
        sewing: specimen.sewing,
      );
    } finally {
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_PlushPillowPainter oldDelegate) =>
      geometry != oldDelegate.geometry ||
      specimen.fabric != oldDelegate.specimen.fabric ||
      specimen.color != oldDelegate.specimen.color ||
      specimen.light != oldDelegate.specimen.light ||
      specimen.sewing != oldDelegate.specimen.sewing;
}

/// Shared light for controlled fabric comparisons and the native playground.
CraftLight plushPillowLight({bool fromRight = false}) => CraftLight(
  x: fromRight ? .85 : -.85,
  y: -.6,
  z: .7,
  ambient: .58,
  direct: .48,
  softness: .45,
  warmth: .12,
);
