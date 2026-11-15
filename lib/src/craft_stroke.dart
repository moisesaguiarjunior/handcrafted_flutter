import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'path_geometry.dart';

/// Distribution of ink along the same centerline.
enum CraftLinePattern {
  /// A continuous completed line, optionally revealed by progress.
  solid,

  /// Visible spans separated by gaps, measured along the curve.
  dashed,

  /// Dots or brush dabs separated by width + gap logical pixels.
  dotted,
}

/// Illustrative instrument treatments, independent of path and pattern.
enum CraftStrokeTool {
  /// Crisp, round-ended ink.
  pen,

  /// Translucent felt-tip ink. Set a larger width for a broad marker.
  marker,

  /// Tapered, seeded variable-width ink with fine bristle highlights.
  brush,
}

/// Immutable stroke parameters; color, seed and progress are separate inputs.
///
/// Width is 0.5..32 logical pixels; dash/gap are at least 0.5; variation is 0..1.
/// Values are validated before painting, including parameters inactive for the
/// chosen pattern. Brush/marker effects approximate ink, not fluid simulation.
@immutable
final class CraftStrokeStyle {
  /// Creates an instrument and pattern recipe.
  const CraftStrokeStyle({
    this.tool = CraftStrokeTool.pen,
    this.pattern = CraftLinePattern.solid,
    this.width = 2,
    this.dash = 8,
    this.gap = 6,
    this.variation = .35,
    this.join = StrokeJoin.round,
  });

  /// Instrument treatment.
  final CraftStrokeTool tool;

  /// Ink distribution.
  final CraftLinePattern pattern;

  /// Nominal maximum width, in logical pixels.
  final double width;

  /// Visible dashed span length, in logical pixels.
  final double dash;

  /// Centerline dash gap, or dotted edge-to-edge spacing, in logical pixels.
  /// Round caps reduce a dash gap's visible opening; use gap > width to keep it.
  final double gap;

  /// Corner treatment for solid/dashed pen and marker strokes.
  ///
  /// Brush outlines and dotted dabs do not use stroked joins. The default
  /// remains rounded; miter uses Flutter's default miter limit of 4.
  final StrokeJoin join;

  /// Seeded brush width/texture variation. Does not change the centerline.
  final double variation;

  void _validate() {
    if (!width.isFinite ||
        width < .5 ||
        width > 32 ||
        !dash.isFinite ||
        dash < .5 ||
        !gap.isFinite ||
        gap < .5 ||
        !variation.isFinite ||
        variation < 0 ||
        variation > 1) {
      throw ArgumentError('Invalid stroke width, dash, gap or variation');
    }
  }

  @override
  bool operator ==(Object other) =>
      other is CraftStrokeStyle &&
      tool == other.tool &&
      pattern == other.pattern &&
      width == other.width &&
      dash == other.dash &&
      gap == other.gap &&
      variation == other.variation &&
      join == other.join;
  @override
  int get hashCode =>
      Object.hash(tool, pattern, width, dash, gap, variation, join);
}

/// A smooth open cubic path through 2..64 caller-supplied waypoints.
///
/// Curvature is 0..1; zero makes straight segments. Endpoints are preserved,
/// but intermediate control handles can overshoot the waypoint bounds. Reserve
/// layout padding. Points must be finite within +/-8192 logical pixels and
/// adjacent points must differ. Total path length is limited to 8192.
Path craftCurveThrough(List<Offset> points, {double curvature = .7}) {
  if (points.length < 2 ||
      points.length > 64 ||
      !curvature.isFinite ||
      curvature < 0 ||
      curvature > 1 ||
      points.any(
        (p) =>
            !p.dx.isFinite ||
            !p.dy.isFinite ||
            p.dx.abs() > 8192 ||
            p.dy.abs() > 8192,
      )) {
    throw ArgumentError('Expected 2..64 finite points and curvature 0..1');
  }
  final path = Path()..moveTo(points.first.dx, points.first.dy);
  for (var i = 0; i < points.length - 1; i++) {
    final a = points[i];
    final b = points[i + 1];
    if (a == b) throw ArgumentError('Adjacent waypoints must differ');
    final previous = points[i == 0 ? i : i - 1];
    final next = points[i + 2 < points.length ? i + 2 : i + 1];
    final c1 = a + (b - previous) * (curvature / 6);
    final c2 = b - (next - a) * (curvature / 6);
    path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, b.dx, b.dy);
  }
  checkedPathMetrics(path);
  return path;
}

/// Reveals an arbitrary path by global arc length across contours, in order.
///
/// Progress is 0..1; no ticker or clock is created. Complete closed contours
/// stay closed and the source fill rule is retained. Source geometry is never
/// modified. Work limits match stitches:
/// at most 32 contours and 8192 logical pixels, with finite path bounds.
Path trimCraftPath(Path source, {required double progress}) {
  final spans = pathSpans(checkedPathMetrics(source), progress: progress);
  return spanPath(spans, preserveClosed: true)..fillType = source.fillType;
}

