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

  /// Fine closed-cell pores, without cloth fibers or directional paper creases.
  eva,

  /// Fine, compact plain weave, with subtle thread crossings.
  cotton,

  /// Short, soft directional nap; an illustrative velvety cloth surface.
  suede,

  /// Pebbled hide grain: rounded cells separated by fine creases, with pores.
  leather,
}

/// Owner-scoped cache of static raster tiles, one per material.
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
      case CraftMaterial.cotton:
        for (var y = 0; y < 48; y++) {
          for (var x = 0; x < 48; x++) {
            final center = Offset(x * 2.0 + .5, y * 2.0 + .5);
            final horizontal = (x + y).isEven;
            final delta = horizontal
                ? const Offset(.7, 0)
                : const Offset(0, .7);
            final alpha = .035 + random.nextDouble() * .055;
            canvas.drawLine(
              center - delta,
              center + delta,
              Paint()
                ..strokeCap = StrokeCap.round
                ..strokeWidth = .8
                ..color = Color.fromRGBO(255, 255, 255, alpha),
            );
            canvas.drawLine(
              center + const Offset(.4, .5) - delta,
              center + const Offset(.4, .5) + delta,
              Paint()
                ..strokeWidth = .35
                ..color = Color.fromRGBO(35, 25, 20, alpha * .7),
            );
          }
        }
      case CraftMaterial.suede:
        for (var i = 0; i < 2600; i++) {
          final p = Offset(random.nextDouble() * s, random.nextDouble() * s);
          final angle = -.8 + random.nextDouble() * 1.6;
          final length = .35 + random.nextDouble() * .95;
          canvas.drawLine(
            p,
            p + Offset(math.cos(angle), math.sin(angle)) * length,
            Paint()
              ..strokeCap = StrokeCap.round
              ..strokeWidth = .35 + random.nextDouble() * .4
              ..color = random.nextBool()
                  ? const Color(0x22FFFFFF)
                  : const Color(0x18000000),
          );
        }
      case CraftMaterial.eva:
        for (var i = 0; i < 720; i++) {
          final p = Offset(random.nextDouble() * s, random.nextDouble() * s);
          final radius = .25 + random.nextDouble() * .65;
          canvas.drawCircle(p + const Offset(.3, .4), radius, light);
          canvas.drawCircle(p, radius * .8, dark);
        }
      case CraftMaterial.leather:
        _leather(canvas, random);
    }
    final picture = recorder.endRecording();
    try {
      return picture.toImageSync(_size, _size);
    } finally {
      picture.dispose();
    }
  }

  /// Pebbled grain from a jittered cell field that wraps at the tile edge.
  /// A smooth height (distance to the nearest cell border) gives each
  /// pebble a rounded top; its slope is lit from the upper left and the
  /// valleys between cells darken. Fixed 96x96 work, batched by tone.
  static void _leather(Canvas canvas, math.Random random) {
    const cells = 16;
    const cell = _size / cells;
    final centers = List.generate(
      cells * cells,
      (_) => Offset(
        (.06 + random.nextDouble() * .88) * cell,
        (.06 + random.nextDouble() * .88) * cell,
      ),
    );
    final height = Float64List(_size * _size);
    for (var y = 0; y < _size; y++) {
      for (var x = 0; x < _size; x++) {
        final p = Offset(x + .5, y + .5);
        final gx = x ~/ cell, gy = y ~/ cell;
        var nearest = double.infinity, second = double.infinity;
        for (var dy = -1; dy <= 1; dy++) {
          for (var dx = -1; dx <= 1; dx++) {
            final cx = gx + dx, cy = gy + dy;
            final origin = Offset(cx * cell, cy * cell);
            final c = origin + centers[(cy % cells) * cells + (cx % cells)];
            final d = (p - c).distance;
            if (d < nearest) {
              second = nearest;
              nearest = d;
            } else if (d < second) {
              second = d;
            }
          }
        }
        final t = math.min(1.0, (second - nearest) / 2.6);
        height[y * _size + x] = t * t * (3 - 2 * t);
      }
    }
    // Tones are quantized finely across the small alpha range actually used.
    const buckets = 24;
    const maxAlpha = .3;
    final darkPoints = List.generate(buckets, (_) => <double>[]);
    final lightPoints = List.generate(buckets, (_) => <double>[]);
    void add(List<List<double>> target, double alpha, int x, int y) {
      final bucket = (alpha / maxAlpha * buckets).round();
      if (bucket <= 0) return;
      target[math.min(bucket, buckets) - 1].addAll([x + .5, y + .5]);
    }

    double at(int x, int y) => height[(y % _size) * _size + (x % _size)];
    for (var y = 0; y < _size; y++) {
      for (var x = 0; x < _size; x++) {
        final h = at(x, y);
        // Rising toward the lower right means the slope faces the light.
        final slope = at(x + 1, y + 1) - at(x - 1, y - 1);
        add(darkPoints, (1 - h) * .17 + math.max(0, -slope) * .16, x, y);
        add(lightPoints, math.max(0, slope) * .2, x, y);
      }
    }
    for (var i = 0; i < buckets; i++) {
      final alpha = (i + 1) / buckets * maxAlpha;
      for (final (points, base) in [
        (darkPoints[i], const Color(0xFF000000)),
        (lightPoints[i], const Color(0xFFFFFFFF)),
      ]) {
        if (points.isEmpty) continue;
        canvas.drawRawPoints(
          ui.PointMode.points,
          Float32List.fromList(points),
          Paint()
            ..color = base.withValues(alpha: alpha)
            ..strokeWidth = 1
            ..strokeCap = StrokeCap.square,
        );
      }
    }
    // Sparse pores and a few long, faint wrinkles break the regular cell rhythm.
    for (var i = 0; i < 140; i++) {
      final p = Offset(
        random.nextDouble() * _size,
        random.nextDouble() * _size,
      );
      canvas.drawCircle(
        p,
        .3 + random.nextDouble() * .35,
        Paint()..color = const Color(0x1C000000),
      );
    }
    for (var i = 0; i < 5; i++) {
      final start = Offset(
        random.nextDouble() * _size,
        random.nextDouble() * _size,
      );
      final angle = random.nextDouble() * math.pi;
      final length = 18 + random.nextDouble() * 26;
      final direction = Offset(math.cos(angle), math.sin(angle));
      final bend =
          Offset(-direction.dy, direction.dx) * (random.nextDouble() * 6 - 3);
      final end = start + direction * length;
      final wrinkle = Path()
        ..moveTo(start.dx, start.dy)
        ..quadraticBezierTo(
          (start.dx + end.dx) / 2 + bend.dx,
          (start.dy + end.dy) / 2 + bend.dy,
          end.dx,
          end.dy,
        );
      canvas.drawPath(
        wrinkle,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = .7
          ..color = const Color(0x12000000),
      );
      canvas.drawPath(
        wrinkle.shift(const Offset(.6, .7)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = .6
          ..color = const Color(0x10FFFFFF),
      );
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
