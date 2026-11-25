import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

import 'material_patch.dart';
import 'showcase_theme.dart';

/// Example-only world point: positive z is height above the receiving board.
class MaterialPoint {
  /// Creates a finite authored point. Recipes stay inside a 640x360 board.
  const MaterialPoint(this.x, this.y, this.z);

  /// World coordinates in artboard units.
  final double x, y, z;

  /// Fixed oblique camera shared by surface, attachments, edges and shadow.
  Offset get screen => Offset(x, y - z * .45);

  /// Vector addition without mutable integration state.
  MaterialPoint operator +(MaterialPoint p) =>
      MaterialPoint(x + p.x, y + p.y, z + p.z);

  /// Vector subtraction.
  MaterialPoint operator -(MaterialPoint p) =>
      MaterialPoint(x - p.x, y - p.y, z - p.z);

  /// Scalar multiplication.
  MaterialPoint operator *(double s) => MaterialPoint(x * s, y * s, z * s);

  /// Dot product for directional light.
  double dot(MaterialPoint p) => x * p.x + y * p.y + z * p.z;

  /// Oriented surface normal from two edges.
  MaterialPoint cross(MaterialPoint p) =>
      MaterialPoint(y * p.z - z * p.y, z * p.x - x * p.z, x * p.y - y * p.x);

  /// Unit direction; callers only supply nondegenerate surface frames.
  MaterialPoint get unit {
    final length = math.sqrt(dot(this));
    return length < 1e-10 ? const MaterialPoint(0, 0, 1) : this * (1 / length);
  }
}

/// One rectangular source cell and its shared front/back world corners.
class MaterialCell {
  /// Corners are top-left, top-right, bottom-right, bottom-left.
  MaterialCell(
    this.source,
    List<MaterialPoint> centers,
    List<MaterialPoint> normals,
    this.thickness,
  ) {
    if (source.isEmpty ||
        source.left < 0 ||
        source.top < 0 ||
        [
          source.left,
          source.top,
          source.right,
          source.bottom,
        ].any((v) => !v.isFinite || v > 320) ||
        centers.length != 4 ||
        normals.length != 4 ||
        !thickness.isFinite ||
        thickness < .5 ||
        thickness > 4 ||
        centers.any(
          (p) =>
              ![p.x, p.y, p.z].every((v) => v.isFinite) ||
              p.x.abs() > 1024 ||
              p.y.abs() > 1024 ||
              p.z < 0 ||
              p.z > 256,
        ) ||
        normals.any(
          (p) => ![p.x, p.y, p.z].every((v) => v.isFinite) || p.dot(p) < 1e-10,
        )) {
      throw ArgumentError(
        'Expected a bounded source cell, four world frames and thickness .5..4',
      );
    }
    front = List.unmodifiable(
      List.generate(4, (i) => centers[i] + normals[i].unit * (thickness / 2)),
    );
    back = List.unmodifiable(
      List.generate(4, (i) => centers[i] - normals[i].unit * (thickness / 2)),
    );
    center = List.unmodifiable(centers);
  }

  /// Stable rectangle in the complete printed source.
  final Rect source;

  /// Constant separation between corresponding front/back vertices.
  final double thickness;

  /// Shared material mid-surface corners.
  late final List<MaterialPoint> center;

  /// Front world surface.
  late final List<MaterialPoint> front;

  /// Reverse world surface.
  late final List<MaterialPoint> back;

  /// Source corner order shared with the image transport.
  List<Offset> get uv => [
    source.topLeft,
    source.topRight,
    source.bottomRight,
    source.bottomLeft,
  ];

  /// Maps an authored material coordinate through the actual affine triangles.
  MaterialPoint map(Offset point, {bool reverse = false}) {
    final u = (point.dx - source.left) / source.width;
    final v = (point.dy - source.top) / source.height;
    final p = reverse ? back : front;
    return v <= u
        ? p[0] + (p[1] - p[0]) * (u - v) + (p[2] - p[0]) * v
        : p[0] + (p[2] - p[0]) * u + (p[3] - p[0]) * (v - u);
  }
}

/// Two fixed 2x printed faces; canonical volume models are prepared per cell size.
class PrintedMaterial {
  /// Borrows the texture owner. Only the returned source images belong here.
  PrintedMaterial(
    this.size,
    MaterialTextures textures, {
    required this.frontColor,
    required this.backColor,
    required CraftMaterial material,
    bool paper = false,
  }) {
    ui.Image? first;
    try {
      first = recordMaterialPrint(
        size,
        (c) => _print(c, textures, material, frontColor, false, paper),
      );
      reverse = recordMaterialPrint(
        size,
        (c) => _print(c, textures, material, backColor, true, paper),
      );
      front = first;
    } catch (_) {
      first?.dispose();
      rethrow;
    }
  }

