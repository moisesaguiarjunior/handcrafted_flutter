part of 'craft_volume.dart';

/// Prepared flat-ended ribbon with a gently rounded cross-section.
///
/// A single open path follows the shared 8192-length/coordinate budget, with at
/// most 2048 intervals and nine cross-section vertices per station. Tight bends
/// and self-crossings can overlap: use a radius greater than half the width.
/// Preparation and station normals are independent of light and substrate grain.
class CraftBand {
  /// Prepares the centerline once, outside paint.
  CraftBand(
    Path path, {
    this.width = 28,
    this.height = 2,
    this.sampleSpacing = 3,
  }) {
    if (!width.isFinite ||
        width < 4 ||
        width > 96 ||
        !height.isFinite ||
        height < .5 ||
        height > 8 ||
        !sampleSpacing.isFinite ||
        sampleSpacing < 1 ||
        sampleSpacing > 6) {
      throw ArgumentError('Expected width4..96, height.5..8, spacing1..6');
    }
    _centerline = trimCraftPath(path, progress: 1);
    final metrics = checkedPathMetrics(_centerline);
    if (metrics.length != 1 ||
        metrics.single.isClosed ||
        metrics.single.length == 0) {
      throw ArgumentError('Expected one nonempty open centerline');
    }
    _metric = metrics.single;
    final bounds = _centerline.getBounds();
    if ([
      bounds.left,
      bounds.top,
      bounds.right,
      bounds.bottom,
    ].any((v) => v.abs() > 8192 - width / 2)) {
      throw ArgumentError('Expected band coordinates within +/-8192');
    }
    final count = (_metric.length / sampleSpacing).ceil();
    if (count > 2048) {
      throw ArgumentError('Band exceeds 2048 intervals');
    }
    _points = [
      for (var i = 0; i <= count; i++)
        _metric.getTangentForOffset(_metric.length * i / count)!,
    ];
    _outline = _offsetPath(width / 2);
    final other = _offsetPath(-width / 2).computeMetrics().single;
    // Reverse the opposite rail so the body is a single closed cut.
    for (var i = _points.length - 1; i >= 0; i--) {
      final tangent = _points[i];
      final n = Offset(-tangent.vector.dy, tangent.vector.dx);
      final p = tangent.position - n * width / 2;
      _outline.lineTo(p.dx, p.dy);
    }
    _outline.close();
    // Force the prepared rail to remain nonempty before allocating the mesh.
    if (other.length == 0) {
      throw ArgumentError('Degenerate band rail');
    }
    const cross = 9;
    _positions = Float32List(_points.length * cross * 2);
    _normals = Float32List(_points.length * cross * 3);
    final bevel = math.min(3.0, width / 2);
    final half = width / 2, face = width / 2 - bevel;
    final crossOffsets = [
      -half,
      -half + bevel * .35,
      -face,
      -face * .5,
      0.0,
      face * .5,
      face,
      half - bevel * .35,
      half,
    ];
    for (var i = 0; i < _points.length; i++) {
      final t = _points[i], n = Offset(-t.vector.dy, t.vector.dx);
      for (var j = 0; j < cross; j++) {
        final offset = crossOffsets[j], p = t.position + n * offset;
        final v = i * cross + j;
        _positions[v * 2] = p.dx;
        _positions[v * 2 + 1] = p.dy;
        final distance = width / 2 - offset.abs();
        final slope = distance >= bevel
            ? 0.0
            : -offset.sign *
                  height *
                  math.pi /
                  (2 * bevel) *
                  math.cos(distance / bevel * math.pi / 2);
        final length = math.sqrt(1 + slope * slope);
        _normals[v * 3] = -slope * n.dx / length;
        _normals[v * 3 + 1] = -slope * n.dy / length;
        _normals[v * 3 + 2] = 1 / length;
      }
    }
    _indices = Uint16List(count * (cross - 1) * 6);
    var cursor = 0;
    for (var i = 0; i < count; i++) {
      for (var j = 0; j < cross - 1; j++) {
        final a = i * cross + j, b = a + cross;
        for (final v in [a, b, a + 1, a + 1, b, b + 1]) {
          _indices[cursor++] = v;
        }
      }
    }
  }

  /// Nominal body width, logical pixels.
  final double width;

  /// Apparent height, logical pixels, independent of grain.
  final double height;

  /// Maximum arc-length interval used during preparation.
  final double sampleSpacing;
  late final Path _centerline, _outline;
  late final ui.PathMetric _metric;
  late final List<ui.Tangent> _points;
  late final Float32List _positions, _normals;
  late final Uint16List _indices;

  /// Copy of the flat-ended closed ribbon cut for substrate painting/clipping.
  Path get outline => Path.from(_outline);

  /// Copy of the source curve, suitable for the existing explicit-progress tools.
  Path get centerline => Path.from(_centerline);

  /// A rail at signed distance from the center, for a seam or attached trim.
  /// Positive offset follows (-tangent.dy, tangent.dx) in canvas coordinates.
  Path rail(double offset) {
    if (!offset.isFinite || offset.abs() > width / 2) {
      throw ArgumentError('Rail lies outside band');
    }
    return _offsetPath(offset);
  }

  Path _offsetPath(double offset) {
    final path = Path();
    for (var i = 0; i < _points.length; i++) {
      final t = _points[i],
          p = t.position + Offset(-t.vector.dy, t.vector.dx) * offset;
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    return path;
  }

  /// Point and tangent by distance; caller controls progress and motion policy.
  ui.Tangent at(double progress) {
    if (!progress.isFinite || progress < 0 || progress > 1) {
      throw ArgumentError('Expected progress0..1');
    }
    return _metric.getTangentForOffset(_metric.length * progress)!;
  }

  /// Applies the same opaque-substrate lighting as [CraftVolume].
  void shade(Canvas canvas, CraftLight light) =>
      _paintVolumeMesh(canvas, _outline, _positions, _indices, _normals, light);

  /// Contact/projection light, clipped to an optional local receiving cut.
  void shadow(
    Canvas canvas,
    CraftLight light, {
    Path? receiver,
    double lift = 0,
  }) => _paintVolumeShadow(
    canvas,
    _outline,
    height,
    light,
    receiver: receiver,
    lift: lift,
  );
}
