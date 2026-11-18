import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

import 'craft_stroke.dart';
import 'path_geometry.dart';

part 'craft_band.dart';

/// Bounded surface height profiles, independent of substrate grain.
enum CraftVolumeProfile {
  /// Thin flat face with a short rounded cut edge.
  sheet,

  /// Broader rolled edge, domed face and small pressure depressions.
  rounded,
}

/// Explicit directional illumination in the current piece coordinate system.
class CraftLight {
  /// Incoming x/y direction and positive elevation; no clock or global state.
  CraftLight({
    this.x = -.65,
    this.y = -.75,
    this.z = 1,
    this.ambient = .65,
    this.direct = .43,
    this.softness = .25,
    this.warmth = .4,
  }) {
    if (![
          x,
          y,
          z,
          ambient,
          direct,
          softness,
          warmth,
        ].every((v) => v.isFinite) ||
        x * x + y * y > 8 + 1e-9 ||
        z < .2 ||
        z > 2 ||
        ambient < 0 ||
        ambient > 1 ||
        direct < 0 ||
        direct > 1 ||
        softness < 0 ||
        softness > 1 ||
        warmth < 0 ||
        warmth > 1) {
      throw ArgumentError('Invalid craft light');
    }
  }

  /// Incoming direction; z is always positive.
  final double x, y, z;

  /// Neutral environmental light, 0..1.
  final double ambient;

  /// Directional strength, 0..1.
  final double direct;

  /// Broadens diffuse response, 0..1.
  final double softness;

  /// Soft warm light tint, 0..1.
  final double warmth;