  /// Source dimensions, independent of camera and frame progress.
  final Size size;

  /// Distinct faces make actual occlusion/reversal inspectable.
  final Color frontColor, backColor;

  /// Owned front image.
  late final ui.Image front;

  /// Owned reverse image.
  late final ui.Image reverse;
  final _models = <Size, CraftVolume>{};
  bool _disposed = false;

  void _print(
    Canvas canvas,
    MaterialTextures textures,
    CraftMaterial material,
    Color color,
    bool back,
    bool paper,
  ) {
    textures.paint(
      canvas,
      Path()..addRect(Offset.zero & size),
      material: material,
      color: color,
      strength: .7,
    );
    if (paper) {
      final stem = Path()
        ..moveTo(14, size.height * .8)
        ..cubicTo(
          size.width * .35,
          size.height * .15,
          size.width * .65,
          size.height * .9,
          size.width - 12,
          size.height * .25,
        );
      paintCraftStroke(
        canvas,
        stem,
        color: back ? DemoPalette.indigo : DemoPalette.sage,
        style: const CraftStrokeStyle(width: 2.2),
      );
      for (var i = 0; i < 5; i++) {
        final x = 27 + i * (size.width - 54) / 4;
        final y = size.height * (.4 + (i.isEven ? .08 : .2));
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(x, y),
            width: 13.0 + i * 2,
            height: 24.0 + (4 - i) * 2,
          ),
          Paint()
            ..color = (back ? DemoPalette.indigo : DemoPalette.rose).withValues(
              alpha: .65,
            ),
        );
      }
      if (back) {
        for (var y = 10.0; y < size.height; y += 15) {
          canvas.drawLine(
            Offset(0, y),
            Offset(size.width, y + 12),
            Paint()
              ..color = DemoPalette.paper.withValues(alpha: .5)
              ..strokeWidth = 1,
          );
        }
      }
    } else {
      for (var y = 12.0; y < size.height; y += 16) {
        canvas.drawLine(
          Offset(11, y),
          Offset(size.width - 11, y),
          Paint()
            ..color = DemoPalette.paper.withValues(alpha: back ? .25 : .5)
            ..strokeWidth = 2,
        );
      }
      paintCraftStitch(
        canvas,
        Path()
          ..moveTo(6, 0)
          ..lineTo(6, size.height)
          ..moveTo(size.width - 6, 0)
          ..lineTo(size.width - 6, size.height),
        thread: back ? DemoPalette.wood : DemoPalette.cream,
        pitch: 8,
        width: 1.1,
      );
      canvas.drawRect(
        Rect.fromLTWH(3, size.height - 12, size.width - 6, 10),
        Paint()..color = back ? DemoPalette.terracotta : DemoPalette.indigo,
      );
    }
  }

  // Source cells differ only by floating-point cancellation at row boundaries.
  Size _shadeKey(Rect rect) =>
      Size((rect.width * 1e6).round() / 1e6, (rect.height * 1e6).round() / 1e6);

  /// Prepares a padded flat face once; padding keeps cell borders out of shading.
  void prepare(Iterable<MaterialCell> cells) {
    if (_disposed) throw StateError('Print already disposed');
    for (final cell in cells) {
      _models.putIfAbsent(
        _shadeKey(cell.source),
        () => CraftVolume(
          Path()..addRect((Offset.zero & _shadeKey(cell.source)).inflate(6)),
          CraftVolumeProfile.sheet,
          height: .5,
          bevel: 1,
        ),
      );
    }
  }

  /// Paints texture and the existing shader through one shared affine transform.
  void triangle(
    Canvas canvas,
    MaterialCell cell,
    bool back,
    List<int> indices,
    List<MaterialPoint> vertices,
    CraftLight light,
  ) {
    if (_disposed) throw StateError('Print already disposed');
    final a = vertices[indices[0]],
        b = vertices[indices[1]],
        c = vertices[indices[2]];
    final normal = (b - a).cross(c - a).unit * (back ? -1 : 1);
    final incoming = MaterialPoint(light.x, light.y, light.z).unit;
    // Tilt changes directional amplitude; the canonical shader still owns tone.
    final local = CraftLight(
      x: 0,
      y: 0,
      z: 1,
      ambient: light.ambient,
      direct: light.direct * normal.dot(incoming).clamp(0.0, 1.0),
      softness: light.softness,
      warmth: light.warmth,
    );
    final uv = cell.uv;
    paintImageTriangle(
      canvas,
      back ? reverse : front,
      size,
      uv[indices[0]],
      uv[indices[1]],
      uv[indices[2]],
      a.screen,
      b.screen,
      c.screen,
      overlay: (canvas) {
        canvas.translate(cell.source.left, cell.source.top);
        _models[_shadeKey(cell.source)]!.shade(canvas, local);
      },
    );
  }

  /// Releases only owned images, never the borrowed texture cache.
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    front.dispose();
    reverse.dispose();
  }
}

