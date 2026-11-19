import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

import 'showcase_theme.dart';

/// Example-local composition recipes, not new package material families.
enum SurfaceRecipe {
  /// Existing layered pigment with its default contour contract.
  watercolor,

  /// Quiet field with a native alpha feather.
  featheredWash,

  /// Example-local prepared directional short fibers.
  fibers,

  /// Repeating axis-aligned printed checks.
  checker,

  /// The same repeating print rotated in source space.
  diamonds,
}

/// Retained source-space decoration. Cropping never changes the source domain.
/// Owns both its picture and its material tiles; dispose when the scene ends.
final class SurfaceProof {
  /// Records a bounded synthetic scene with explicit seed and recipe values.
  SurfaceProof({
    required this.recipe,
    this.domain = const Rect.fromLTWH(0, 0, 960, 1728),
    this.seed = 23,
    this.phase = Offset.zero,
    this.substrate,
    this.grainStrength = .28,
    this.printColor = DemoPalette.sage,
    this.coreOpacity = .28,
    this.paintSubstrate = true,
    this.feather = 24,
    this.tightFeather = false,
    this.irregular = true,
    this.fiberAngle = math.pi / 2,
    this.fiberLength = 22,
    this.fiberStrength = .12,
    this.fiberDensity = 80,
  }) {
    if (![
          domain.left,
          domain.top,
          domain.right,
          domain.bottom,
        ].every((v) => v.isFinite && v.abs() <= 8192) ||
        domain.isEmpty ||
        domain.width > 2048 ||
        domain.height > 2048 ||
        !phase.dx.isFinite ||
        !phase.dy.isFinite ||
        phase.dx.abs() > 4096 ||
        phase.dy.abs() > 4096 ||
        !grainStrength.isFinite ||
        grainStrength < 0 ||
        grainStrength > 1 ||
        !coreOpacity.isFinite ||
        coreOpacity < 0 ||
        coreOpacity > 1 ||
        !feather.isFinite ||
        feather < 0 ||
        feather > 64 ||
        !fiberAngle.isFinite ||
        !fiberLength.isFinite ||
        fiberLength < 2 ||
        fiberLength > 64 ||
        !fiberDensity.isFinite ||
        fiberDensity < 0 ||
        fiberDensity > 200 ||
        !fiberStrength.isFinite ||
        fiberStrength < 0 ||
        fiberStrength > 1) {
      throw ArgumentError('Expected a bounded finite domain and recipe values');
    }
    _textures = MaterialTextures(seed: seed);
    final recorder = ui.PictureRecorder();
    try {
      _record(Canvas(recorder));
      _picture = recorder.endRecording();
    } catch (_) {
      recorder.endRecording().dispose();
      _textures.dispose();
      rethrow;
    }
  }

  /// Fixed source-space bounds (coordinates within ±8192), never the viewport.
  final Rect domain;

  /// Recipe selected by the host, without a clock.
  final SurfaceRecipe recipe;

  /// Random geometry seed; scrolling does not replace it.
  final int seed;

  /// Printed pattern offset (±4096px), independent of scrolling/substrate color.
  final Offset phase;

  /// Optional material override: the same print can decorate paper or cloth.
  final CraftMaterial? substrate;

  /// Existing material grain strength, independently of printed ink.
  final double grainStrength;

  /// Printed ink, applied only to pattern geometry, not the substrate/content.
  final Color printColor;

  /// Nearly uniform wash field alpha, separate from edge transition width.
  final double coreOpacity;

  /// Omits the paper fill for transparent-mask evidence.
  final bool paintSubstrate;

  /// Gaussian transition sigma, in source logical pixels; zero means hard edge.
  final double feather;

  /// Applies the same Gaussian alpha mask twice for a tighter transition curve.
  final bool tightFeather;

  /// Uses the existing seeded pigment silhouette rather than an ellipse.
  final bool irregular;

  /// Mean fiber direction in radians, independent of the source bounds.
  final double fiberAngle;

  /// Mean fiber length in source logical pixels, with seeded variation.
  final double fiberLength;

  /// Fiber mark alpha multiplier, separate from substrate color.
  final double fiberStrength;

  /// Fibers per 10,000 source square pixels, capped at 4096 per scene.
  final double fiberDensity;

  late final MaterialTextures _textures;
  late final ui.Picture _picture;
  bool _disposed = false;

  void _record(Canvas canvas) {
    final outline = Path()..addRect(domain);
    if (paintSubstrate) {
      _textures.paint(
        canvas,
        outline,
        material:
            substrate ??
            switch (recipe) {
              SurfaceRecipe.checker ||
              SurfaceRecipe.diamonds => CraftMaterial.cotton,
              _ => CraftMaterial.paper,
            },
        color: DemoPalette.paper,
        strength: recipe == SurfaceRecipe.fibers ? 0 : grainStrength,
      );
    }
    switch (recipe) {
      case SurfaceRecipe.watercolor:
        paintWatercolor(
          canvas,
          outline,
          pigment: DemoPalette.indigo,
          paper: paintSubstrate ? DemoPalette.paper : Colors.transparent,
          companion: DemoPalette.sage,
          seed: seed,
          opacity: .4,
          granulation: .15,
        );
      case SurfaceRecipe.featheredWash:
        // The ink field is intentionally quieter than paintWatercolor's defaults.
        // The package painter still supplies subtle seeded pigment variation.
        final field = domain.deflate(math.min(domain.shortestSide * .14, 64));
        final mask = irregular
            ? pigmentOutline(field, seed: seed, broad: true)
            : (Path()..addOval(field));
        final layerBounds = domain.inflate(feather * 4);
        canvas.saveLayer(layerBounds, Paint());
        canvas.drawRect(
          domain,
          Paint()..color = DemoPalette.indigo.withValues(alpha: coreOpacity),
        );
        paintWatercolor(
          canvas,
          outline,
          pigment: DemoPalette.indigo,
          paper: paintSubstrate ? DemoPalette.paper : Colors.transparent,
          seed: seed,
          opacity: coreOpacity * .06,
          granulation: 0,
        );
        for (var pass = 0; pass < (tightFeather ? 2 : 1); pass++) {
          // A whole transparent layer is needed: a dstIn path drawn directly
          // would leave ink outside the path instead of clearing it.
          canvas.saveLayer(layerBounds, Paint()..blendMode = BlendMode.dstIn);
          canvas.drawPath(
            mask,
            Paint()
              ..color = Colors.white
              ..maskFilter = feather == 0
                  ? null
                  : MaskFilter.blur(BlurStyle.normal, feather),
          );
          canvas.restore();
        }
        canvas.restore();
      case SurfaceRecipe.fibers:
        _fibers(canvas, outline);
      case SurfaceRecipe.checker:
      case SurfaceRecipe.diamonds:
        _print(canvas, outline);
    }
  }

