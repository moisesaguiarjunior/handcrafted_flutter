import 'dart:math' as math;
import 'dart:ui' show PathMetric;

import 'package:flutter/painting.dart';

/// Shared work/coordinate validation for stitches and drawn strokes.
List<PathMetric> checkedPathMetrics(Path source) {
  final bounds = source.getBounds();
  final metrics = source.computeMetrics().take(33).toList();
  if (![
        bounds.left,
        bounds.top,
        bounds.right,
        bounds.bottom,
      ].every((n) => n.isFinite) ||
      metrics.length > 32 ||
      metrics.any((m) => !m.length.isFinite) ||
      metrics.fold<double>(0, (n, m) => n + m.length) > 8192) {
    throw ArgumentError(
      'Expected finite bounds, at most 32 contours and 8192 logical pixels',
    );
  }
  return metrics;
}

/// An arc-length interval on an already validated contour.
typedef PathSpan = ({PathMetric metric, double start, double end});

/// Pattern phase restarts per contour; progress traverses all contours in order.
List<PathSpan> pathSpans(
  List<PathMetric> metrics, {
  double? dash,
  double gap = 4,
  double progress = 1,
}) {
  if (!progress.isFinite ||
      progress < 0 ||
      progress > 1 ||
      (dash != null && (!dash.isFinite || dash < .5)) ||
      !gap.isFinite ||
      gap < .5) {
    throw ArgumentError('Expected progress 0..1 and dash/gap at least 0.5');
  }
  var remaining = metrics.fold<double>(0, (n, m) => n + m.length) * progress;
  final spans = <PathSpan>[];
  for (final metric in metrics) {
    if (metric.length == 0) continue;
    // At completion, subtraction rounding must not trim or drop tiny contours.
    final visible = progress == 1
        ? metric.length
        : math.min(remaining, metric.length);
    if (visible <= 0) break;
    if (dash == null) {
      spans.add((metric: metric, start: 0, end: visible));
    } else {
      for (var d = 0.0; d < visible; d += dash + gap) {
        spans.add((metric: metric, start: d, end: math.min(d + dash, visible)));
      }
    }
    remaining -= metric.length;
  }
  return spans;
}

/// Collects independent visible intervals without bridging their gaps.
Path spanPath(List<PathSpan> spans, {bool preserveClosed = false}) {
  final path = Path();
  for (final span in spans) {
    final segment = span.metric.extractPath(span.start, span.end);
    if (preserveClosed &&
        span.start == 0 &&
        span.metric.isClosed &&
        span.end == span.metric.length) {
      segment.close();
    }
    path.addPath(segment, Offset.zero);
  }
  return path;
}