/// A finite projected sheet. The authored recipes keep layers from intersecting.
class ProjectedMaterial {
  /// At most 32 source cells; no general mesh/physics or z-buffer API is implied.
  ProjectedMaterial(List<MaterialCell> source)
    : cells = List.unmodifiable(source) {
    if (cells.isEmpty || cells.length > 32) {
      throw ArgumentError('Expected 1..32 cells');
    }
  }

  /// Source cells in material order.
  final List<MaterialCell> cells;

  /// Mid-surface attachment, before the small physical face offset.
  MaterialPoint attach(Offset source) {
    final cell = cells.firstWhere(
      (c) => c.source.inflate(1e-6).contains(source),
    );
    final front = cell.map(source), back = cell.map(source, reverse: true);
    return (front + back) * .5;
  }

  /// Actual visible skin at a source coordinate; attachments may instead use attach().
  MaterialPoint surfacePoint(Offset source) {
    final cell = cells.firstWhere(
      (c) => c.source.inflate(1e-6).contains(source),
    );
    final u = (source.dx - cell.source.left) / cell.source.width;
    final v = (source.dy - cell.source.top) / cell.source.height;
    final indices = v <= u ? const [0, 1, 2] : const [0, 2, 3];
    final a = cell.front[indices[0]].screen,
        b = cell.front[indices[1]].screen,
        c = cell.front[indices[2]].screen;
    final area = (b.dx - a.dx) * (c.dy - a.dy) - (b.dy - a.dy) * (c.dx - a.dx);
    return cell.map(source, reverse: area < 0);
  }

  /// Projected ground receiver shadow from the actual height of every corner.
  Path groundShadow(CraftLight light) {
    final path = Path();
    for (final cell in cells) {
      final points = [
        for (final p in cell.center)
          Offset(p.x - light.x * p.z / light.z, p.y - light.y * p.z / light.z),
      ];
      for (final indices in [
        const [0, 1, 2],
        const [0, 2, 3],
      ]) {
        final p = [for (final i in indices) points[i]];
        final area =
            (p[1] - p[0]).dx * (p[2] - p[0]).dy -
            (p[1] - p[0]).dy * (p[2] - p[0]).dx;
        path.addPolygon(area < 0 ? p.reversed.toList() : p, true);
      }
    }
    return path;
  }

  /// Maximum actual separation, used to soften the single receiver shadow.
  double get height =>
      cells.expand((c) => c.center).map((p) => p.z).reduce(math.max);

  /// Draws back-to-front in world height for these nonintersecting authored folds.
  void paint(
    Canvas canvas,
    PrintedMaterial print,
    CraftLight light, {
    bool shadow = true,
  }) {
    print.prepare(cells);
    if (shadow) {
      canvas.drawPath(
        groundShadow(light),
        Paint()
          ..color = DemoPalette.ink.withValues(alpha: .16)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 1 + height * .07),
      );
    }
    final pieces = <(double, void Function())>[];
    for (final cell in cells) {
      for (final back in [false, true]) {
        final points = back ? cell.back : cell.front;
        for (final indices in [
          const [0, 1, 2],
          const [0, 2, 3],
        ]) {
          final a = points[indices[0]].screen,
              b = points[indices[1]].screen,
              c = points[indices[2]].screen;
          final area =
              (b.dx - a.dx) * (c.dy - a.dy) - (b.dy - a.dy) * (c.dx - a.dx);
          if ((back ? -area : area) <= .01) continue;
          final depth = indices.fold<double>(0, (v, i) => v + points[i].z) / 3;
          pieces.add((
            depth,
            () => print.triangle(canvas, cell, back, indices, points, light),
          ));
        }
      }
      // Only the two outer side walls; no fake thickness seam at every row.
      final walls = [
        const [0, 3],
        const [1, 2],
        if (cell.source.top == 0) const [0, 1],
        if ((cell.source.bottom - print.size.height).abs() < 1e-6) const [3, 2],
      ];
      for (final pair in walls) {
        final p = [
          cell.front[pair[0]],
          cell.front[pair[1]],
          cell.back[pair[1]],
          cell.back[pair[0]],
        ];
        pieces.add((
          p.fold<double>(0, (v, p) => v + p.z) / 4,
          () => canvas.drawPath(
            Path()..addPolygon(p.map((p) => p.screen).toList(), true),
            Paint()
              ..color = Color.lerp(print.frontColor, DemoPalette.ink, .18)!,
          ),
        ));
      }
    }
    pieces.sort((a, b) => a.$1.compareTo(b.$1));
    for (final piece in pieces) {
      piece.$2();
    }
  }
}
