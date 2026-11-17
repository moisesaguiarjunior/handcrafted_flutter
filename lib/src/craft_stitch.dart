import 'dart:math' as math;
import 'dart:ui' show Tangent;

import 'package:flutter/painting.dart';

import 'path_geometry.dart';
import 'running_stitch.dart';
import 'thread_paint.dart';

part 'stitch_frame.dart';

/// Surface thread patterns following a caller-prepared seam.
enum CraftStitchKind {
  /// Short visible spans with gaps.
  running,

  /// Contiguous curved segments with punctures at their boundaries.
  backstitch,

  /// Edge rail and transverse stitch on a caller-selected side.
  blanket,

  /// Closed lens-shaped links between seam stations.
  chain,

  /// Two crossing threads per seam interval.
  cross,

  /// Longer visible spans with short gaps.
  basting,
}

/// Prepares illustrative thread geometry along an open or closed seam.
///
/// [pitch] is a nominal interval (4..48 logical pixels); [depth] is transverse
/// reach (1..32). [side] is 1 or -1, selecting the clockwise screen-space normal
/// for blanket stitches. It does not infer inside/outside from a silhouette.
/// Chain and cross are centered on the seam. Closed contours distribute cells
/// evenly to avoid a partial terminal motif; open contours do likewise. Closed
/// chain/cross contours use at least three cells, counted in the preflight budget,
/// so a short closed seam does not collapse a link/cross onto its start point.
/// Running/basting retain native arc-length spans and their final short span.
///
/// Shared input limits are 32 contours / 8192 arc length, with coordinates within
/// +/-8192; output is bounded to 1024 cells, 3072 contours and 32768 arc length.
/// Invalid input/budget throws before painting. Zero-length contours are omitted.
/// No smoothing, exact thread crossings, needle physics or weave displacement is
/// inferred. Prepare outside paint and invalidate when seam or parameters change.
/// Reserve depth + four thread widths from a substrate edge, and clip final ink.
Path craftStitchPath(
  Path seam, {
  CraftStitchKind kind = CraftStitchKind.running,
  double pitch = 12,
  double depth = 6,
  int side = 1,
}) {
  if (!pitch.isFinite ||
      pitch < 4 ||
      pitch > 48 ||
      !depth.isFinite ||
      depth < 1 ||
      depth > 32 ||
      (side != 1 && side != -1)) {
    throw ArgumentError('Expected pitch 4..48, depth 1..32 and side +/-1');
  }
  final metrics = checkedPathMetrics(seam);
  final bounds = seam.getBounds();
  if ([
    bounds.left,
    bounds.top,
    bounds.right,
    bounds.bottom,
  ].any((v) => v.abs() > 8192)) {
    throw ArgumentError('Expected seam coordinates within +/-8192');
  }
  final cells = metrics.fold<int>(
    0,
    (n, m) => n + _cellCount(m.length, m.isClosed, kind, pitch),
  );
  if (cells > 1024) throw ArgumentError('Stitches exceed 1024 cells');
  if (kind == CraftStitchKind.running || kind == CraftStitchKind.basting) {
    final ratio = kind == CraftStitchKind.basting ? .8 : .55;
    final result = runningStitchPath(
      seam,
      dash: pitch * ratio,
      gap: pitch * (1 - ratio),
    );
    _checkOutput(result);
    return result;
  }
  final result = Path();
  for (final metric in metrics) {
    if (metric.length == 0) continue;
    final count = _cellCount(metric.length, metric.isClosed, kind, pitch);
    for (var i = 0; i < count; i++) {
      final start = metric.length * i / count;
      final end = metric.length * (i + 1) / count;
      final a = metric.getTangentForOffset(start)!;
      final b = metric.getTangentForOffset(end)!;
      final mid = metric.getTangentForOffset((start + end) / 2)!;
      final na = Offset(-a.vector.dy, a.vector.dx);
      final nb = Offset(-b.vector.dy, b.vector.dx);
      final normal = Offset(-mid.vector.dy, mid.vector.dx);
      void line(Offset p, Offset q) => result
        ..moveTo(p.dx, p.dy)
        ..lineTo(q.dx, q.dy);
      switch (kind) {
        case CraftStitchKind.backstitch:
          final segment = metric.extractPath(start, end);
          if (metric.isClosed && count == 1) segment.close();
          result.addPath(segment, Offset.zero);
        case CraftStitchKind.blanket:
          final spoke = b.position + nb * depth * side.toDouble();
          result.addPath(metric.extractPath(start, end), Offset.zero);
          line(b.position, spoke);
        case CraftStitchKind.chain:
          final upper = mid.position + normal * depth;
          final lower = mid.position - normal * depth;
          result
            ..moveTo(a.position.dx, a.position.dy)
            ..quadraticBezierTo(
              upper.dx,
              upper.dy,
              b.position.dx,
              b.position.dy,
            )
            ..quadraticBezierTo(
              lower.dx,
              lower.dy,
              a.position.dx,
              a.position.dy,
            )
            ..close();
        case CraftStitchKind.cross:
          line(a.position - na * depth / 2, b.position + nb * depth / 2);
          line(a.position + na * depth / 2, b.position - nb * depth / 2);
        case CraftStitchKind.running:
        case CraftStitchKind.basting:
          throw StateError(
            'Span-based stitches are handled before cell geometry',
          );
      }
    }
  }
  _checkOutput(result);
  return result;
}

