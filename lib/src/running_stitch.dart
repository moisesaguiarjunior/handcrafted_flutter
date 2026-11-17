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
/// bridging gaps. Original arcs are sampled at most 0.5px apart (at most 18432
/// stations including endpoints); normal drift is at most 1.5px at stations.
/// Reserve 1.75px including the polygonal approximation, in addition to ink
/// and relief clearance. Irregular output is limited to 1024 stitches. Zero preserves legacy paths.
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
    final start = span.start + random.nextDouble() * inset;
    final end = span.end - random.nextDouble() * inset;
    final offsets = List.generate(
      3,
      (_) => (random.nextDouble() * 2 - 1) * drift,
    );
    final count = math.max(1, ((end - start) / .5).ceil());
    for (var i = 0; i <= count; i++) {
      final t = i / count;
      final tangent = span.metric.getTangentForOffset(
        start + (end - start) * t,
      )!;
      final normal = Offset(-tangent.vector.dy, tangent.vector.dx);
      final offset =
          offsets[0] * (1 - t) * (1 - t) +
          2 * offsets[1] * t * (1 - t) +
          offsets[2] * t * t;
      final point = tangent.position + normal * offset;
      if (i == 0) {
        result.moveTo(point.dx, point.dy);
      } else {
        result.lineTo(point.dx, point.dy);
      }
    }
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
