import 'dart:math' as math;

import 'package:clipper2/clipper2.dart' as clip;
import 'package:flutter/painting.dart';

import 'path_geometry.dart';

/// Recedes a filled closed silhouette, shrinking islands and enlarging holes.
///
/// Curves are flattened at arc-length intervals no larger than [sampleSpacing]
/// (0.25..2 logical pixels), then quantized to 1/256 pixel. This is a polygonal
/// approximation, not an exact Bezier offset. Round joins are used. Nonzero and
/// even-odd fill rules are respected before offsetting; winding is normalized.
/// Narrow regions may disappear or split. An exhausted shape returns an empty
/// path. Zero [distance] returns a fresh exact copy, including its fill rule.
///
/// Inputs must be closed, have coordinates within +/-8192, and obey the shared
/// 32-contour / 8192-length limits. Flattening accepts at most 4096 samples;
/// offset polygons accept at most 8192 vertices; the returned path also obeys
/// shared contour/length limits. Distance is finite in 0..128. Invalid
/// inputs or exhausted work budgets throw [ArgumentError] without painting.
/// Features below quantization precision are unsupported. Prepare the returned
/// path outside paint and invalidate it when silhouette, distance or spacing
/// changes. The caller owns it; no global cache or raster resource is created.
///
/// For sewing, reserve thread and puncture clearance in addition to sampling
/// error (at least width * 4 + sampleSpacing). Clip final ink to the original
/// substrate. This path does not reserve accessible space for native controls.
Path insetCraftPath(
  Path source, {
  required double distance,
  double sampleSpacing = .5,
}) {
  if (!distance.isFinite ||
      distance < 0 ||
      distance > 128 ||
      !sampleSpacing.isFinite ||
      sampleSpacing < .25 ||
      sampleSpacing > 2) {
    throw ArgumentError('Expected distance 0..128 and sampleSpacing 0.25..2');
  }
  final metrics = checkedPathMetrics(source);
  final bounds = source.getBounds();
  if (metrics.any((m) => !m.isClosed) ||
      [
        bounds.left,
        bounds.top,
        bounds.right,
        bounds.bottom,
      ].any((v) => v.abs() > 8192)) {
    throw ArgumentError(
      'Expected closed contours with coordinates within +/-8192',
    );
  }
  if (distance == 0) return Path.from(source);
  if (metrics.isEmpty || bounds.isEmpty) return Path();
  const scale = 256.0;
  final polygons = <clip.Path64>[];
  var samples = 0;
  for (final metric in metrics) {
    if (metric.length == 0) continue;
    final count = math.max(3, (metric.length / sampleSpacing).ceil());
    samples += count;
    if (samples > 4096)
      throw ArgumentError('Inset exceeds 4096 flattening samples');
    final polygon = <clip.Point64>[];
    for (var i = 0; i < count; i++) {
      final point = metric
          .getTangentForOffset(metric.length * i / count)!
          .position;
      final vertex = clip.Point64.fromDouble(
        point.dx - bounds.left,
        point.dy - bounds.top,
        scale: scale,
      );
      if (polygon.isEmpty ||
          vertex.x != polygon.last.x ||
          vertex.y != polygon.last.y) {
        polygon.add(vertex);
      }
    }
    if (polygon.length > 1 &&
        polygon.first.x == polygon.last.x &&
        polygon.first.y == polygon.last.y) {
      polygon.removeLast();
    }
    if (polygon.length < 3)
      throw ArgumentError('Contour is below inset quantization precision');
    polygons.add(polygon);
  }
  final normalized = clip.Clipper.union(
    subject: polygons,
    fillRule: source.fillType == PathFillType.evenOdd
        ? clip.FillRule.evenOdd
        : clip.FillRule.nonZero,
  );
  final inset = clip.Clipper.inflatePaths(
    paths: normalized,
    delta: -distance * scale,
    joinType: clip.JoinType.round,
    endType: clip.EndType.polygon,
    arcTolerance: sampleSpacing * scale / 4,
  );
  if (inset.fold<int>(0, (n, path) => n + path.length) > 8192) {
    throw ArgumentError('Inset exceeds 8192 output vertices');
  }
  final result = Path();
  for (final polygon in inset) {
    if (polygon.isEmpty) continue;
    result.moveTo(
      polygon.first.x / scale + bounds.left,
      polygon.first.y / scale + bounds.top,
    );
    for (final point in polygon.skip(1)) {
      result.lineTo(
        point.x / scale + bounds.left,
        point.y / scale + bounds.top,
      );
    }
    result.close();
  }
  // Keep the supplied silhouette authoritative near approximation boundaries.
  final clipped = Path.combine(PathOperation.intersect, result, source);
  checkedPathMetrics(clipped);
  return clipped;
}
