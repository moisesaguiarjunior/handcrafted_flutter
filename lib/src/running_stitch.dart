import 'dart:math' as math;

import 'package:flutter/painting.dart';

import 'path_geometry.dart';
import 'thread_paint.dart';

/// Extracts visible running-stitch spans from a caller-supplied seam.
///
/// Uses logical pixel arc lengths, restarting at each contour. [dash] and [gap]
/// must be finite and at least 0.5. Rejects more than 32 contours or 8192 total
/// logical pixels with [ArgumentError]. A seam is not automatically inset;
/// callers derive it from the same outline and reserve thread/relief padding.
/// Optional [irregularity] 0..1 varies length, angle and bow using [seed], without
/// bridging gaps. Maximum transverse drift is 1.5 pixels; reserve this clearance
/// too. Irregular output is limited to 1024 stitches. Zero preserves legacy paths.
Path runningStitchPath(
  Path source, {
  required double dash,
  required double gap,
  double irregularity = 0,
  int seed = 7,
}) {
  if (!irregularity.isFinite || irregularity < 0 || irregularity > 1) {
    throw ArgumentError('Expected irregularity 0..1');
  }
  final spans = pathSpans(checkedPathMetrics(source), dash: dash, gap: gap);
  if (irregularity == 0) return spanPath(spans);
  if (spans.length > 1024) {
    throw ArgumentError('Irregular sewing exceeds 1024 stitches');
  }
  final random = math.Random(seed);
  final result = Path();
  final drift = math.min(1.5, dash * .15) * irregularity;
  for (final span in spans) {
    // Stay inside each original span so neighboring stitches never bridge a gap.
    final inset = math.min(span.end - span.start, gap) * .18 * irregularity;
    final a = span.metric.getTangentForOffset(
      span.start + random.nextDouble() * inset,
    )!;
    final b = span.metric.getTangentForOffset(
      span.end - random.nextDouble() * inset,
    )!;
    final mid = span.metric.getTangentForOffset((span.start + span.end) / 2)!;
    Offset displaced(Offset p, Offset tangent) =>
        p +
        Offset(-tangent.dy, tangent.dx) *
            ((random.nextDouble() * 2 - 1) * drift);
    final start = displaced(a.position, a.vector);
    final end = displaced(b.position, b.vector);
    final control = displaced(mid.position, mid.vector);
    result
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);
  }
  return result;
}

/// Paints a running stitch with optional illustrative puncture compression.
///
/// [compression] is 0..1, a shading strength, not physical depth or tension.
/// [pucker] 0..1 adds broader crease shading around actual holes, multiplied
/// by compression. Reserve width * 7 for its footprint. This does not displace
/// the weave or simulate a needle. [width] is 0.5..8
/// logical pixels; [light] is a finite nonzero direction, normalized internally.
/// The caller owns clipping and must reserve width * 4 padding for relief.
/// Invalid parameters throw [ArgumentError] before any painting occurs.
void paintRunningStitch(
  Canvas canvas,
  Path seam, {
  required Color thread,
  double dash = 6,
  double gap = 4,
  double width = 1.5,
  double compression = 0,
  double irregularity = 0,
  int seed = 7,
  double pucker = 0,
  Offset light = const Offset(-1, -1),
}) {
  validateThreadPaint(width, compression, light, pucker: pucker);
  final stitches = runningStitchPath(
    seam,
    dash: dash,
    gap: gap,
    irregularity: irregularity,
    seed: seed,
  );
  paintThreadGeometry(
    canvas,
    stitches,
    thread: thread,
    width: width,
    compression: compression,
    pucker: pucker,
    light: light,
  );
}
