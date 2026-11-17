import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

import 'contour_inset.dart';
import 'path_geometry.dart';

part 'cord_braid.dart';

/// Illustrative raised bands; none simulates strand tension or displaced cloth.
enum CraftTrimKind {
  /// Diagonal strand hatching.
  rope,

  /// Fine directional fibers.
  ribbon,

  /// Close transverse thread marks.
  embroidered,
}

/// Prepares the centerline of a trim inside a closed substrate.
///
/// [gap] is nominal clearance from the substrate to the band's body, excluding
/// its cast shadow. Reserves half [width] plus [sampleSpacing] for polygonal inset
/// error. This is not an exact Bezier clearance guarantee: clip final ink to the
/// substrate. Holes expand and narrow regions can disappear. Prepare outside
/// paint; the caller owns and invalidates the result. See [insetCraftPath] limits.
Path contourTrimPath(
  Path outline, {
  double width = 8,
  double gap = 0,
  double sampleSpacing = .5,
}) {
  if (!width.isFinite ||
      width < 1 ||
      width > 32 ||
      !gap.isFinite ||
      gap < 0 ||
      gap > 96) {
    throw ArgumentError('Expected trim width 1..32 and nominal gap 0..96');
  }
  return insetCraftPath(
    outline,
    distance: gap + width / 2 + sampleSpacing,
    sampleSpacing: sampleSpacing,
  );
}

/// Paints cord, ribbon or close embroidered thread along an open/closed path.
///
/// Uses logical pixels: [width] 1..32, [pitch] 2..32, [relief] and [texture] 0..1.
/// [light] is a finite nonzero direction. All validation precedes painting.
/// Accepts the shared 32-contour / 8192-length geometry budget, coordinates within
/// +/-8192 and at most 2048 texture stations (even with texture set to zero).
/// One-point paths have no tangent and paint nothing; this is not a freehand
/// capture renderer. No cache, image, blur, layer or clock is allocated.
///
/// Texture strokes remain inside the nominal round band, including at open ends.
/// Shading is illustrative: reserve [width] around the centerline for the cast
/// shadow, or clip the whole composition. Use [contourTrimPath] to place bands at
/// a nominal edge gap; this painter does not infer the substrate from its path.
/// Optional [strandColors] adds 2..6 individually shaded strands to rope only, independently
/// of grain [texture]. Colored work is additionally limited to 8192 samples.
/// Closed contours use whole turns so the color phase meets at the seam.
/// Palette mode paints only its strands (no flat [color] backing). Local depth
/// orders crossings; two colors twist, while three or more form a braid.
/// Fine filaments follow each strand, not the whole band. At most six short
/// strokes per adjacent strand sample plus one ground shadow per strand;
/// this bounded approximation is not a tension/physical fiber solver.
void paintCraftTrim(
  Canvas canvas,
  Path path, {
  required Color color,
  CraftTrimKind kind = CraftTrimKind.rope,
  double width = 8,
  double pitch = 6,
  double relief = .7,
  double texture = .75,
  Offset light = const Offset(-1, -1),
  List<Color>? strandColors,
}) {
  if (!width.isFinite ||
      width < 1 ||
      width > 32 ||
      !pitch.isFinite ||
      pitch < 2 ||
      pitch > 32 ||
      !relief.isFinite ||
      relief < 0 ||
      relief > 1 ||
      !texture.isFinite ||
      texture < 0 ||
      texture > 1 ||
      !light.dx.isFinite ||
      !light.dy.isFinite ||
      !light.distance.isFinite ||
      light.distance == 0) {
    throw ArgumentError('Invalid trim width, pitch, relief, texture or light');
  }
  final strands = strandColors == null
      ? null
      : List<Color>.unmodifiable(strandColors);
  if (strands != null &&
      (kind != CraftTrimKind.rope ||
          strands.length < 2 ||
          strands.length > 6)) {
    throw ArgumentError('Expected 2..6 strand colors for rope only');
  }
  final metrics = checkedPathMetrics(path);
  final bounds = path.getBounds();
  if ([
    bounds.left,
    bounds.top,
    bounds.right,
    bounds.bottom,
  ].any((n) => n.abs() > 8192)) {
    throw ArgumentError('Expected trim coordinates within +/-8192');
  }
  var stations = 0;
  for (final metric in metrics) {
    if (metric.length == 0) continue;
    stations += (metric.length / pitch).ceil() + (metric.isClosed ? 0 : 1);
  }
  if (stations > 2048) {
    throw ArgumentError('Trim exceeds 2048 texture stations');
  }
  if (strands != null &&
      metrics.fold<int>(
            0,
            (sum, metric) =>
                sum +
                _braidPlan(metric, width, pitch, strands.length).samples *
                    strands.length,
          ) >
          8192) {
    throw ArgumentError('Colored rope exceeds 8192 strand samples');
  }
  final direction = light / light.distance;
  if (strands != null) {
    _paintBraidedCord(
      canvas,
      metrics,
      strands,
      width: width,
      pitch: pitch,
      relief: relief,
      texture: texture,
      light: direction,
    );
    return;
  }
  final band = spanPath(pathSpans(metrics), preserveClosed: true);
  Paint stroke(Color c, double w) => Paint()
    ..color = c
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;
  if (relief > 0) {
    canvas.drawPath(
      band.shift(-direction * width * .22),
      stroke(Color.fromRGBO(35, 25, 15, .22 * relief * color.a), width * 1.1),
    );
  }
  canvas.drawPath(band, stroke(color, width));

  if (relief > 0) {
    canvas.drawPath(
      band.shift(direction * width * .1),
      stroke(Color.fromRGBO(255, 255, 255, .32 * relief * color.a), width * .7),
    );
  }
  if (texture == 0) return;
  final dark = stroke(
    Color.fromRGBO(35, 25, 15, .4 * texture * color.a),
    width * .08,
  );
  final bright = stroke(
    Color.fromRGBO(255, 255, 255, .5 * texture * color.a),
    width * .06,
  );
  for (final metric in metrics) {
    if (metric.length == 0) continue;
    final count = (metric.length / pitch).ceil();
    final end = metric.isClosed ? count : count + 1;
    for (var i = 0; i < end; i++) {
      final tangent = metric.getTangentForOffset(metric.length * i / count);
      if (tangent == null) continue;
      final p = tangent.position;
      final t = tangent.vector;
      final n = Offset(-t.dy, t.dx);
      final a = math.min(pitch * .25, width * .14);
      switch (kind) {
        case CraftTrimKind.rope:
          final mark = Path()
            ..moveTo(
              (p - n * width * .4 - t * a).dx,
              (p - n * width * .4 - t * a).dy,
            )
            ..quadraticBezierTo(
              p.dx,
              p.dy,
              (p + n * width * .4 + t * a).dx,
              (p + n * width * .4 + t * a).dy,
            );
          canvas.drawPath(mark, dark);
          canvas.drawPath(mark.shift(t * width * .08), bright);
        case CraftTrimKind.ribbon:
          for (final offset in [-.24, 0.0, .24]) {
            final c = p + n * width * offset;
            canvas.drawLine(c - t * a, c + t * a, bright);
          }
        case CraftTrimKind.embroidered:
          canvas.drawLine(p - n * width * .4, p + n * width * .4, dark);
          canvas.drawLine(
            p - n * width * .35 + t * width * .08,
            p + n * width * .35 + t * width * .08,
            bright,
          );
      }
    }
  }
}
