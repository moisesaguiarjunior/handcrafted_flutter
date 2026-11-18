part of 'craft_volume.dart';

/// One piecewise-linear width key, measured by normalized centerline arc length.
/// Positive follows (-tangent.dy, tangent.dx); both distances are positive.
/// Validated by [CraftBand]: endpoints 0/1, strictly ordered, at most 128 keys,
/// each side >=2 pixels and combined width <=96 pixels.
class CraftBandWidth {
  /// Defines independently authored distances on either side of the centerline.
  const CraftBandWidth({
    required this.progress,
    required this.positive,
    required this.negative,
  });

  /// Normalized arc-length position, 0..1.
  final double progress;

  /// Distance along the positive canvas normal, in logical pixels.
  final double positive;

  /// Distance along the negative canvas normal, in logical pixels.
  final double negative;
}

/// Prepared open or closed ribbon with a gently rounded cross-section.
///
/// A single smooth path follows the shared 8192-length/coordinate budget, with at
/// most 2048 intervals and nine cross-section vertices per station. Tight bends
/// and self-crossings can overlap: keep the bend radius above the inward-side
/// distance (or the larger side distance as a conservative bound).
/// Preparation and station normals are independent of light and substrate grain.
class CraftBand {
  /// Prepares the centerline once, outside paint.
  CraftBand(
    Path path, {
    this.width = 28,
    this.height = 2,
    this.sampleSpacing = 3,
    List<CraftBandWidth>? widthProfile,
  }) : widthProfile = _copyBandWidths(widthProfile) {
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
    if (this.widthProfile.isNotEmpty) {
      if (this.widthProfile.length < 2 ||
          this.widthProfile.length > 128 ||
          this.widthProfile.first.progress != 0 ||
          this.widthProfile.last.progress != 1) {
        throw ArgumentError(
          'Expected 2..128 width keys including endpoints0/1',
        );
      }
      var previous = -1.0;
      for (final key in this.widthProfile) {
        if (![
              key.progress,
              key.positive,
              key.negative,
            ].every((v) => v.isFinite) ||
            key.progress <= previous ||
            key.progress < 0 ||
            key.progress > 1 ||
            key.positive < 2 ||
            key.negative < 2 ||
            key.positive + key.negative > 96) {
          throw ArgumentError(
            'Expected ordered width keys, sides>=2, total<=96',
          );
        }
        previous = key.progress;
      }
    }
    _centerline = trimCraftPath(path, progress: 1);
    final metrics = checkedPathMetrics(_centerline);
    if (metrics.length != 1 || metrics.single.length == 0) {
      throw ArgumentError('Expected one nonempty centerline');
    }
    _metric = metrics.single;
    _closed = _metric.isClosed;
    if (_closed &&
        this.widthProfile.isNotEmpty &&
        (this.widthProfile.first.positive != this.widthProfile.last.positive ||
            this.widthProfile.first.negative !=
                this.widthProfile.last.negative)) {
      throw ArgumentError('Closed band widths must agree at the join');
    }
    final maxWidth = this.widthProfile.isEmpty
        ? width / 2
        : this.widthProfile
              .map((k) => math.max(k.positive, k.negative))
              .reduce(math.max);
    final bounds = _centerline.getBounds();
    if ([
      bounds.left,
      bounds.top,
      bounds.right,
      bounds.bottom,
    ].any((v) => v.abs() > 8192 - maxWidth)) {
      throw ArgumentError('Expected band coordinates within +/-8192');
    }
    final count = (_metric.length / sampleSpacing).ceil();
    if (count > 2048) {
      throw ArgumentError('Band exceeds 2048 intervals');
    }
    final stations = <double>{
      for (var i = 0; i <= count; i++) i / count,
      for (final key in this.widthProfile) key.progress,
    }.toList()..sort();
    if (stations.length > 2049) {
      throw ArgumentError('Band exceeds 2048 intervals');
    }
    _points = [
      for (var i = 0; i < stations.length; i++)
        _metric.getTangentForOffset(
          this.widthProfile.isEmpty
              ? _metric.length * i / count
              : _metric.length * stations[i],
        )!,
    ];
    if (_closed) _points[_points.length - 1] = _points.first;
    _widths = [for (final progress in stations) _widthAt(progress)];
    for (final side in [true, false]) {
      final metrics = edge(positive: side).computeMetrics().toList();
      if (metrics.length != 1 || metrics.single.length == 0) {
        throw ArgumentError('Degenerate band rail');
      }
    }
    _outline = edge(positive: true);
    if (_closed) {
      _outline.addPath(edge(positive: false), Offset.zero);
      _outline.fillType = PathFillType.evenOdd;
    } else {
      for (var i = _points.length - 1; i >= 0; i--) {
        final t = _points[i], n = Offset(-t.vector.dy, t.vector.dx);
        final p = t.position - n * _widths[i].$2;
        _outline.lineTo(p.dx, p.dy);
      }
      _outline.close();
    }
    const cross = 9;
    _positions = Float32List(_points.length * cross * 2);
    _normals = Float32List(_points.length * cross * 3);
    final heights = this.widthProfile.isEmpty
        ? null
        : Float64List(_points.length * cross);
    for (var i = 0; i < _points.length; i++) {
      final t = _points[i], n = Offset(-t.vector.dy, t.vector.dx);
      final (positive, negative) = _widths[i];
      final bevel = math.min(3.0, math.min(positive, negative));
      final faceNegative = negative - bevel, facePositive = positive - bevel;
      final crossOffsets = [
        -negative,
        -negative + bevel * .35,
        -faceNegative,
        -faceNegative * .5,
        0.0,
        facePositive * .5,
        facePositive,
        positive - bevel * .35,
        positive,
      ];
      for (var j = 0; j < cross; j++) {
        final offset = crossOffsets[j], p = t.position + n * offset;
        final v = i * cross + j;
        _positions[v * 2] = p.dx;
        _positions[v * 2 + 1] = p.dy;
        final distance = offset < 0 ? negative + offset : positive - offset;
        if (heights != null) {
          heights[v] = distance >= bevel
              ? height
              : height * math.sin(distance / bevel * math.pi / 2);
        }
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
    // Profile changes also tilt the surface along the curve. Constant-width
    // normals retain the original renderer exactly.
    if (heights != null) {
      for (var i = 0; i < _points.length; i++) {
        final before = i == 0 ? (_closed ? _points.length - 2 : 0) : i - 1;
        final after = i == _points.length - 1 ? (_closed ? 1 : i) : i + 1;
        final n = Offset(-_points[i].vector.dy, _points[i].vector.dx);
        for (var j = 0; j < cross; j++) {
          final v = i * cross + j,
              a = before * cross + j,
              b = after * cross + j;
          final dx = _positions[b * 2] - _positions[a * 2];
          final dy = _positions[b * 2 + 1] - _positions[a * 2 + 1];
          final dz = heights[b] - heights[a];
          final slope =
              -(_normals[v * 3] * n.dx + _normals[v * 3 + 1] * n.dy) /
              _normals[v * 3 + 2];
          var nx = dy * slope - dz * n.dy;
          var ny = dz * n.dx - dx * slope;
          var nz = dx * n.dy - dy * n.dx;
          if (nz < 0) {
            nx = -nx;
            ny = -ny;
            nz = -nz;
          }
          final length = math.sqrt(nx * nx + ny * ny + nz * nz);
          if (length > 1e-9) {
            _normals[v * 3] = nx / length;
            _normals[v * 3 + 1] = ny / length;
            _normals[v * 3 + 2] = nz / length;
          }
        }
      }
    }
    final intervals = _points.length - 1;
    _indices = Uint16List(intervals * (cross - 1) * 6);
    var cursor = 0;
    for (var i = 0; i < intervals; i++) {
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

  /// Immutable width keys; empty retains the constant [width] geometry.
  final List<CraftBandWidth> widthProfile;

  /// Apparent thickness, logical pixels, independent of shadow lift and grain.
  final double height;

  /// Maximum arc-length interval used during preparation.
  final double sampleSpacing;
  late final Path _centerline, _outline;
  late final ui.PathMetric _metric;
  late final bool _closed;
  late final List<(double, double)> _widths;
  late final List<ui.Tangent> _points;
  late final Float32List _positions, _normals;
  late final Uint16List _indices;

  /// Copied ribbon cut for substrate painting/clipping; closed curves have a hole.
  Path get outline => Path.from(_outline);

  /// Copy of the source curve, suitable for the existing explicit-progress tools.
  Path get centerline => Path.from(_centerline);

  /// A rail at signed distance from the center, for a seam or attached trim.
  /// Positive offset follows (-tangent.dy, tangent.dx) in canvas coordinates.
  Path rail(double offset) {
    if (!offset.isFinite ||
        _widths.any((w) => offset > w.$1 || -offset > w.$2)) {
      throw ArgumentError('Rail lies outside band');
    }
    return _offsetPath(offset);
  }

  (double, double) _widthAt(double progress) {
    if (widthProfile.isEmpty) return (width / 2, width / 2);
    for (var i = 1; i < widthProfile.length; i++) {
      final a = widthProfile[i - 1], b = widthProfile[i];
      if (progress <= b.progress) {
        final t = (progress - a.progress) / (b.progress - a.progress);
        return (
          a.positive + (b.positive - a.positive) * t,
          a.negative + (b.negative - a.negative) * t,
        );
      }
    }
    return (widthProfile.last.positive, widthProfile.last.negative);
  }

  /// Prepared edge following the actual width profile, optionally inset.
  /// Positive selects (-tangent.dy, tangent.dx). Insets must fit every station.
  /// Closed centerlines produce closed edges with the same continuous join.
  Path edge({bool positive = true, double inset = 0}) {
    if (!inset.isFinite ||
        inset < 0 ||
        _widths.any((w) => inset > (positive ? w.$1 : w.$2))) {
      throw ArgumentError('Expected edge inset within every station');
    }
    final path = Path();
    for (var i = 0; i < _points.length; i++) {
      final t = _points[i], n = Offset(-t.vector.dy, t.vector.dx);
      final distance = positive
          ? _widths[i].$1 - inset
          : -_widths[i].$2 + inset;
      final p = t.position + n * distance;
      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }
    if (_closed) path.close();
    return path;
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
    if (_closed) path.close();
    return path;
  }

  /// Point and tangent by distance; caller controls progress and motion policy.
  ui.Tangent at(double progress) {
    if (!progress.isFinite || progress < 0 || progress > 1) {
      throw ArgumentError('Expected progress0..1');
    }
    if (_closed && progress == 1) return _points.first;
    return _metric.getTangentForOffset(_metric.length * progress)!;
  }

  /// Applies the same opaque-substrate lighting as [CraftVolume].
  void shade(Canvas canvas, CraftLight light) =>
      _paintVolumeMesh(canvas, _outline, _positions, _indices, _normals, light);

  /// Contact/projection shadow of the same cut, clipped to an optional receiver.
  /// [lift] is ground separation (0..24), independent of [height] (thickness).
  /// [softness] scales shadow blur (.25..4), independently of light diffusion.
  void shadow(
    Canvas canvas,
    CraftLight light, {
    Path? receiver,
    double lift = 0,
    double softness = 1,
  }) => _paintVolumeShadow(
    canvas,
    _outline,
    height,
    light,
    receiver: receiver,
    lift: lift,
    softness: softness,
  );
}

List<CraftBandWidth> _copyBandWidths(List<CraftBandWidth>? source) {
  final count = source?.length ?? 0;
  if (count < 0 || count == 1 || count > 128) {
    throw ArgumentError('Expected zero or 2..128 width keys');
  }
  // Bound both allocation and element access before touching caller data.
  return List.unmodifiable([for (var i = 0; i < count; i++) source![i]]);
}