int _cellCount(double length, bool closed, CraftStitchKind kind, double pitch) {
  if (length == 0) return 0;
  final minimum =
      closed && (kind == CraftStitchKind.chain || kind == CraftStitchKind.cross)
      ? 3
      : 1;
  return math.max(minimum, (length / pitch).ceil());
}

void _checkOutput(Path result) {
  final metrics = result.computeMetrics().take(3073).toList();
  if (metrics.length > 3072 ||
      metrics.any((m) => !m.length.isFinite) ||
      metrics.fold<double>(0, (n, m) => n + m.length) > 32768) {
    throw ArgumentError(
      'Stitch output exceeds 3072 contours or 32768 arc length',
    );
  }
}

/// Paints a patterned seam with the same thread/illustrative punctures as running.
///
/// Parameters and output budgets are checked before any drawing. [compression]
/// is shading strength, not physical depth. [pucker] 0..1 adds local gathering
/// shading multiplied by compression; reserve width * 7 and clip to cloth. Punctures mark generated contour ends;
/// closed links meet at their shared anchor. Behind-fabric thread is not modeled.
/// Caller owns clipping, silhouette clearance and native controls. [progress]
/// is 0..1 in generated thread order; partial tips are not new punctures.
/// The default completes the original static geometry. Use [CraftStitchFrame]
/// to reuse prepared geometry and obtain a caller-owned thread-tip position.
void paintCraftStitch(
  Canvas canvas,
  Path seam, {
  required Color thread,
  CraftStitchKind kind = CraftStitchKind.running,
  double pitch = 12,
  double depth = 6,
  int side = 1,
  double width = 1.5,
  double compression = .6,
  double pucker = 0,
  Offset light = const Offset(-1, -1),
  double progress = 1,
}) {
  if (!progress.isFinite || progress < 0 || progress > 1) {
    throw ArgumentError('Expected progress 0..1');
  }
  validateThreadPaint(width, compression, light, pucker: pucker);
  final stitches = craftStitchPath(
    seam,
    kind: kind,
    pitch: pitch,
    depth: depth,
    side: side,
  );
  if (progress != 1) {
    CraftStitchFrame.sample(stitches, progress: progress).paint(
      canvas,
      thread: thread,
      width: width,
      compression: compression,
      pucker: pucker,
      light: light,
    );
    return;
  }
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
