import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

import 'showcase_theme.dart';

/// Original example silhouettes; applications can supply their own closed cut.
enum PillowShape {
  /// Five softly rounded points.
  star,

  /// Thick crescent with a concave inner edge.
  moon,

  /// Eight short rounded rays around a broad center.
  sun,
}

/// Research-informed visual recipes, not physically calibrated textile models.
enum PillowFabric {
  /// Existing plain-woven cotton grain.
  cotton,

  /// Existing matted felt grain.
  felt,

  /// Existing prepared matte nap over a flat substrate, suggesting short plush.
  shortPile,
}

/// Human-readable fabric names without assigning a proprietary textile brand.
String pillowFabricLabel(PillowFabric fabric) => switch (fabric) {
  PillowFabric.cotton => 'Woven cotton',
  PillowFabric.felt => 'Matte felt',
  PillowFabric.shortPile => 'Short-pile study',
};

/// Original cut in a 112px artboard; no artwork or pattern is imported.
Path pillowCut(PillowShape shape) {
  if (shape == PillowShape.moon) {
    return Path()
      ..moveTo(81, 10)
      ..cubicTo(31, -3, 0, 44, 25, 83)
      ..cubicTo(43, 112, 77, 110, 96, 83)
      ..cubicTo(55, 99, 34, 32, 81, 10)
      ..close();
  }
  final rays = shape == PillowShape.star ? 5 : 8;
  final inner = shape == PillowShape.star ? 27.0 : 35.0;
  final points = [
    for (var i = 0; i < rays * 2; i++)
      const Offset(56, 56) +
          Offset(
                math.cos(i * math.pi / rays - math.pi / 2),
                math.sin(i * math.pi / rays - math.pi / 2),
              ) *
              (i.isEven ? 53 : inner),
  ];
  final start = (points.last + points.first) / 2;
  final path = Path()..moveTo(start.dx, start.dy);
  for (var i = 0; i < points.length; i++) {
    final end = (points[i] + points[(i + 1) % points.length]) / 2;
    path.quadraticBezierTo(points[i].dx, points[i].dy, end.dx, end.dy);
  }
  return path..close();
}

/// Example-owned stuffed form composed from the existing cut, volume and seam.
/// Filling changes the prepared height/bevel, not the cut, fabric or light.
final class StuffedShapeGeometry {
  /// Accepts a caller cut under the existing CraftVolume and nap work limits.
  StuffedShapeGeometry(Path cut, {this.filling = .65, this.seed = 71}) {
    if (!filling.isFinite || filling < 0 || filling > 1) {
      throw ArgumentError('Expected filling 0..1');
    }
    volume = CraftVolume(
      cut,
      CraftVolumeProfile.rounded,
      height: .6 + 17.4 * filling,
      bevel: 3 + 11 * filling,
      seed: seed,
    );
    final inset = insetCraftPath(volume.outline, distance: 4.5);
    seam = CraftStitchFrame.sample(
      runningStitchPath(
        inset,
        dash: 2.5,
        gap: 1.8,
        irregularity: .12,
        seed: seed,
      ),
      progress: 1,
    );
    nap = CraftNap(
      volume.outline,
      scale: 1.1,
      density: .8,
      direction: -.8,
      seed: seed,
    );
  }

  /// Visual fullness, 0..1; not fiber mass, pressure or physical density.
  final double filling;

  /// Seed used for existing volume/nap/seam preparation.
  final int seed;

  /// Existing retained volume; relighting does not prepare another field.
  late final CraftVolume volume;

  /// Prepared pale thread follows the inset silhouette, including concavities.
  late final CraftStitchFrame seam;

  /// Prepared existing short fibers; no image resource is owned by the geometry.
  late final CraftNap nap;

