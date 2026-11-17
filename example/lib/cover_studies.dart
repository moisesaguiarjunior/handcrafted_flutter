import 'package:flutter/material.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

import 'material_studies.dart';
import 'relief_motifs.dart';
import 'showcase_theme.dart';

/// Three purposeful objects whose motifs are pressed or raised into material.
enum ReliefObject {
  /// A leather journal cover with a pressed ginkgo leaf and a stitched border.
  journal,

  /// A twill travel card with a raised hot-air balloon.
  voyage,

  /// A letterpress thank-you card with pressed mountains.
  thanks,
}

const _navy = DemoPalette.indigo;
const _flax = Color(0xFFD8C9A7);
const _rose = DemoPalette.terracotta;

/// Three real-material relief studies shared by the live gallery and captures.
class ReliefObjectsSheet extends StatelessWidget {
  /// Creates the journal, travel card and letterpress studies.
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
              ReliefObject.journal => 'A tooled leather journal',
              ReliefObject.voyage => 'A raised balloon on twill',
              ReliefObject.thanks => 'Letterpress on cotton paper',
            }, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(switch (object) {
              ReliefObject.journal => 'Pressed leaf, saddle-style seam',
              ReliefObject.voyage => 'Raised panels, pressed seams',
              ReliefObject.thanks => 'Debossed peaks, native lettering',
            }),
          ],
        ),
    ],
  );
}

Path _reliefCut(ReliefObject object, Size size) {
  final w = size.width, h = size.height;
  return switch (object) {
    ReliefObject.journal =>
      Path()..addRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(10, 8, w - 20, h - 16),
          topLeft: const Radius.circular(6),
          bottomLeft: const Radius.circular(6),
          topRight: const Radius.circular(22),
          bottomRight: const Radius.circular(22),
        ),
      ),
    ReliefObject.voyage =>
      Path()
        ..moveTo(10, h - 8)
        ..lineTo(10, w / 2 + 4)
        ..arcToPoint(
          Offset(w - 10, w / 2 + 4),
          radius: Radius.circular(w / 2 - 10),
        )
        ..lineTo(w - 10, h - 8)
        ..close(),
    ReliefObject.thanks => paperOutline(
      Rect.fromLTWH(12, 14, w - 24, h - 28),
      edge: PaperEdge.deckle,
      depth: 3,
      pitch: 18,
      seed: 61,
    ),
  };
}

class _ReliefPlate extends StatelessWidget {
  const _ReliefPlate({required this.object});
  final ReliefObject object;
  @override
  Widget build(BuildContext context) {
    Path cut(Size size) => _reliefCut(object, size);
    final surface = CraftSurface(
      material: switch (object) {
        ReliefObject.journal => CraftMaterial.leather,
        ReliefObject.voyage => CraftMaterial.twill,
        ReliefObject.thanks => CraftMaterial.paper,
      },
      color: switch (object) {
        ReliefObject.journal => DemoPalette.cognac,
        ReliefObject.voyage => DemoPalette.indigo,
        ReliefObject.thanks => const Color(0xFFF6EFE2),
      },
      seed: 44 + object.index,
      strength: 1,
      outline: cut,
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _ReliefPainter(object))),
          Positioned(
            left: 24,
            right: 24,
            bottom: object == ReliefObject.thanks ? 34 : 30,
            child: CraftReliefText(
              switch (object) {
                ReliefObject.journal => 'Field journal',
                ReliefObject.voyage => 'Bon voyage',
                ReliefObject.thanks => 'Thank you',
              },
              textAlign: TextAlign.center,
              kind: object == ReliefObject.voyage
                  ? CraftReliefKind.raised
                  : CraftReliefKind.inset,
              depth: 1.7,
              style: TextStyle(
                fontFamily: 'Caveat',
                fontWeight: FontWeight.w700,
                fontSize: 40,
                color: switch (object) {
                  ReliefObject.journal => const Color(0xFF5A321B),
                  ReliefObject.voyage => DemoPalette.cream,
                  ReliefObject.thanks => const Color(0xFF55705F),
                },
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
    final art = Rect.fromLTWH(
      size.width * .14,
      size.height * .08,
      size.width * .72,
      size.height * .66,
    );
    switch (object) {
      case ReliefObject.journal:
        final seam = insetCraftPath(
          _reliefCut(object, size),
          distance: 15,
          sampleSpacing: 1,
        );
        paintRunningStitch(
          canvas,
          seam,
          thread: DemoPalette.cream,
          dash: 9,
          gap: 5,
          width: 2.4,
          compression: .6,
          irregularity: .3,
          seed: 12,
        );
        // A spine band pressed along the binding edge.
        paintCraftRelief(
          canvas,
          Path()..addRect(Rect.fromLTWH(30, 26, 6, size.height - 52)),
          depth: 1.6,
        );
        paintReliefMotif(
          canvas,
          ReliefMotif.ginkgo,
          art,
          depthScale: 1.2,
          strength: 1,
        );
      case ReliefObject.voyage:
        paintReliefMotif(
          canvas,
          ReliefMotif.balloon,
          art,
          kind: CraftReliefKind.raised,
          strength: 1,
        );
      case ReliefObject.thanks:
        paintReliefMotif(
          canvas,
          ReliefMotif.mountains,
          art.deflate(6),
          strength: .85,
          depthScale: .9,
        );
    }
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
            key: const ValueKey('cover-journal'),
            size: const Size(352, 370),
            pose: PartPose(rotation: -.055),
            child: const _ReliefPlate(object: ReliefObject.journal),
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
                          'Save to album',
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
                        'Chapter one',
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
            'Tooled leather',
            'A pressed leaf. Native lettering.',
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
