import 'package:flutter/painting.dart';

import 'path_geometry.dart';
import 'thread_paint.dart';

/// Extracts visible running-stitch spans from a caller-supplied seam.
///
/// Uses logical pixel arc lengths, restarting at each contour. [dash] and [gap]
/// must be finite and at least 0.5. Rejects more than 32 contours or 8192 total
/// logical pixels with [ArgumentError]. A seam is not automatically inset;
/// callers derive it from the same outline and reserve thread/relief padding.
Path runningStitchPath(
  Path source, {
  required double dash,
  required double gap,
}) {
  return spanPath(pathSpans(checkedPathMetrics(source), dash: dash, gap: gap));
}

/// Paints a running stitch with optional illustrative puncture compression.
///
/// [compression] is 0..1, a shading strength, not physical depth or tension.
/// This does not displace the weave or simulate a needle. [width] is 0.5..8
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
  Offset light = const Offset(-1, -1),
}) {
  validateThreadPaint(width, compression, light);
  final stitches = runningStitchPath(seam, dash: dash, gap: gap);
  paintThreadGeometry(
    canvas,
    stitches,
    thread: thread,
    width: width,
    compression: compression,
    light: light,
  );
}