/// Draws pen, marker or brush ink on any caller-supplied curved or straight path.
///
/// Progress reveals global arc length; pattern phase restarts per contour and
/// stays fixed while revealing. Zero progress paints nothing; one completes the
/// selected pattern (a dashed line does not silently become solid). Paint a
/// faint track first if incomplete and complete portions should coexist.
///
/// Drawing is deterministic for identical inputs on the same renderer. Brush
/// width depends on seed and distance, not elapsed time. Caps/ink can extend by
/// half the nominal width outside the centerline; the caller owns clipping and
/// layout padding. This does not compute an inset seam or simulate wet pigment.
void paintCraftStroke(
  Canvas canvas,
  Path source, {
  required Color color,
  CraftStrokeStyle style = const CraftStrokeStyle(),
  int seed = 7,
  double progress = 1,
}) {
  style._validate();
  final metrics = checkedPathMetrics(source);
  final spans = pathSpans(
    metrics,
    progress: progress,
    dash: style.pattern == CraftLinePattern.dashed ? style.dash : null,
    gap: style.gap,
  );
  if (style.pattern == CraftLinePattern.dotted) {
    for (final span in spans) {
      for (var d = 0.0; d < span.end; d += style.width + style.gap) {
        final tangent = span.metric.getTangentForOffset(d);
        if (tangent == null) continue;
        final radius = style.width / 2;
        if (style.tool == CraftStrokeTool.brush) {
          final pressure =
              1 -
              style.variation *
                  .3 *
                  (1 + math.sin(d * .09 + (seed & 0xffff) * .73)) /
                  2;
          canvas.save();
          canvas.translate(tangent.position.dx, tangent.position.dy);
          canvas.rotate(tangent.angle - .4);
          canvas.drawOval(
            Rect.fromCenter(
              center: Offset.zero,
              width: style.width * pressure,
              height: style.width * .72,
            ),
            Paint()..color = color,
          );
          canvas.restore();
          continue;
        }
        canvas.drawCircle(
          tangent.position,
          radius,
          Paint()
            ..color = style.tool == CraftStrokeTool.marker
                ? color.withValues(alpha: color.a * .68)
                : color,
        );
      }
    }
    return;
  }
  if (style.tool == CraftStrokeTool.brush) {
    for (final span in spans) {
      _paintBrush(canvas, span, color, style, seed);
    }
    return;
  }
  // Keep a full closed solid contour closed, avoiding overlapping marker caps.
  final path = spanPath(
    spans,
    preserveClosed: style.pattern == CraftLinePattern.solid,
  );
  canvas.drawPath(
    path,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = style.width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = style.join
      ..color = style.tool == CraftStrokeTool.marker
          ? color.withValues(alpha: color.a * .68)
          : color,
  );
}

void _paintBrush(
  Canvas canvas,
  PathSpan span,
  Color color,
  CraftStrokeStyle style,
  int seed,
) {
  final left = <Offset>[];
  final right = <Offset>[];
  final bristles = Path();
  final phase = (seed & 0xffff) * .73;
  // Fixed-distance samples keep the already drawn prefix stable during reveal.
  final distances = <double>[span.start];
  for (var d = span.start + 2; d < span.end; d += 2) {
    distances.add(d);
  }
  distances.add(span.end);
  for (final d in distances) {
    final tangent = span.metric.getTangentForOffset(d);
    if (tangent == null) continue;
    final direction = tangent.vector;
    final normal = Offset(-direction.dy, direction.dx);
    final taper = span.metric.isClosed
        ? 1.0
        : math.min(
            1.0,
            math.min(d, span.metric.length - d) / (style.width * 1.5),
          );
    final pressure = .65 + .35 * math.sin(d * .09 + phase);
    final radius =
        style.width /
        2 *
        (.15 + .85 * taper) *
        (1 - style.variation * .5 * (1 - pressure));
    left.add(tangent.position + normal * radius);
    right.add(tangent.position - normal * radius);
    final grain = tangent.position + normal * radius * .32;
    if (left.length == 1) {
      bristles.moveTo(grain.dx, grain.dy);
    } else {
      bristles.lineTo(grain.dx, grain.dy);
    }
  }
  if (left.isEmpty) return;
  final ink = Path()..moveTo(left.first.dx, left.first.dy);
  for (final p in left.skip(1)) {
    ink.lineTo(p.dx, p.dy);
  }
  for (final p in right.reversed) {
    ink.lineTo(p.dx, p.dy);
  }
  ink.close();
  canvas.drawPath(ink, Paint()..color = color);
  canvas.save();
  canvas.clipPath(ink);
  canvas.drawPath(
    bristles,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.min(.7, style.width * .08)
      ..strokeJoin = StrokeJoin.round
      ..color = const Color(0xFFFFFFFF)
          .withValues(alpha: color.a * .28 * style.variation),
  );
  canvas.restore();
}
