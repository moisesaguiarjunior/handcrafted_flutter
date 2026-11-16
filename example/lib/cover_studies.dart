import 'package:flutter/material.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

import 'material_studies.dart';
import 'showcase_theme.dart';

/// Distinct original sculptural motifs, without repeating botanical stamps.
enum ReliefObject {
  /// A scalloped shell with directional ribs.
  shell,

  /// A feather with separated barbs.
  feather,

  /// A crescent with small star-shaped impressions.
  crescent,
}

const _navy = Color(0xFF36566A);
const _flax = Color(0xFFD8C9A7);
const _rose = Color(0xFFB77584);

/// Three real-material relief studies shared by the live gallery and captures.
class ReliefObjectsSheet extends StatelessWidget {
  /// Creates original shell, feather and crescent studies.
  const ReliefObjectsSheet({super.key});
  @override
  Widget build(BuildContext context) => SpecimenRow(
    children: [
      for (final object in ReliefObject.values)
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 340, child: _ReliefPlate(object: object)),
            const SizedBox(height: 12),
            Text(switch (object) {
              ReliefObject.shell => 'Sculpted shell on twill',
              ReliefObject.feather => 'A pressed feather in flax',
              ReliefObject.crescent => 'Moonlight on felt',
            }, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(
              object == ReliefObject.feather
                  ? 'Inset barbs, native pressed lettering'
                  : 'Raised rims, visible substrate grain',
            ),
          ],
        ),
    ],
  );
}

Path _reliefCut(ReliefObject object, Size size) {
  final w = size.width, h = size.height;
  return switch (object) {
    ReliefObject.shell => Path()..addOval(Rect.fromLTWH(8, 8, w - 16, h - 16)),
    ReliefObject.feather =>
      Path()
        ..moveTo(22, 8)
        ..lineTo(w - 18, 20)
        ..lineTo(w - 8, h - 54)
        ..lineTo(w * .43, h - 8)
        ..lineTo(8, h - 35)
        ..close(),
    ReliefObject.crescent =>
      Path()
        ..moveTo(w * .5, 8)
        ..quadraticBezierTo(w * .9, 8, w - 8, h * .26)
        ..lineTo(w - 8, h * .65)
        ..quadraticBezierTo(w * .8, h * .92, w * .5, h - 8)
        ..quadraticBezierTo(w * .2, h * .92, 8, h * .65)
        ..lineTo(8, h * .26)
        ..quadraticBezierTo(w * .1, 8, w * .5, 8)
        ..close(),
  };
}

class _ReliefPlate extends StatelessWidget {
  const _ReliefPlate({required this.object});
  final ReliefObject object;
  @override
  Widget build(BuildContext context) {
    final base = switch (object) {
      ReliefObject.shell => _navy,
      ReliefObject.feather => _flax,
      ReliefObject.crescent => DemoPalette.rose,
    };
    Path cut(Size size) => _reliefCut(object, size);
    final surface = CraftSurface(
      material: switch (object) {
        ReliefObject.shell => CraftMaterial.twill,
        ReliefObject.feather => CraftMaterial.linen,
        ReliefObject.crescent => CraftMaterial.felt,
      },
      color: base,
      seed: 44 + object.index,
      strength: 1,
      outline: cut,
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _ReliefPainter(object))),
          Positioned(
            left: 20,
            right: 20,
            bottom: 29,
            child: CraftReliefText(
              switch (object) {
                ReliefObject.shell => 'Cove',
                ReliefObject.feather => 'Drift',
                ReliefObject.crescent => 'Nightfall',
              },
              textAlign: TextAlign.center,
              depth: 1.7,
              style: TextStyle(
                fontFamily: 'Caveat',
                fontSize: 44,
                color: object == ReliefObject.feather
                    ? const Color(0xFF79674C)
                    : const Color(0xFFF3E8DB),
              ),
            ),
          ),
        ],
      ),
    );
    return _Lifted(outline: cut, child: surface);
  }
}

