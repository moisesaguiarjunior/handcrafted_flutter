import 'dart:math' as math;
import 'dart:ui' show PointMode;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'path_geometry.dart';

part 'dry_stroke.dart';

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

  /// Fine graphite grain, with the substrate visible between deposits.
  pencil,

  /// Broad, powdery deposits without blur or offscreen layers.
  chalk,

  /// Dense wax ridges with seeded gaps between deposits.
  wax,
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
    this.dryCoverage = 0,
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

  /// Seeded brush or dry-deposit variation. Does not change the centerline.
  final double variation;

  /// Extra overlapping grain for pencil/chalk/wax, in 0..1. Zero preserves the
  /// original sparse deposits; one produces a denser hand-rubbed mark. Ignored
  /// by wet tools; all values are validated. Work stays bounded to eight marks
  /// per distance station, at most 8224 stations over the shared path budget.
  final double dryCoverage;

  void _validate() {
    if (!width.isFinite ||
        width < .5 ||
        width > 32 ||
        !dash.isFinite ||
        dash < .5 ||
        !gap.isFinite ||
        gap < .5 ||
        !dryCoverage.isFinite ||
        dryCoverage < 0 ||
        dryCoverage > 1 ||
        !variation.isFinite ||
        variation < 0 ||
        variation > 1) {
      throw ArgumentError(
        'Invalid stroke width, dash, gap, variation or dry coverage',
      );
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
      join == other.join &&
      dryCoverage == other.dryCoverage;
  @override
  int get hashCode => Object.hash(
    tool,
    pattern,
    width,
    dash,
    gap,
    variation,
    join,
    dryCoverage,
  );
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

/// Conservative local envelope for [paintCraftStroke], independent of seed.
///
/// Includes instrument width, native miter joins and maximum dry dispersion.
/// Nonzero progress retains the full source envelope for stable reveal layout;
/// zero/no drawable spans return Rect.zero. All paint input limits still apply.
/// [rasterPadding] adds nonnegative local clearance (default2), covering the
/// tested native/browser fringe at unit scale/DPR>=1. Under downscaling reserve
/// at least two device pixels after transforming instead. This is not a tight alpha scan,
/// transformed screen bound, freehand bound or permission to exceed path limits.
Rect craftStrokeBounds(
  Path source, {
  CraftStrokeStyle style = const CraftStrokeStyle(),
  double progress = 1,
  double rasterPadding = 2,
}) {
  final spans = _craftStrokeSpans(source, style, progress);
  if (!rasterPadding.isFinite || rasterPadding < 0) {
    throw ArgumentError('Expected finite nonnegative raster padding');
  }
  if (spans.isEmpty) return Rect.zero;
  double radius;
  if (_isDryTool(style.tool)) {
    final step = _dryStep(style), length = _dryLength(style, step);
    final body =
        style.width * _dryBodyWidth / 2 +
        (style.pattern == CraftLinePattern.dotted ? length / 2 : 0);
    // L1 is intentionally conservative: across and forward directions are unit
    // vectors, and every round grain adds half its actual maximum stroke width.
    final grain =
        style.width * _dryAcrossLimit(style) +
        _dryForwardOffset(style, step, 1).abs() +
        _dryGrainLength(style, length, 1, .5 * style.variation) / 2 +
        _dryGrainWidth(style, 1) / 2;
    radius = math.max(body, grain);
  } else {
    final nativeJoin =
        style.tool != CraftStrokeTool.brush &&
        style.pattern != CraftLinePattern.dotted;
    radius =
        style.width /
        2 *
        (nativeJoin && style.join == StrokeJoin.miter ? _inkMiterLimit : 1);
  }
  final bounds = source.getBounds().inflate(radius + rasterPadding);
  if (!bounds.isFinite || !bounds.width.isFinite || !bounds.height.isFinite) {
    throw ArgumentError('Stroke envelope overflows finite coordinates');
  }
  return bounds;
}

const _inkMiterLimit = 4.0;

bool _isDryTool(CraftStrokeTool tool) =>
    tool == CraftStrokeTool.pencil ||
    tool == CraftStrokeTool.chalk ||
    tool == CraftStrokeTool.wax;

List<PathSpan> _craftStrokeSpans(
  Path source,
  CraftStrokeStyle style,
  double progress,
) {
  style._validate();
  return pathSpans(
    checkedPathMetrics(source),
    progress: progress,
    dash: style.pattern == CraftLinePattern.dashed ? style.dash : null,
    gap: style.gap,
  );
}

/// Draws ink or dry instruments on a caller-supplied curved or straight path.
///
/// Progress reveals global arc length; pattern phase restarts per contour and
/// stays fixed while revealing. Zero progress paints nothing; one completes the
/// selected pattern (a dashed line does not silently become solid). Paint a
/// faint track first if incomplete and complete portions should coexist.
///
/// Drawing is deterministic for identical inputs on the same renderer. Brush
/// width depends on seed and distance, not elapsed time. Round caps and dabs can
/// extend half the nominal width outside the centerline. Miter corners can extend
/// farther, subject to Flutter's native miter limit; half-width padding is not
/// sufficient for those corners. The caller owns clipping and layout padding.
/// This does not compute an inset seam or simulate wet pigment.
void paintCraftStroke(
  Canvas canvas,
  Path source, {
  required Color color,
  CraftStrokeStyle style = const CraftStrokeStyle(),
  int seed = 7,
  double progress = 1,
}) {
  final spans = _craftStrokeSpans(source, style, progress);
  if (_isDryTool(style.tool)) {
    for (final span in spans) {
      _paintDryStroke(canvas, span, color, style, seed);
    }
    return;
  }
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
  canvas.drawPath(path, _inkStrokePaint(color, style));
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

Paint _inkStrokePaint(Color color, CraftStrokeStyle style) => Paint()
  ..style = PaintingStyle.stroke
  ..strokeWidth = style.width
  ..strokeCap = StrokeCap.round
  ..strokeJoin = style.join
  ..strokeMiterLimit = _inkMiterLimit
  ..color = style.tool == CraftStrokeTool.marker
      ? color.withValues(alpha: color.a * .68)
      : color;

/// Renders bounded solid-pen input without an illustrative arc-length limit.
///
/// Accepts at most 128 strokes and 8192 total points. [bounds] is the permitted
/// input rectangle: finite positive dimensions up to 2048 logical pixels each,
/// coordinates within +/-8192. Points must be finite and inside its inclusive
/// edges. These bounds validate input, not clip ink; reserve half-width/miter
/// clearance or apply the consumer's own canvas clip before painting.
///
/// Reuses [CraftStrokeStyle] validation, width and native joins, accepting only
/// solid pen. Marker, brush, dashed and dotted treatments throw [ArgumentError];
/// their arc-length sampling budgets remain with [paintCraftStroke].
///
/// Preserves ordered points as straight segments, with no smoothing, truncation,
/// progress or closed-contour inference. Empty strokes paint nothing; one-point
/// taps draw a round native point. Repeated points keep native drawPath behavior.
/// All input is validated before painting any stroke. Cost is bounded by points,
/// not traveled distance. No capture controller, clock, IO, image or cache is
/// retained. Consumers own editable input, consent, storage and export scaling.
void paintCraftFreehand(
  Canvas canvas,
  List<List<Offset>> strokes, {
  required Rect bounds,
  required Color color,
  CraftStrokeStyle style = const CraftStrokeStyle(),
}) {
  style._validate();
  if (style.tool != CraftStrokeTool.pen ||
      style.pattern != CraftLinePattern.solid ||
      strokes.length > 128 ||
      !bounds.width.isFinite ||
      !bounds.height.isFinite ||
      bounds.width <= 0 ||
      bounds.height <= 0 ||
      bounds.width > 2048 ||
      bounds.height > 2048 ||
      [
        bounds.left,
        bounds.top,
        bounds.right,
        bounds.bottom,
      ].any((v) => !v.isFinite || v.abs() > 8192)) {
    throw ArgumentError(
      'Expected solid pen, at most 128 strokes and finite bounded input rectangle',
    );
  }
  var points = 0;
  for (final stroke in strokes) {
    points += stroke.length;
    if (points > 8192) {
      throw ArgumentError('Freehand exceeds 8192 input points');
    }
    for (final point in stroke) {
      if (!point.dx.isFinite ||
          !point.dy.isFinite ||
          point.dx < bounds.left ||
          point.dx > bounds.right ||
          point.dy < bounds.top ||
          point.dy > bounds.bottom) {
        throw ArgumentError(
          'Expected finite points inside inclusive input bounds',
        );
      }
    }
  }
  final paint = _inkStrokePaint(color, style);
  for (final stroke in strokes) {
    if (stroke.isEmpty) continue;
    if (stroke.length == 1) {
      canvas.drawPoints(PointMode.points, stroke, paint);
      continue;
    }
    final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
    for (final point in stroke.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(path, paint);
  }
}
