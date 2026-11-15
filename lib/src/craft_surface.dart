import 'package:flutter/widgets.dart';

import 'material_textures.dart';
import 'craft_outline.dart';

/// A material background behind native widgets, clipped to its local shape.
///
/// Owns and disposes its texture cache. Changing [seed] replaces that cache.
/// A color/material change does not recreate the child or an animation clock.
/// [shape] is a value recipe; equivalent values retain cached geometry on rebuild.
/// [outline] accepts custom paths and receives current layout size. Use one only.
/// Child layout, semantics, focus and actions are preserved. Shape clipping also
/// clips child input; keep captions outside this surface if they exceed the art.
class CraftSurface extends StatefulWidget {
  /// Creates a surface. Painter bounds/ranges follow [MaterialTextures.paint].
  const CraftSurface({
    super.key,
    required this.material,
    required this.color,
    this.seed = 7,
    this.scale = 1,
    this.strength = 1,
    this.shape,
    this.outline,
    this.child,
  });

  /// Substrate texture independent of the host palette.
  final CraftMaterial material;

  /// Base fill.
  final Color color;

  /// Host-controlled texture seed.
  final int seed;

  /// Logical pixels per texture unit, 0.5..4.
  final double scale;

  /// Grain strength, 0..1.
  final double strength;

  /// Optional value silhouette, cached across equivalent recipe instances.
  final CraftOutline? shape;

  /// Optional silhouette; defaults to local rectangular bounds.
  ///
  /// Retained for custom geometry. Callback identity controls cache invalidation;
  /// keep the callback stable, or prefer [shape] for built-in recipes.
  final Path Function(Size)? outline;

  /// Real widgets painted over the material.
  final Widget? child;

  @override
  State<CraftSurface> createState() => _CraftSurfaceState();
}

class _CraftSurfaceState extends State<CraftSurface> {
  late MaterialTextures _textures = MaterialTextures(seed: widget.seed);
  late _SurfaceGeometry _geometry = _SurfaceGeometry(
    widget.shape,
    widget.outline,
  );

  @override
  void didUpdateWidget(CraftSurface oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.shape != widget.shape ||
        oldWidget.outline != widget.outline) {
      _geometry = _SurfaceGeometry(widget.shape, widget.outline);
    }
    if (oldWidget.seed != widget.seed) {
      _textures.dispose();
      _textures = MaterialTextures(seed: widget.seed);
    }
  }

  @override
  void dispose() {
    _textures.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ClipPath(
    clipper: _SurfaceClipper(_geometry),
    child: CustomPaint(
      painter: _SurfacePainter(_textures, widget, _geometry),
      child: widget.child,
    ),
  );
}

class _SurfaceClipper extends CustomClipper<Path> {
  const _SurfaceClipper(this.geometry);
  final _SurfaceGeometry geometry;
  @override
  Path getClip(Size size) => geometry.pathFor(size);
  @override
  bool shouldReclip(_SurfaceClipper old) => old.geometry != geometry;
}

class _SurfacePainter extends CustomPainter {
  const _SurfacePainter(this.textures, this.surface, this.geometry);
  final _SurfaceGeometry geometry;
  final MaterialTextures textures;
  final CraftSurface surface;
  @override
  void paint(Canvas canvas, Size size) => textures.paint(
    canvas,
    geometry.pathFor(size),
    material: surface.material,
    color: surface.color,
    scale: surface.scale,
    strength: surface.strength,
  );
  @override
  bool shouldRepaint(_SurfacePainter old) =>
      old.textures != textures ||
      old.surface.material != surface.material ||
      old.surface.color != surface.color ||
      old.surface.scale != surface.scale ||
      old.surface.strength != surface.strength ||
      old.geometry != geometry;
}

class _SurfaceGeometry {
  _SurfaceGeometry(this.shape, this.outline) {
    if (shape != null && outline != null) {
      throw ArgumentError('Supply shape or outline, not both');
    }
  }
  final CraftOutline? shape;
  final Path Function(Size)? outline;
  Size? _size;
  Path? _path;
  Path pathFor(Size size) {
    if (_size != size) {
      _path =
          shape?.pathFor(size) ??
          outline?.call(size) ??
          (Path()..addRect(Offset.zero & size));
      _size = size;
    }
    return _path!;
  }
}