class _ReliefPainter extends CustomPainter {
  _ReliefPainter(this.object);
  final ReliefObject object;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 320, size.height / 340);
    void sculpt(
      Path shape, {
      bool inset = false,
      Color? fill,
      double depth = 3,
    }) => paintCraftRelief(
      canvas,
      shape,
      kind: inset ? CraftReliefKind.inset : CraftReliefKind.raised,
      depth: depth,
      strength: 1,
      fill: fill,
    );
    switch (object) {
      case ReliefObject.shell:
        final shell = Path()
          ..moveTo(160, 230)
          ..cubicTo(90, 225, 28, 167, 35, 110)
          ..cubicTo(38, 86, 54, 66, 78, 68)
          ..cubicTo(85, 40, 115, 34, 137, 49)
          ..cubicTo(151, 20, 180, 24, 193, 49)
          ..cubicTo(220, 30, 249, 47, 253, 72)
          ..cubicTo(287, 67, 300, 95, 291, 128)
          ..cubicTo(281, 177, 216, 224, 160, 230)
          ..close();
        sculpt(shell, fill: Colors.white.withValues(alpha: .16));
        for (final tip in const [
          Offset(52, 108),
          Offset(85, 81),
          Offset(116, 60),
          Offset(161, 44),
          Offset(204, 64),
          Offset(245, 89),
          Offset(275, 121),
        ]) {
          final rib = Path()
            ..moveTo(158, 216)
            ..quadraticBezierTo((tip.dx + 160) / 2 - 9, 145, tip.dx, tip.dy)
            ..quadraticBezierTo((tip.dx + 160) / 2, 149, 163, 216)
            ..close();
          sculpt(rib, inset: true, depth: 2.2);
        }
      case ReliefObject.feather:
        final feather = Path()
          ..moveTo(78, 239)
          ..cubicTo(40, 126, 135, 58, 248, 38)
          ..cubicTo(250, 145, 195, 242, 78, 239)
          ..close();
        sculpt(feather, inset: true, depth: 3.5);
        canvas.save();
        canvas.clipPath(feather);
        for (var i = 0; i < 9; i++) {
          final t = i / 9;
          final center = Offset(86 + t * 136, 224 - t * 165);
          final vane = Path()
            ..moveTo(center.dx, center.dy)
            ..quadraticBezierTo(
              center.dx - 44,
              center.dy + 8,
              center.dx - 32,
              center.dy - 24,
            )
            ..quadraticBezierTo(
              center.dx - 10,
              center.dy - 8,
              center.dx + 3,
              center.dy - 4,
            )
            ..close();
          sculpt(vane, inset: true, depth: 1.4);
          final other = Path()
            ..moveTo(center.dx + 4, center.dy)
            ..quadraticBezierTo(
              center.dx + 57,
              center.dy + 12,
              center.dx + 48,
              center.dy - 22,
            )
            ..quadraticBezierTo(
              center.dx + 23,
              center.dy - 5,
              center.dx + 7,
              center.dy - 4,
            )
            ..close();
          sculpt(other, inset: true, depth: 1.2);
        }
        canvas.restore();
      case ReliefObject.crescent:
        final moon = Path.combine(
          PathOperation.difference,
          Path()..addOval(const Rect.fromLTWH(59, 48, 188, 188)),
          Path()..addOval(const Rect.fromLTWH(115, 24, 177, 177)),
        );
        sculpt(moon, fill: Colors.white.withValues(alpha: .18), depth: 4);
        for (final p in const [
          Offset(226, 90),
          Offset(268, 158),
          Offset(215, 204),
        ]) {
          final star = Path()
            ..moveTo(p.dx, p.dy - 10)
            ..lineTo(p.dx + 3, p.dy - 3)
            ..lineTo(p.dx + 10, p.dy)
            ..lineTo(p.dx + 3, p.dy + 3)
            ..lineTo(p.dx, p.dy + 10)
            ..lineTo(p.dx - 3, p.dy + 3)
            ..lineTo(p.dx - 10, p.dy)
            ..lineTo(p.dx - 3, p.dy - 3)
            ..close();
          sculpt(star, inset: true, depth: 1.8);
        }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ReliefPainter old) => old.object != object;
}

/// A captured poster built entirely from the library's real painting/widgets.
class MaterialCover extends StatelessWidget {
  /// Creates a fixed artboard; live hosts scroll it instead of shrinking controls.
  const MaterialCover({super.key, this.onPressed});