  /// Paints shadow, opaque fabric, prepared shading and optional pale sewing.
  /// Caller owns/disposes textures. This is an opaque-board composition, not a
  /// transparent-sprite exporter or cloth/fiberfill simulation.
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
    volume.shadow(canvas, light);
    textures.paint(
      canvas,
      volume.outline,
      material: fabric == PillowFabric.felt
          ? CraftMaterial.felt
          : CraftMaterial.cotton,
      color: color,
      scale: 1.1,
      strength: fabric == PillowFabric.shortPile ? 0 : .65,
    );
    if (fabric == PillowFabric.shortPile) {
      nap.paint(
        canvas,
        ink: Color.lerp(color, DemoPalette.ink, .25)!,
        highlight: Color.lerp(color, DemoPalette.paper, .35)!,
        contrast: .7,
      );
    }
    volume.shade(canvas, light);
    if (sewing) {
      canvas.save();
      canvas.clipPath(volume.outline);
      seam.paint(
        canvas,
        thread: Color.lerp(color, DemoPalette.paper, .8)!,
        width: .65,
        compression: compression,
        pucker: .18,
        light: light.planar,
      );
      canvas.restore();
    }
  }
}

/// Stateful resource owner surrounding decorative paint with native semantics.
class StuffedShape extends StatefulWidget {
  /// Reuses its texture owner across paint-only fabric/light/color changes.
  const StuffedShape({
    super.key,
    required this.shape,
    this.fabric = PillowFabric.cotton,
    this.filling = .65,
    this.color = DemoPalette.ochre,
    this.light,
    this.sewing = true,
    this.compression = .14,
    this.size = 180,
  });

  /// Example silhouette.
  final PillowShape shape;

  /// Fabric is independent of filling and the pattern geometry.
  final PillowFabric fabric;

  /// Prepared visual fullness, 0..1.
  final double filling;

  /// Opaque host-owned fabric tone.
  final Color color;

  /// Explicit incoming light in this unrotated piece's coordinate system.
  final CraftLight? light;

  /// Shows or hides the decorative perimeter stitch.
  final bool sewing;

  /// Paint-only puncture shading, 0..1.
  final double compression;

  /// Display size; source remains 112px and native controls never scale with it.
  final double size;

  @override
  State<StuffedShape> createState() => _StuffedShapeState();
}

class _StuffedShapeState extends State<StuffedShape> {
  final textures = MaterialTextures(seed: 71);
  late StuffedShapeGeometry geometry = _prepare();
  StuffedShapeGeometry _prepare() =>
      StuffedShapeGeometry(pillowCut(widget.shape), filling: widget.filling);
  @override
  void didUpdateWidget(StuffedShape oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.shape != widget.shape ||
        oldWidget.filling != widget.filling) {
      geometry = _prepare();
    }
  }

  @override
  void dispose() {
    textures.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: widget.size,
    child: ExcludeSemantics(
      child: IgnorePointer(
        child: RepaintBoundary(
          key: ValueKey('pillow-${widget.shape.name}'),
          child: CustomPaint(
            painter: _StuffedPainter(geometry, textures, widget),
          ),
        ),
      ),
    ),
  );
}

class _StuffedPainter extends CustomPainter {
  _StuffedPainter(this.geometry, this.textures, this.specimen);
  final StuffedShapeGeometry geometry;
  final MaterialTextures textures;
  final StuffedShape specimen;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 132, size.height / 132);
    canvas.translate(10, 10);
    geometry.paint(
      canvas,
      textures,
      specimen.light ??
          CraftLight(ambient: .75, direct: .4, softness: .6, warmth: .18),
      fabric: specimen.fabric,
      color: specimen.color,
      sewing: specimen.sewing,
      compression: specimen.compression,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_StuffedPainter oldDelegate) =>
      geometry != oldDelegate.geometry ||
      specimen.fabric != oldDelegate.specimen.fabric ||
      specimen.color != oldDelegate.specimen.color ||
      specimen.light != oldDelegate.specimen.light ||
      specimen.sewing != oldDelegate.specimen.sewing ||
      specimen.compression != oldDelegate.specimen.compression;
}
