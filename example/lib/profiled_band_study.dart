import 'package:flutter/material.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

/// Original paper cuts: asymmetric ribbon, continuous loop and raised strip.
/// No embroidery is implied by the band geometry.
class ProfiledBandStudy extends StatefulWidget {
  /// Prepares original geometry once and accepts explicit shared illumination.
  const ProfiledBandStudy({super.key, this.light});

  /// Scene-space light; null selects the fixed documentation condition.
  final CraftLight? light;

  @override
  State<ProfiledBandStudy> createState() => _ProfiledBandStudyState();
}

class _ProfiledBandStudyState extends State<ProfiledBandStudy> {
  final textures = MaterialTextures(seed: 127);
  late final ribbon = CraftBand(
    Path()
      ..moveTo(35, 66)
      ..cubicTo(150, 8, 160, 155, 295, 113)
      ..cubicTo(410, 76, 426, 27, 600, 80),
    height: 1,
    widthProfile: const [
      CraftBandWidth(progress: 0, positive: 14, negative: 18),
      CraftBandWidth(progress: .23, positive: 24, negative: 15),
      CraftBandWidth(progress: .48, positive: 17, negative: 23),
      CraftBandWidth(progress: .73, positive: 26, negative: 18),
      CraftBandWidth(progress: 1, positive: 18, negative: 14),
    ],
  );
  late final loop = CraftBand(
    Path()..addOval(const Rect.fromLTWH(58, 205, 194, 132)),
    height: 1.5,
    widthProfile: const [
      CraftBandWidth(progress: 0, positive: 14, negative: 12),
      CraftBandWidth(progress: .32, positive: 19, negative: 9),
      CraftBandWidth(progress: .67, positive: 12, negative: 18),
      CraftBandWidth(progress: 1, positive: 14, negative: 12),
    ],
  );
  late final raised = CraftBand(
    Path()
      ..moveTo(350, 315)
      ..cubicTo(387, 214, 516, 211, 590, 282),
    height: 1,
    widthProfile: const [
      CraftBandWidth(progress: 0, positive: 13, negative: 19),
      CraftBandWidth(progress: .5, positive: 22, negative: 17),
      CraftBandWidth(progress: 1, positive: 16, negative: 13),
    ],
  );

  @override
  void dispose() {
    textures.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      AspectRatio(
        aspectRatio: 640 / 370,
        child: IgnorePointer(
          child: ExcludeSemantics(
            child: CustomPaint(
              painter: _BandPainter(
                textures,
                ribbon,
                loop,
                raised,
                widget.light ?? CraftLight(),
              ),
            ),
          ),
        ),
      ),
      const Text(
        'Paper in three forms',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      const Text(
        'Independent edges above; a joined loop below left; a thin strip lifted '
        '9px below right. No thread. Thickness, ground lift and shadow softness '
        'are separate; every silhouette is the actual prepared band.',
      ),
    ],
  );
}

class _BandPainter extends CustomPainter {
  const _BandPainter(
    this.textures,
    this.ribbon,
    this.loop,
    this.raised,
    this.light,
  );
  final MaterialTextures textures;
  final CraftBand ribbon, loop, raised;
  final CraftLight light;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    try {
      canvas.scale(size.width / 640);
      final board = Path()
        ..addRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(0, 0, 640, 370),
            const Radius.circular(18),
          ),
        );
      textures.paint(
        canvas,
        board,
        material: CraftMaterial.paper,
        color: const Color(0xFFFFFAF2),
        strength: .27,
      );
      void paintBand(
        CraftBand band,
        Color color, {
        double lift = 0,
        double softness = 1,
      }) {
        band.shadow(
          canvas,
          light,
          receiver: board,
          lift: lift,
          softness: softness,
        );
        textures.paint(
          canvas,
          band.outline,
          material: CraftMaterial.paper,
          color: color,
          strength: .3,
        );
        band.shade(canvas, light);
      }

      paintBand(ribbon, const Color(0xFFEBC49A));
      paintBand(loop, const Color(0xFFE5A5A0));
      paintBand(raised, const Color(0xFF9ABBC5), lift: 9, softness: 1.4);
    } finally {
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_BandPainter old) =>
      old.textures != textures ||
      old.ribbon != ribbon ||
      old.loop != loop ||
      old.raised != raised ||
      old.light != light;
}
