import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:typed_data';

import 'package:flutter/painting.dart';

/// Extracted texture families, independent of color and host theme.
enum CraftMaterial {
  /// Irregular woven warp and weft.
  linen,

  /// Diagonal ribs.
  twill,

  /// Matted short fibers.
  felt,

  /// Paired small creases.
  paper,

  /// Long wavy grain.
  wood,
}

/// Owner-scoped cache of five static raster tiles, one per material.
///
/// Create outside paint; reuse for a scene and call [dispose] when it ends.
/// Seed is stable for the cache lifetime. Color and scale do not create entries.
/// Tiles are rasterized once and replayed through an ImageShader.
class MaterialTextures {
  /// Creates an empty cache with a fixed [seed].
  MaterialTextures({this.seed = 7});

  /// Seed used only when recording a tile.
  final int seed;
  final _pictures = <CraftMaterial, ui.Image>{};
  bool _disposed = false;
  static const _size = 96;

  /// Paints a clipped material fill; [scale] is logical pixels per tile unit.
  ///
  /// [strength] ranges from zero (flat fill) to one (original grain).
  /// Scale must be finite in 0.5..4. Bounds cannot exceed 2048 logical pixels
  /// per axis, bounding tile replay work. Invalid inputs throw [ArgumentError];
  /// using a disposed cache throws [StateError]. No timers or global state.
  void paint(
    Canvas canvas,
    Path outline, {
    required CraftMaterial material,
    required Color color,
    double scale = 1,
    double strength = 1,
  }) {
    if (_disposed) throw StateError('MaterialTextures is disposed');
    if (!scale.isFinite || scale < .5 || scale > 4) {
      throw ArgumentError.value(scale, 'scale', 'Expected 0.5..4');
    }
    if (!strength.isFinite || strength < 0 || strength > 1) {
      throw ArgumentError.value(strength, 'strength', 'Expected 0..1');
    }
    final bounds = outline.getBounds();
    if (![
          bounds.left,
          bounds.top,
          bounds.right,
          bounds.bottom,
        ].every((n) => n.isFinite) ||
        bounds.width > 2048 ||
        bounds.height > 2048) {
      throw ArgumentError.value(
        bounds,
        'outline',
        'Expected finite bounds up to 2048 per axis',
      );
    }
    if (bounds.isEmpty) return;
    canvas.drawPath(outline, Paint()..color = color);
    if (strength == 0) return;
    final picture = _pictures.putIfAbsent(material, () => _draw(material));
    canvas.save();
    canvas.clipPath(outline);
    // A bounded layer applies grain strength without fading the base color.
    if (strength < 1) {
      canvas.saveLayer(
        bounds,
        Paint()..color = Color.fromRGBO(255, 255, 255, strength),
      );
    }
    canvas.translate(bounds.left, bounds.top);
    canvas.drawPaint(
      Paint()
        ..shader = ui.ImageShader(
          picture,
          TileMode.repeated,
          TileMode.repeated,
          Float64List.fromList([
            scale,
            0,
            0,
            0,
            0,
            scale,
            0,
            0,
            0,
            0,
            1,
            0,
            0,
            0,
            0,
            1,
          ]),
        ),
    );
    if (strength < 1) canvas.restore();
    canvas.restore();
  }

  /// Releases cached raster tiles. Repeated disposal is safe.
  void dispose() {
    if (_disposed) return;
    for (final picture in _pictures.values) {
      picture.dispose();
    }
    _pictures.clear();
    _disposed = true;
  }

  ui.Image _draw(CraftMaterial material) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final random = math.Random(material.index + seed);
    const s = _size * 1.0;
    final light = Paint()..color = const Color(0x24FFFFFF);
    final dark = Paint()..color = const Color(0x16000000);
    switch (material) {
      case CraftMaterial.linen:
        // Irregular warp and weft: thin lines of varying strength.
        for (var i = 0.0; i < s; i += 1.2 + random.nextDouble() * 2) {
          final a = 0.03 + random.nextDouble() * 0.06;
          canvas.drawRect(
            Rect.fromLTWH(0, i, s, 1),
            Paint()..color = Color.fromRGBO(70, 55, 40, a),
          );
          canvas.drawRect(
            Rect.fromLTWH(i, 0, .4 + random.nextDouble(), s),
            Paint()..color = Color.fromRGBO(70, 55, 40, a * .8),
          );
        }
        _slubs(
          canvas,
          random,
          s,
          count: 14,
          length: 5,
          paint: Paint()..color = const Color(0x0E000000),
        );
      case CraftMaterial.twill:
        // Diagonal ribs, as in denim.
        for (var i = -s; i < s; i += 3) {
          final p = Path()
            ..moveTo(i, s)
            ..lineTo(i + s, 0);
          canvas.drawPath(
            p,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.2
              ..color = const Color(0x22FFFFFF),
          );
        }
        _slubs(canvas, random, s, count: 60, length: 4, paint: dark);
      case CraftMaterial.felt:
        // Matted fibers: many short random strokes in both tones.
        for (var i = 0; i < 520; i++) {
          final o = Offset(random.nextDouble() * s, random.nextDouble() * s);
          final a = random.nextDouble() * math.pi;
          final l = 1.5 + random.nextDouble() * 3.5;
          canvas.drawLine(
            o,
            o + Offset(math.cos(a) * l, math.sin(a) * l),
            Paint()
              ..strokeWidth = 0.7
              ..color = random.nextBool()
                  ? const Color(0x1EFFFFFF)
                  : const Color(0x14000000),
          );
        }
      case CraftMaterial.paper:
        // Short paired creases give paper relief without a sparse dot grid.
        // The fixed tile is cached once, like the cloth; never per frame.
        for (var i = 0; i < 1900; i++) {
          final x = random.nextDouble() * s;
          final y = random.nextDouble() * s;
          final length = .7 + random.nextDouble() * 2;
          final crease = Path()
            ..moveTo(x, y)
            ..quadraticBezierTo(x + length * .5, y - .6, x + length, y + .2);
          canvas.drawPath(
            crease,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = .45
              ..color = const Color(0x0C000000),
          );
          canvas.drawPath(
            crease.shift(const Offset(0, .6)),
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = .55
              ..color = light.color,
          );
        }
      case CraftMaterial.wood:
        // Long horizontal grain.
        for (var y = 0.0; y < s; y += 3 + random.nextDouble() * 4) {
          final p = Path()..moveTo(0, y);
          for (var x = 0.0; x <= s; x += 12) {
            p.lineTo(x, y + math.sin(x / 9 + y) * 0.8);
          }
          canvas.drawPath(
            p,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 0.8
              ..color = random.nextBool()
                  ? const Color(0x22000000)
                  : const Color(0x18FFFFFF),
          );
        }
    }
    final picture = recorder.endRecording();
    try {
      return picture.toImageSync(_size, _size);
    } finally {
      picture.dispose();
    }
  }

  static void _slubs(
    Canvas canvas,
    math.Random random,
    double s, {
    required int count,
    required double length,
    required Paint paint,
  }) {
    for (var i = 0; i < count; i++) {
      final o = Offset(random.nextDouble() * s, random.nextDouble() * s);
      final horizontal = random.nextBool();
      final l = length * (0.5 + random.nextDouble());
      canvas.drawLine(
        o,
        o + (horizontal ? Offset(l, 0) : Offset(0, l)),
        paint..strokeWidth = 1,
      );
    }
  }
}
