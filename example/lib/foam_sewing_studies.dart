import 'package:flutter/material.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

import 'material_studies.dart';

/// Original foam cuts comparing overlapping edges, raised yarn and pressed marks.
class FoamSewingStudies extends StatelessWidget {
  /// Uses the same native depth/contrast controls as the existing foam study.
  const FoamSewingStudies({super.key, this.depth = 3, this.strength = .6});

  /// Raised edge depth in logical pixels, 0..8.
  final double depth;

  /// Surface and pressed-rim contrast, 0..1.
  final double strength;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Cut, stack, stitch',
        style: TextStyle(fontFamily: 'Caveat', fontSize: 38),
      ),
      const Text(
        'Soft edges and fine pores. A pale strand sits above the cut; an ochre mark is pressed into it.',
      ),
      const SizedBox(height: 18),
      SpecimenRow(
        children: [
          for (final (index, title, detail) in [
            (
              0,
              'Layer upon layer',
              'Small contact shadows between separate cuts',
            ),
            (
              1,
              'A raised strand',
              'Cream yarn, rounded ends and small punctures',
            ),
            (2, 'A pressed mark', 'A pale lower lip, without a dark seam halo'),
          ])
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 1.1,
                  child: _FoamArt(index, depth, strength),
                ),
                const SizedBox(height: 10),
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                Text(detail),
              ],
            ),
        ],
      ),
    ],
  );
}

class _FoamArt extends StatefulWidget {
  const _FoamArt(this.index, this.depth, this.strength);
  final int index;
  final double depth, strength;
  @override
  State<_FoamArt> createState() => _FoamArtState();
}

class _FoamArtState extends State<_FoamArt> {
  final textures = MaterialTextures(seed: 93);
  @override
  void dispose() {
    textures.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: IgnorePointer(
      child: CustomPaint(
        painter: _FoamSewingPainter(
          textures,
          widget.index,
          widget.depth,
          widget.strength,
        ),
      ),
    ),
  );
}

class _FoamSewingPainter extends CustomPainter {
  _FoamSewingPainter(this.textures, this.index, this.depth, this.strength) {
    outline = Path()
      ..moveTo(45, 45)
      ..quadraticBezierTo(150, 24, 255, 45)
      ..quadraticBezierTo(270, 136, 255, 235)
      ..quadraticBezierTo(150, 254, 45, 235)
      ..quadraticBezierTo(27, 140, 45, 45)
      ..close();
    seam = insetCraftPath(outline, distance: 15);
    stitches = runningStitchPath(
      seam,
      dash: 10,
      gap: 7,
      irregularity: .65,
      seed: 93,
    );
  }
  final MaterialTextures textures;
  final int index;
  final double depth, strength;
  late final Path outline, seam, stitches;
  static const coral = Color(0xFFF28C6C),
      cream = Color(0xFFFFDE9E),
      blue = Color(0xFF73B7C3),
      green = Color(0xFF9CB46B);
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 300, size.height / 280);
    final background = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(0, 0, 300, 280),
          const Radius.circular(18),
        ),
      );
    textures.paint(
      canvas,
      background,
      material: CraftMaterial.paper,
      color: const Color(0xFFFFFAF2),
      strength: .35,
    );
    if (index == 0) {
      _layers(canvas);
    } else {
      _sewn(canvas);
    }
    canvas.restore();
  }

  void _layer(Canvas canvas, Path cut, Color color) {
    canvas.drawShadow(cut, const Color(0x293E2B20), depth, false);
    textures.paint(canvas, cut, material: CraftMaterial.eva, color: color);
    paintFoamFinish(
      canvas,
      cut,
      finish: FoamFinish.pebbled,
      ink: const Color(0xFF9E7155),
      strength: strength * .2,
      seed: 93,
    );
    paintCraftRelief(
      canvas,
      cut,
      kind: CraftReliefKind.raised,
      depth: depth,
      strength: .28,
    );
  }

  Path _scallops(double y) {
    final p = Path()
      ..moveTo(42, y)
      ..lineTo(258, y)
      ..lineTo(258, y + 24);
    for (var i = 3; i >= 0; i--) {
      final x = 42.0 + i * 54;
      p.quadraticBezierTo(x + 27, y + 63, x, y + 24);
    }
    return p..close();
  }

  void _layers(Canvas canvas) {
    _layer(canvas, outline, cream);
    for (final (y, color) in [
      (137.0, blue),
      (104.0, coral),
      (71.0, const Color(0xFFF9C457)),
    ]) {
      _layer(canvas, _scallops(y), color);
    }
    final strip = Path()
      ..moveTo(55, 88)
      ..quadraticBezierTo(150, 94, 245, 88);
    paintRunningStitch(
      canvas,
      strip,
      thread: const Color(0xFFFFF0CF),
      dash: 9,
      gap: 7,
      irregularity: .55,
      width: 2.5,
      compression: strength * .35,
    );
    final leaf = Path()
      ..moveTo(183, 224)
      ..quadraticBezierTo(183, 179, 237, 175)
      ..quadraticBezierTo(240, 221, 183, 224)
      ..close();
    _layer(canvas, leaf, green);
    paintRunningStitch(
      canvas,
      Path()
        ..moveTo(193, 215)
        ..quadraticBezierTo(207, 198, 227, 186),
      thread: const Color(0xFF8A9B50),
      dash: 7,
      gap: 4,
      width: 2.3,
      relief: CraftReliefKind.inset,
      compression: strength,
    );
  }

  void _sewn(Canvas canvas) {
    final raised = index == 1;
    _layer(canvas, outline, raised ? coral : cream);
    canvas.save();
    canvas.clipPath(outline);
    CraftStitchFrame.sample(stitches, progress: 1).paint(
      canvas,
      thread: raised ? const Color(0xFFFFF1D0) : const Color(0xFFBE914B),
      width: 3,
      compression: raised ? strength * .35 : strength,
      relief: raised ? CraftReliefKind.raised : CraftReliefKind.inset,
    );
    canvas.restore();
    // The same small folded leaf motif makes material shading easy to compare.
    final leaf = Path()
      ..moveTo(102, 175)
      ..quadraticBezierTo(94, 111, 191, 96)
      ..quadraticBezierTo(198, 160, 102, 175)
      ..close();
    _layer(canvas, leaf, raised ? cream : blue);
    final vein = Path()
      ..moveTo(114, 164)
      ..quadraticBezierTo(146, 138, 178, 109);
    paintRunningStitch(
      canvas,
      vein,
      thread: raised ? const Color(0xFFBE914B) : const Color(0xFF458591),
      width: 2.5,
      dash: 8,
      gap: 5,
      relief: CraftReliefKind.inset,
      compression: strength,
    );
  }

  @override
  bool shouldRepaint(_FoamSewingPainter old) =>
      old.textures != textures ||
      old.index != index ||
      old.depth != depth ||
      old.strength != strength;
}