  /// Native action shown on the paper composition.
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 1200,
    height: 750,
    child: Stack(
      children: [
        const Positioned(
          left: 46,
          top: 30,
          child: Text(
            'Make something tactile.',
            style: TextStyle(
              fontFamily: 'Caveat',
              fontSize: 74,
              color: DemoPalette.ink,
            ),
          ),
        ),
        const Positioned(
          left: 50,
          top: 128,
          child: Text(
            'Paper, cloth, pigment and thread. Still your Flutter widgets.',
            style: TextStyle(fontSize: 22, color: DemoPalette.ink),
          ),
        ),
        Positioned(
          left: 45,
          top: 206,
          child: CraftPart(
            key: const ValueKey('cover-shell'),
            size: const Size(352, 370),
            pose: PartPose(rotation: -.055),
            child: const _ReliefPlate(object: ReliefObject.shell),
          ),
        ),
        Positioned(
          left: 425,
          top: 225,
          child: CraftPart(
            key: const ValueKey('cover-paint'),
            size: const Size(330, 345),
            pose: PartPose(rotation: .045),
            child: _Lifted(
              outline: const CraftOutline.paper(
                edge: PaperEdge.torn,
                edgeDepth: 4,
                edgePitch: 22,
                seed: 12,
              ).pathFor,
              child: CraftSurface(
                material: CraftMaterial.paper,
                color: DemoPalette.paper,
                seed: 12,
                strength: 1,
                shape: const CraftOutline.paper(
                  edge: PaperEdge.torn,
                  edgeDepth: 4,
                  edgePitch: 22,
                  seed: 12,
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(painter: _PigmentLandscape()),
                    ),
                    Positioned(
                      left: 30,
                      right: 30,
                      bottom: 18,
                      child: TextButton(
                        onPressed: onPressed,
                        child: const Text(
                          'Keep creating',
                          style: TextStyle(fontSize: 19),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 805,
          top: 212,
          child: CraftPart(
            key: const ValueKey('cover-thread'),
            size: const Size(330, 350),
            pose: PartPose(rotation: -.04),
            child: _Lifted(
              outline: _coverPatch,
              child: CraftSurface(
                material: CraftMaterial.linen,
                color: _flax,
                seed: 15,
                outline: _coverPatch,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(painter: _PatchEmbroidery()),
                    ),
                    const Positioned(
                      left: 40,
                      right: 40,
                      top: 98,
                      child: CraftReliefText(
                        'Stay curious',
                        textAlign: TextAlign.center,
                        depth: 1.4,
                        style: TextStyle(
                          fontFamily: 'Caveat',
                          fontSize: 38,
                          color: _navy,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const Positioned(
          left: 53,
          top: 608,
          child: _Caption(
            'Sculpted relief',
            'Visible weave. Native lettering.',
          ),
        ),
        const Positioned(
          left: 440,
          top: 608,
          child: _Caption(
            'Watercolor & torn paper',
            'Pigment layers. A real button.',
          ),
        ),
        const Positioned(
          left: 815,
          top: 608,
          child: _Caption(
            'Cord & embroidered lines',
            'A border that follows the cut.',
          ),
        ),
        const Positioned(
          left: 52,
          bottom: 30,
          child: Text(
            'Seeded materials  /  shaped edges  /  native controls  /  explicit motion',
            style: TextStyle(fontSize: 17, color: DemoPalette.ink),
          ),
        ),
      ],
    ),
  );
}

class _Caption extends StatelessWidget {
  const _Caption(this.title, this.subtitle);
  final String title, subtitle;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 8),
      Text(subtitle, style: const TextStyle(fontSize: 16)),
    ],
  );
}

Path _coverPatch(Size size) {
  final x = size.width / 330, y = size.height / 350;
  return Path()
    ..moveTo(32 * x, 45 * y)
    ..cubicTo(80 * x, 22 * y, 252 * x, 27 * y, 290 * x, 58 * y)
    ..cubicTo(312 * x, 119 * y, 287 * x, 153 * y, 307 * x, 219 * y)
    ..cubicTo(322 * x, 296 * y, 228 * x, 328 * y, 165 * x, 311 * y)
    ..cubicTo(88 * x, 336 * y, 20 * x, 300 * y, 28 * x, 230 * y)
    ..cubicTo(41 * x, 160 * y, 7 * x, 111 * y, 32 * x, 45 * y)
    ..close();
}

class _PatchEmbroidery extends CustomPainter {
  _PatchEmbroidery() : outline = _coverPatch(const Size(330, 350)) {
    seam = contourTrimPath(outline, width: 11, gap: 7, sampleSpacing: 1);
  }
  final Path outline;
  late final Path seam;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 330, size.height / 350);
    canvas.clipPath(outline);
    paintCraftTrim(
      canvas,
      seam,
      color: DemoPalette.paper,
      width: 11,
      pitch: 4,
      relief: 1,
    );
    final sprig = Path()
      ..moveTo(90, 238)
      ..quadraticBezierTo(166, 227, 239, 182)
      ..moveTo(148, 224)
      ..quadraticBezierTo(98, 170, 118, 172)
      ..quadraticBezierTo(149, 175, 148, 224)
      ..moveTo(181, 209)
      ..quadraticBezierTo(171, 163, 193, 162)
      ..quadraticBezierTo(209, 172, 181, 209)
      ..moveTo(210, 198)
      ..quadraticBezierTo(244, 228, 258, 207)
      ..quadraticBezierTo(252, 192, 210, 198);
    paintCraftTrim(
      canvas,
      sprig,
      color: _rose,
      kind: CraftTrimKind.embroidered,
      width: 6,
      pitch: 2,
      relief: 1,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PatchEmbroidery old) => false;
}

class _PigmentLandscape extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 330, size.height / 345);
    final sky = pigmentOutline(
      const Rect.fromLTWH(25, 28, 280, 235),
      seed: 44,
      broad: true,
    );
    paintWatercolor(
      canvas,
      sky,
      pigment: const Color(0xFF91AEB9),
      companion: const Color(0xFFB7CBD0),
      paper: DemoPalette.paper,
      seed: 42,
      opacity: .8,
    );
    paintWatercolor(
      canvas,
      Path()..addOval(const Rect.fromLTWH(197, 58, 62, 62)),
      pigment: const Color(0xFFDBB275),
      paper: DemoPalette.paper,
      seed: 22,
      opacity: .9,
    );
    for (var i = 0; i < 3; i++) {
      final y = 165.0 + i * 29;
      final hill = Path()
        ..moveTo(24, y + 22)
        ..cubicTo(120, y - 70, 215, y + 38, 307, y - 10)
        ..lineTo(307, 272)
        ..lineTo(24, 272)
        ..close();
      paintWatercolor(
        canvas,
        hill,
        pigment: [const Color(0xFF81A598), const Color(0xFF5D8D87), _navy][i],
        paper: DemoPalette.paper,
        seed: 34 + i,
        opacity: .7,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PigmentLandscape old) => false;
}

/// Scrollable live cover and distinct relief studies; no decorative tickers.
class CoverGallery extends StatefulWidget {
  /// Creates the documentation compositions as a runnable gallery.
  const CoverGallery({super.key});
  @override
  State<CoverGallery> createState() => _CoverGalleryState();
}

class _CoverGalleryState extends State<CoverGallery> {
  int count = 0;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: MaterialCover(onPressed: () => setState(() => count++)),
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Native actions: $count'),
        ),
        const Padding(padding: EdgeInsets.all(24), child: ReliefObjectsSheet()),
      ],
    ),
  );
}

class _Lifted extends StatelessWidget {
  const _Lifted({required this.outline, required this.child});
  final Path Function(Size) outline;
  final Widget child;
  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _LiftShadow(outline), child: child);
}

class _LiftShadow extends CustomPainter {
  const _LiftShadow(this.outline);
  final Path Function(Size) outline;
  @override
  void paint(Canvas canvas, Size size) =>
      canvas.drawShadow(outline(size), const Color(0x550E2531), 5, true);
  @override
  bool shouldRepaint(_LiftShadow old) => old.outline != outline;
}