  /// Converts a shared incoming light to a piece rotated in the scene plane.
  /// Translation does not change a directional source; scale is uniform here.
  CraftLight inLocalSpace(double rotation) {
    if (!rotation.isFinite) throw ArgumentError('Expected finite rotation');
    final c = math.cos(rotation), s = math.sin(rotation);
    return CraftLight(
      x: x * c + y * s,
      y: -x * s + y * c,
      z: z,
      ambient: ambient,
      direct: direct,
      softness: softness,
      warmth: warmth,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is CraftLight &&
      x == other.x &&
      y == other.y &&
      z == other.z &&
      ambient == other.ambient &&
      direct == other.direct &&
      softness == other.softness &&
      warmth == other.warmth;
  @override
  int get hashCode => Object.hash(x, y, z, ambient, direct, softness, warmth);

  /// Existing relief accepts only the planar direction, not light elevation.
  Offset get planar =>
      x * x + y * y < .000001 ? const Offset(-1, -1) : Offset(x, y);
}

/// Prepared bounded distance/height/normal field for one original closed cut.
///
/// This preparation samples contours at <=3px and a fixed 2px grid. Bounds <=320
/// per axis, at most 320 contour segments and 26244 grid stations. Geometry and
/// _normals survive light changes. Height-field shading is approximate, with an opaque-substrate requirement.
class CraftVolume {
  /// Copies and validates a cut before preparing its material profile.
  CraftVolume(
    Path source,
    this.profile, {
    int seed = 71,
    double? height,
    double? bevel,
  }) : thickness = height ?? (profile == CraftVolumeProfile.sheet ? 3 : 10),
       bevel = bevel ?? (profile == CraftVolumeProfile.sheet ? 4 : 16) {
    if (!thickness.isFinite ||
        thickness < .5 ||
        thickness > 24 ||
        !this.bevel.isFinite ||
        this.bevel < 1 ||
        this.bevel > 32) {
      throw ArgumentError('Expected height .5..24 and bevel 1..32');
    }
    _outline = trimCraftPath(source, progress: 1);
    bounds = _outline.getBounds();
    final metrics = _outline.computeMetrics().toList();
    if (bounds.width > 320 ||
        bounds.height > 320 ||
        [
          bounds.left,
          bounds.top,
          bounds.right,
          bounds.bottom,
        ].any((v) => v.abs() > 512) ||
        metrics.any((m) => !m.isClosed)) {
      throw ArgumentError('Expected a closed cut up to 320px per axis');
    }
    final edges = <(Offset, Offset)>[];
    for (final m in metrics) {
      final count = math.max(3, (m.length / 3).ceil());
      if (edges.length + count > 320) {
        throw ArgumentError('Cut exceeds 320 segments');
      }
      final points = [
        for (var i = 0; i < count; i++)
          m.getTangentForOffset(m.length * i / count)!.position,
      ];
      for (var i = 0; i < count; i++) {
        edges.add((points[i], points[(i + 1) % count]));
      }
    }
    _columns = (bounds.width / 2).ceil() + 2;
    _rows = (bounds.height / 2).ceil() + 2;
    final heights = Float32List(_columns * _rows);
    final random = math.Random(seed);
    final dents = List.generate(
      3,
      (_) => Offset(
        bounds.left + bounds.width * (.25 + random.nextDouble() * .5),
        bounds.top + bounds.height * (.25 + random.nextDouble() * .5),
      ),
    );
    for (var y = 0; y < _rows; y++) {
      for (var x = 0; x < _columns; x++) {
        final p = _point(x, y);
        if (!_outline.contains(p)) continue;
        var squared = double.infinity;
        for (final (a, b) in edges) {
          final d = b - a;
          final t = d.distanceSquared == 0
              ? 0.0
              : (((p - a).dx * d.dx + (p - a).dy * d.dy) / d.distanceSquared)
                    .clamp(0.0, 1.0);
          squared = math.min(squared, (p - (a + d * t)).distanceSquared);
        }
        final distance = math.sqrt(squared);
        final t = (distance / this.bevel).clamp(0.0, 1.0);
        var height = thickness * math.sin(t * math.pi / 2);
        if (profile == CraftVolumeProfile.rounded) {
          final q = p - bounds.center;
          height *=
              1 +
              .06 *
                  math.exp(
                    -q.distanceSquared /
                        (bounds.shortestSide * bounds.shortestSide * .18),
                  );
          for (final dent in dents) {
            final d = p - dent;
            height *=
                1 - .018 * math.exp(-(d.dx * d.dx / 120 + d.dy * d.dy / 80));
          }
        }
        heights[y * _columns + x] = height;
      }
    }
    for (
      var pass = 0;
      profile == CraftVolumeProfile.rounded && pass < 3;
      pass++
    ) {
      final smooth = Float32List(heights.length);
      for (var y = 1; y < _rows - 1; y++) {
        for (var x = 1; x < _columns - 1; x++) {
          var sum = 0.0;
          for (var dy = -1; dy <= 1; dy++) {
            for (var dx = -1; dx <= 1; dx++) {
              sum +=
                  heights[(y + dy) * _columns + x + dx] *
                  (dx == 0 ? 2 : 1) *
                  (dy == 0 ? 2 : 1);
            }
          }
          smooth[y * _columns + x] = sum / 16;
        }
      }
      heights.setAll(0, smooth);
    }
    _positions = Float32List(_columns * _rows * 2);
    for (var y = 0; y < _rows; y++) {
      for (var x = 0; x < _columns; x++) {
        final p = _point(x, y), i = (y * _columns + x) * 2;
        _positions[i] = p.dx;
        _positions[i + 1] = p.dy;
      }
    }
    _indices = Uint16List((_columns - 1) * (_rows - 1) * 6);
    var cursor = 0;
    for (var y = 0; y < _rows - 1; y++) {
      for (var x = 0; x < _columns - 1; x++) {
        final i = y * _columns + x;
        for (final v in [
          i,
          i + 1,
          i + _columns,
          i + 1,
          i + _columns + 1,
          i + _columns,
        ]) {
          _indices[cursor++] = v;
        }
      }
    }
    _normals = Float32List(_columns * _rows * 3);
    double h(int x, int y) => x < 0 || y < 0 || x >= _columns || y >= _rows
        ? 0
        : heights[y * _columns + x];
    for (var y = 0; y < _rows; y++) {
      for (var x = 0; x < _columns; x++) {
        final dx = (h(x + 1, y) - h(x - 1, y)) / 4,
            dy = (h(x, y + 1) - h(x, y - 1)) / 4;
        final length = math.sqrt(dx * dx + dy * dy + 1),
            i = (y * _columns + x) * 3;
        _normals[i] = -dx / length;
        _normals[i + 1] = -dy / length;
        _normals[i + 2] = 1 / length;
      }
    }
  }

  /// Caller cut copied by the preparation; caller owns its final clipping.
  late final Path _outline;

  /// Independent copy of the prepared cut, for the caller's substrate paint.
  Path get outline => Path.from(_outline);

  /// Preparation extent, independent of light.
  late final Rect bounds;

  /// Selected height profile.
  final CraftVolumeProfile profile;

  /// Nominal edge-to-face height in logical pixels, not a measurement in mm.
  final double thickness;

  /// Width of the edge-to-face transition, independent of grain.
  final double bevel;

  /// Number of prepared grid stations horizontally and vertically.
  late final int _columns, _rows;

  /// Unit normals in an ordinary Dart buffer; no image/native resource is owned.
  late final Float32List _normals;

  /// Fixed shared-edge grid positions and triangle indices, prepared once.
  late final Float32List _positions;

  /// Indices stay below 26244, within the native 16-bit grid range.
  late final Uint16List _indices;
  Offset _point(int x, int y) =>
      Offset(bounds.left - 1 + x * 2, bounds.top - 1 + y * 2);

  /// Paints smooth lighting into existing grain using two shared-edge meshes.
  /// Requires an opaque painted substrate; this composition is not alpha preserving.
  /// Positions/indices/normals are reused. Temporary native vertices are always
  /// disposed after recording, including exceptions; no image/cache/layer/clock.
  void shade(Canvas canvas, CraftLight light) {
    if (bounds.isEmpty) return;
    _paintVolumeMesh(canvas, _outline, _positions, _indices, _normals, light);
  }

  /// Separates contact from lifted projection; optional receiver clips overlap.
  void shadow(
    Canvas canvas,
    CraftLight light, {
    Path? receiver,
    double lift = 0,
  }) {
    _paintVolumeShadow(
      canvas,
      _outline,
      thickness,
      light,
      receiver: receiver,
      lift: lift,
    );
  }
}

void _paintVolumeMesh(
  Canvas canvas,
  Path outline,
  Float32List positions,
  Uint16List indices,
  Float32List normals,
  CraftLight light,
) {
  final dark = Int32List(normals.length ~/ 3),
      bright = Int32List(normals.length ~/ 3);
  final length = math.sqrt(
    light.x * light.x + light.y * light.y + light.z * light.z,
  );
  final lx = light.x / length, ly = light.y / length, lz = light.z / length;
  for (var i = 0; i < normals.length ~/ 3; i++) {
    final dot =
        (normals[i * 3] * lx +
                normals[i * 3 + 1] * ly +
                normals[i * 3 + 2] * lz)
            .clamp(0.0, 1.0);
    final diffuse =
        dot * (1 - light.softness) + (dot * .5 + .5) * light.softness;
    final directional = light.direct * diffuse;
    final red = light.ambient + directional;
    final green = light.ambient + directional * (1 - light.warmth * .08);
    final blue = light.ambient + directional * (1 - light.warmth * .22);
    dark[i] = Color.fromRGBO(
      (255 * red.clamp(.35, 1.0)).round(),
      (255 * green.clamp(.35, 1.0)).round(),
      (255 * blue.clamp(.35, 1.0)).round(),
      1,
    ).toARGB32();
    bright[i] = Color.fromRGBO(
      (255 * (red - 1).clamp(0.0, .18)).round(),
      (255 * (green - 1).clamp(0.0, .18)).round(),
      (255 * (blue - 1).clamp(0.0, .18)).round(),
      1,
    ).toARGB32();
  }
  final meshes = <ui.Vertices>[];
  try {
    meshes.add(
      ui.Vertices.raw(
        ui.VertexMode.triangles,
        positions,
        colors: dark,
        indices: indices,
      ),
    );
    meshes.add(
      ui.Vertices.raw(
        ui.VertexMode.triangles,
        positions,
        colors: bright,
        indices: indices,
      ),
    );
    canvas.save();
    try {
      canvas.clipPath(outline);
      canvas.drawVertices(
        meshes[0],
        BlendMode.dst,
        Paint()..blendMode = BlendMode.modulate,
      );
      canvas.drawVertices(
        meshes[1],
        BlendMode.dst,
        Paint()..blendMode = BlendMode.screen,
      );
    } finally {
      canvas.restore();
    }
  } finally {
    for (final mesh in meshes) {
      mesh.dispose();
    }
  }
}

void _paintVolumeShadow(
  Canvas canvas,
  Path outline,
  double thickness,
  CraftLight light, {
  Path? receiver,
  double lift = 0,
  double softness = 1,
}) {
  if (!softness.isFinite || softness < .25 || softness > 4) {
    throw ArgumentError('Expected shadow softness .25..4');
  }
  if (!lift.isFinite || lift < 0 || lift > 24) {
    throw ArgumentError('Expected lift 0..24');
  }
  if (receiver != null) checkedPathMetrics(receiver);
  if (outline.getBounds().isEmpty) return;
  canvas.save();
  try {
    if (receiver != null) canvas.clipPath(receiver);
    final offset = Offset(-light.x / light.z, -light.y / light.z);
    canvas.drawPath(
      outline.shift(offset * (thickness * .22)),
      Paint()
        ..color = const Color(0xFF3F2A1E).withValues(
          alpha: .14 * (light.ambient + light.direct).clamp(0.0, 1.0),
        )
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 1.1 * softness),
    );
    canvas.drawPath(
      outline.shift(offset * (thickness * .5 + lift)),
      Paint()
        ..color = const Color(0xFF4B3528).withValues(
          alpha: .24 * light.direct / (light.ambient + light.direct + 1e-9),
        )
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          (2.5 + lift * .3) * softness,
        ),
    );
  } finally {
    canvas.restore();
  }
}