  void _fibers(Canvas canvas, Path outline) {
    if (fiberStrength == 0 || fiberDensity == 0) return;
    final random = math.Random(seed);
    final marks = Path();
    final count = (domain.width * domain.height * fiberDensity / 10000)
        .round()
        .clamp(0, 4096);
    for (var i = 0; i < count; i++) {
      final start = Offset(
        domain.left + random.nextDouble() * domain.width,
        domain.top + random.nextDouble() * domain.height,
      );
      final angle = fiberAngle + (random.nextDouble() - .5) * .12;
      final length = fiberLength * (.5 + random.nextDouble());
      final delta = Offset(math.cos(angle), math.sin(angle)) * length;
      marks.moveTo(start.dx, start.dy);
      marks.quadraticBezierTo(
        start.dx + delta.dx * .5 + .35,
        start.dy + delta.dy * .5,
        start.dx + delta.dx,
        start.dy + delta.dy,
      );
    }
    canvas.save();
    canvas.clipPath(outline);
    canvas.drawPath(
      marks,
      Paint()
        ..color = DemoPalette.wood.withValues(alpha: fiberStrength)
        ..style = PaintingStyle.stroke
        ..strokeWidth = .35
        ..strokeCap = StrokeCap.round,
    );
    canvas.restore();
  }

  void _print(Canvas canvas, Path outline) {
    const cell = 64.0;
    final random = math.Random(seed);
    final origin =
        domain.topLeft +
        phase +
        Offset(random.nextDouble() * cell, random.nextDouble() * cell);
    final diagonal = recipe == SurfaceRecipe.diamonds;
    final angle = diagonal ? math.pi / 4 : 0.0;
    Offset rotate(Offset p, double a) => Offset(
      p.dx * math.cos(a) - p.dy * math.sin(a),
      p.dx * math.sin(a) + p.dy * math.cos(a),
    );
    final corners = [
      domain.topLeft,
      domain.topRight,
      domain.bottomLeft,
      domain.bottomRight,
    ].map((p) => rotate(p - origin, -angle)).toList();
    final left = (corners.map((p) => p.dx).reduce(math.min) / cell).floor();
    final right = (corners.map((p) => p.dx).reduce(math.max) / cell).ceil();
    final top = (corners.map((p) => p.dy).reduce(math.min) / cell).floor();
    final bottom = (corners.map((p) => p.dy).reduce(math.max) / cell).ceil();
    final marks = Path();
    // At most 2500 cells at the maximum supported square domain, before parity.
    for (var y = top; y <= bottom; y++) {
      for (var x = left; x <= right; x++) {
        if ((x + y).isEven) {
          marks.addRect(Rect.fromLTWH(x * cell, y * cell, cell, cell));
        }
      }
    }
    canvas.save();
    canvas.clipPath(outline);
    canvas.translate(origin.dx, origin.dy);
    canvas.rotate(angle);
    canvas.drawPath(
      marks,
      Paint()..color = printColor.withValues(alpha: printColor.a * .45),
    );
    canvas.restore();
  }

  /// Paints a viewport of the retained world. Optional strips prove clipping
  /// preserves phase; the source picture and its seed never change per strip.
  void paintViewport(Canvas canvas, Rect viewport, {double? stripHeight}) {
    if (_disposed) throw StateError('SurfaceProof is disposed');
    if (![
          viewport.left,
          viewport.top,
          viewport.right,
          viewport.bottom,
        ].every((v) => v.isFinite) ||
        viewport.isEmpty ||
        !domain.contains(viewport.topLeft) ||
        viewport.right > domain.right ||
        viewport.bottom > domain.bottom ||
        (stripHeight != null && (!stripHeight.isFinite || stripHeight < 1))) {
      throw ArgumentError('Expected a finite viewport contained in the domain');
    }
    final height = stripHeight ?? viewport.height;
    for (var top = 0.0; top < viewport.height; top += height) {
      canvas.save();
      canvas.clipRect(
        Rect.fromLTWH(
          0,
          top,
          viewport.width,
          math.min(height, viewport.height - top),
        ),
        doAntiAlias: false,
      );
      canvas.translate(-viewport.left, -viewport.top);
      canvas.drawPicture(_picture);
      canvas.restore();
    }
  }

  /// Releases resources once. A disposed scene cannot be painted again.
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _picture.dispose();
    _textures.dispose();
  }
}
