import 'package:flutter/material.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

/// Original composition testing local volume under one scene-space light.
/// Shapes and profiles are example recipes, independent of a consumer's artwork.
class MixedVolumeStudy extends StatefulWidget {
  /// Host owns the light. No timer or animation controller is created here.
  const MixedVolumeStudy({super.key, this.light});

  /// One shared directional source for uniformly scaled, planar-rotated pieces.
  final CraftLight? light;

  @override
  State<MixedVolumeStudy> createState() => _MixedVolumeStudyState();
}

class _MixedVolumeStudyState extends State<MixedVolumeStudy> {
  final textures = MaterialTextures(seed: 71);
  late final pieces = <_Piece>[
    _Piece(
      Path()
        ..moveTo(-94, 25)
        ..cubicTo(-115, -8, -68, -52, -35, -25)
        ..cubicTo(-20, -72, 46, -61, 55, -19)
        ..cubicTo(101, -39, 122, 31, 77, 39)
        ..lineTo(-68, 39)
        ..quadraticBezierTo(-87, 38, -94, 25)
        ..close(),
      CraftVolumeProfile.sheet,
      const Color(0xFF83B7CC),
      const Offset(140, 99),
      -.13,
    ),
    _Piece(
      Path()
        ..moveTo(-75, 24)
        ..cubicTo(-78, -53, 2, -56, 72, -26)
        ..cubicTo(68, 33, -15, 60, -75, 24)
        ..close(),
      CraftVolumeProfile.rounded,
      const Color(0xFFE9A081),
      const Offset(385, 100),
      .29,
    ),
    _Piece(
      Path()
        ..moveTo(-136, -22)
        ..quadraticBezierTo(-12, -49, 126, -24)
        ..lineTo(111, 0)
        ..lineTo(134, 25)
        ..quadraticBezierTo(-11, 3, -132, 30)
        ..lineTo(-116, 3)
        ..close(),
      CraftVolumeProfile.sheet,
      const Color(0xFFE6BF65),
      const Offset(203, 228),
      -.16,
    ),
    _Piece(
      Path()
        ..fillType = PathFillType.evenOdd
        ..addOval(const Rect.fromLTWH(-43, -43, 86, 86))
        ..addOval(const Rect.fromLTWH(-13, -4, 7, 7))
        ..addOval(const Rect.fromLTWH(6, -4, 7, 7)),
      CraftVolumeProfile.rounded,
      const Color(0xFF9BAF83),
      const Offset(433, 233),
      -.25,
    ),
  ];

  @override
  void dispose() {
    textures.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: 540 / 330,
    child: ExcludeSemantics(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _MixedPainter(
            textures,
            pieces,
            widget.light ?? CraftLight(),
          ),
        ),
      ),
    ),
  );
}

class _Piece {
  _Piece(
    Path cut,
    CraftVolumeProfile profile,
    this.color,
    this.center,
    this.rotation,
  ) : volume = CraftVolume(cut, profile);
  final CraftVolume volume;
  final Color color;
  final Offset center;
  final double rotation;
}

class _MixedPainter extends CustomPainter {
  _MixedPainter(this.textures, this.pieces, this.light);
  final MaterialTextures textures;
  final List<_Piece> pieces;
  final CraftLight light;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    try {
      canvas.scale(size.width / 540, size.height / 330);
      final board = Path()
        ..addRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(0, 0, 540, 330),
            const Radius.circular(18),
          ),
        );
      textures.paint(
        canvas,
        board,
        material: CraftMaterial.paper,
        color: const Color(0xFFFFFAF2),
        strength: .3,
      );
      canvas.clipPath(board);
      for (final piece in pieces) {
        canvas.save();
        try {
          canvas.translate(piece.center.dx, piece.center.dy);
          canvas.rotate(piece.rotation);
          final local = light.inLocalSpace(piece.rotation);
          piece.volume.shadow(canvas, local);
          textures.paint(
            canvas,
            piece.volume.outline,
            material: CraftMaterial.eva,
            color: piece.color,
            strength: piece.volume.profile == CraftVolumeProfile.sheet
                ? .32
                : .08,
          );
          piece.volume.shade(canvas, local);
        } finally {
          canvas.restore();
        }
      }
    } finally {
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_MixedPainter old) =>
      old.textures != textures || old.pieces != pieces || old.light != light;
}
