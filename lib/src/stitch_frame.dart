part of 'craft_stitch.dart';

/// A bounded snapshot of prepared thread at an explicit completion fraction.
///
/// Supply output from [craftStitchPath]. Geometry is copied; later mutations of
/// the supplied path cannot change this frame. A partial strand has a starting
/// puncture but no hole at the travelling tip. No dynamic thread or cloth physics.
final class CraftStitchFrame {
  CraftStitchFrame._(this._path, this._punctures, this.tip);

  /// Samples generated thread order, not seam distance. Progress is 0..1.
  /// Prepared input is limited to 3072 contours / 32768 arc units, with finite
  /// bounds within +/-8224 (the seam coordinate budget plus transverse depth).
  factory CraftStitchFrame.sample(Path prepared, {required double progress}) {
    if (!progress.isFinite || progress < 0 || progress > 1) {
      throw ArgumentError('Expected progress 0..1');
    }
    _checkOutput(prepared);
    final bounds = prepared.getBounds();
    if ([
      bounds.left,
      bounds.top,
      bounds.right,
      bounds.bottom,
    ].any((v) => !v.isFinite || v.abs() > 8224)) {
      throw ArgumentError(
        'Expected finite prepared thread bounds within +/-8224',
      );
    }
    final metrics = prepared.computeMetrics().toList();
    var remaining = metrics.fold<double>(0, (n, m) => n + m.length) * progress;
    final path = Path()..fillType = prepared.fillType;
    final holes = <Offset>[];
    Tangent? tip;
    for (final metric in metrics) {
      if (metric.length == 0) continue;
      final visible = progress == 1
          ? metric.length
          : math.min(remaining, metric.length);
      if (visible <= 0) break;
      final segment = metric.extractPath(0, visible);
      if (visible == metric.length && metric.isClosed) segment.close();
      path.addPath(segment, Offset.zero);
      final start = metric.getTangentForOffset(0);
      if (start != null) holes.add(start.position);
      if (visible == metric.length) {
        final end = metric.getTangentForOffset(metric.length);
        if (end != null) holes.add(end.position);
      }
      tip = metric.getTangentForOffset(visible);
      remaining -= metric.length;
    }
    return CraftStitchFrame._(
      progress == 1 ? Path.from(prepared) : path,
      List.unmodifiable(holes),
      progress == 1 ? null : tip,
    );
  }

  final Path _path;
  final List<Offset> _punctures;

  /// Travelling thread end, absent before drawing and after completion.
  final Tangent? tip;

  /// A caller-owned copy of the visible geometry.
  Path get path => Path.from(_path);

  /// Paints the same thread shading as [paintCraftStitch], with actual anchors.
  /// The moving tip is not painted as a new puncture at each sampled frame.
  /// [pucker] 0..1 adds broader crease shading at actual holes, multiplied by
  /// compression. Reserve width * 7 and clip to the substrate. No displacement.
  /// Inset [relief] paints the visible geometry as pressed marks, without
  /// punctures or gathering; compression controls their narrow lip contrast.
  void paint(
    Canvas canvas, {
    required Color thread,
    double width = 1.5,
    double compression = .6,
    double pucker = 0,
    CraftReliefKind relief = CraftReliefKind.raised,
    Offset light = const Offset(-1, -1),
  }) {
    validateThreadPaint(width, compression, light, pucker: pucker);
    paintThreadGeometry(
      canvas,
      _path,
      thread: thread,
      width: width,
      compression: compression,
      pucker: pucker,
      relief: relief,
      light: light,
      punctures: _punctures,
    );
  }
}
