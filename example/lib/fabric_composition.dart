import 'package:flutter/material.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

/// Original pocket construction: back, cavity, note, front, fold and sewing.
/// Geometry stays prepared when only the shared light or insertion changes.
class FabricComposition extends StatefulWidget {
  /// Creates an original clock-free material composition.
  const FabricComposition({
    super.key,
    this.light,
    this.insertion = .25,
    this.pocketOpening = 1,
    this.foldDepth = 7,
    this.surfaceHeight = 4,
    this.seamCompression = .2,
  });

  /// Shared scene-space light.
  final CraftLight? light;

  /// Host-owned finite progress; one puts the decorative note behind the lip.
  final double insertion;

  /// Mouth separation, 0..1, independently of note insertion.
  final double pocketOpening;

  /// Folded lip depth in this example's source units, 1..14.
  final double foldDepth;

  /// Front's apparent material height, .5..8.
  final double surfaceHeight;

  /// Paint-only pressure of the localized inset seam, 0..1.
  final double seamCompression;
  @override
  State<FabricComposition> createState() => _FabricCompositionState();
}

class _FabricCompositionState extends State<FabricComposition> {
  final textures = MaterialTextures(seed: 93);
  late PocketGeometry geometry = _preparePocket();
  PocketGeometry _preparePocket() => PocketGeometry(
    opening: widget.pocketOpening,
    foldDepth: widget.foldDepth,
    surfaceHeight: widget.surfaceHeight,
  );
  @override
  void didUpdateWidget(FabricComposition old) {
    super.didUpdateWidget(old);
    if (old.pocketOpening != widget.pocketOpening ||
        old.foldDepth != widget.foldDepth ||
        old.surfaceHeight != widget.surfaceHeight) {
      geometry = _preparePocket();
    }
  }

  late final band = CraftBand(
    craftCurveThrough(const [
      Offset(18, 300),
      Offset(155, 275),
      Offset(320, 325),
      Offset(580, 275),
    ]),
    width: 32,
  );
  late final seams = [
    for (final offset in [-11.0, 11.0])
      CraftStitchFrame.sample(
        runningStitchPath(
          band.rail(offset),
          dash: 5,
          gap: 4,
          irregularity: .08,
          seed: 41,
        ),
        progress: 1,
      ),
  ];
  @override
  void dispose() {
    textures.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: 600 / 370,
    child: ExcludeSemantics(
      child: IgnorePointer(
        child: CustomPaint(
          painter: _FabricPainter(
            textures,
            geometry,
            band,
            seams,
            widget.light ?? CraftLight(),
            widget.insertion,
            widget.seamCompression,
          ),
        ),
      ),
    ),
  );
}

/// Prepared example geometry, with an explicit occluding mouth.
class PocketGeometry {
  /// Prepares all cuts and the seam outside paint.
  PocketGeometry({
    this.opening = 1,
    this.foldDepth = 7,
    this.surfaceHeight = 4,
  }) {
    if (!opening.isFinite ||
        opening < 0 ||
        opening > 1 ||
        !foldDepth.isFinite ||
        foldDepth < 1 ||
        foldDepth > 14 ||
        !surfaceHeight.isFinite ||
        surfaceHeight < .5 ||
        surfaceHeight > 8) {
      throw ArgumentError(
        'Expected opening0..1, fold1..14 and front height.5..8',
      );
    }
    final frontTop = 64 + 21 * opening, frontControl = 39 + 80 * opening;
    final lipBottom = frontTop + foldDepth,
        lipControl = frontControl + foldDepth * 8 / 7;
    back = Path()
      ..moveTo(16, 64)
      ..quadraticBezierTo(98, 34, 180, 64)
      ..lineTo(183, 222)
      ..quadraticBezierTo(184, 251, 157, 255)
      ..quadraticBezierTo(97, 267, 39, 254)
      ..quadraticBezierTo(13, 251, 14, 223)
      ..close();
    front = Path()
      ..moveTo(16, frontTop)
      ..quadraticBezierTo(98, frontControl, 180, frontTop)
      ..lineTo(183, 222)
      ..quadraticBezierTo(184, 251, 157, 255)
      ..quadraticBezierTo(97, 267, 39, 254)
      ..quadraticBezierTo(13, 251, 14, 223)
      ..close();
    cavity = Path()
      ..moveTo(16, 64)
      ..quadraticBezierTo(98, 39, 180, 64)
      ..lineTo(180, frontTop)
      ..quadraticBezierTo(98, frontControl, 16, frontTop)
      ..close();
    lip = Path()
      ..moveTo(16, frontTop)
      ..quadraticBezierTo(98, frontControl, 180, frontTop)
      ..lineTo(180, lipBottom)
      ..quadraticBezierTo(98, lipControl, 16, lipBottom)
      ..close();
    backVolume = CraftVolume(
      back,
      CraftVolumeProfile.rounded,
      height: 2,
      bevel: 8,
    );
    frontVolume = CraftVolume(
      front,
      CraftVolumeProfile.rounded,
      height: surfaceHeight,
      bevel: 13,
    );
    lipVolume = CraftVolume(lip, CraftVolumeProfile.sheet, height: 1, bevel: 3);
    patch = Path()
      ..moveTo(98, 151)
      ..cubicTo(65, 159, 77, 193, 101, 205)
      ..cubicTo(127, 187, 124, 166, 98, 151)
      ..close();
    patchVolume = CraftVolume(
      patch,
      CraftVolumeProfile.sheet,
      height: 1.5,
      bevel: 3,
    );
    seam = runningStitchPath(
      Path()
        ..moveTo(27, 112)
        ..lineTo(26, 220)
        ..quadraticBezierTo(25, 240, 43, 244)
        ..quadraticBezierTo(97, 256, 154, 245)
        ..quadraticBezierTo(172, 241, 171, 221)
        ..lineTo(170, 112),
      dash: 6,
      gap: 4,
      irregularity: .16,
      seed: 93,
    );
    seamFrame = CraftStitchFrame.sample(seam, progress: 1);
  }

  /// Example-owned mouth geometry control, independent of insertion.
  final double opening;

  /// Example-owned lip depth, independent of front material height.
  final double foldDepth;

  /// Apparent front material height; no cloth deformation is simulated.
  final double surfaceHeight;

  /// Static complete thread, shared by all pocket colorways and lights.
  late final CraftStitchFrame seamFrame;

  /// Independent cuts and the inset sewing path for this original recipe.
  late final Path back, front, cavity, lip, seam, patch;

  /// Prepared local volume for each layer.
  late final CraftVolume backVolume, frontVolume, lipVolume, patchVolume;

  /// Paints the assembled pocket. The note always precedes its occluding face.
  void paint(
    Canvas canvas,
    MaterialTextures textures,
    CraftLight light, {
    required Color color,
    double insertion = .25,
    double seamCompression = .2,
  }) {
    if (!insertion.isFinite ||
        insertion < 0 ||
        insertion > 1 ||
        !seamCompression.isFinite ||
        seamCompression < 0 ||
        seamCompression > 1) {
      throw ArgumentError('Expected insertion and seam compression0..1');
    }
    backVolume.shadow(canvas, light);
    void cloth(Path cut, Color tone, CraftVolume volume) {
      textures.paint(
        canvas,
        cut,
        material: CraftMaterial.cotton,
        color: tone,
        strength: .28,
      );
      volume.shade(canvas, light);
    }

    cloth(back, color, backVolume);
    canvas.drawPath(
      cavity,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color.lerp(color, const Color(0xFF66513D), .22)!, color],
        ).createShader(cavity.getBounds()),
    );
    final note = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(62, 17 + insertion * 111, 75, 108),
          const Radius.circular(3),
        ),
      );
    textures.paint(
      canvas,
      note,
      material: CraftMaterial.paper,
      color: const Color(0xFFFFF3D5),
      strength: .25,
    );
    paintCraftRelief(
      canvas,
      note,
      kind: CraftReliefKind.raised,
      depth: 1,
      strength: .2,
      light: light.planar,
    );
    // A note may enter from outside the mouth; the face hides its lower portion.
    cloth(front, color, frontVolume);
    patchVolume.shadow(canvas, light, receiver: front);
    textures.paint(
      canvas,
      patch,
      material: CraftMaterial.felt,
      color: color.r > color.b
          ? const Color(0xFF93AD92)
          : const Color(0xFFF0B3A0),
      strength: .2,
    );
    patchVolume.shade(canvas, light);
    paintCraftStroke(
      canvas,
      Path()
        ..moveTo(100, 194)
        ..quadraticBezierTo(88, 177, 99, 160),
      color: const Color(0x99FFF1D4),
      style: const CraftStrokeStyle(width: 1.1),
    );
    canvas.save();
    try {
      canvas.clipPath(front);
      for (final x in [28.0, 166.0]) {
        final crease = Path()
          ..moveTo(x, 223)
          ..quadraticBezierTo(
            x + (x < 100 ? 7 : -7),
            207,
            x + (x < 100 ? 4 : -4),
            191,
          );
        paintCraftStroke(
          canvas,
          crease,
          color: const Color(0x14FFFFFF),
          style: const CraftStrokeStyle(width: 2),
        );
      }
      seamFrame.paint(
        canvas,
        thread: const Color(0xFFFFF0CD),
        width: 1.5,
        compression: seamCompression,
        relief: CraftReliefKind.inset,
        light: light.planar,
      );
    } finally {
      canvas.restore();
    }
    cloth(lip, Color.lerp(color, Colors.white, .10)!, lipVolume);
  }
}

class _FabricPainter extends CustomPainter {
  _FabricPainter(
    this.textures,
    this.geometry,
    this.band,
    this.seams,
    this.light,
    this.insertion,
    this.seamCompression,
  );
  final MaterialTextures textures;
  final PocketGeometry geometry;
  final CraftBand band;
  final List<CraftStitchFrame> seams;
  final CraftLight light;
  final double insertion, seamCompression;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    try {
      canvas.scale(size.width / 600, size.height / 370);
      final board = Path()
        ..addRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(0, 0, 600, 370),
            const Radius.circular(18),
          ),
        );
      textures.paint(
        canvas,
        board,
        material: CraftMaterial.paper,
        color: const Color(0xFFFFFAF1),
        strength: .3,
      );
      canvas.clipPath(board);
      band.shadow(canvas, light, receiver: board);
      textures.paint(
        canvas,
        band.outline,
        material: CraftMaterial.paper,
        color: const Color(0xFFF0D1A0),
        strength: .35,
      );
      band.shade(canvas, light);
      for (final seam in seams) {
        seam.paint(
          canvas,
          thread: const Color(0xFFFFF3D9),
          width: 1,
          compression: .18,
          relief: CraftReliefKind.inset,
          light: light.planar,
        );
      }
      for (final (center, rotation, color) in [
        (const Offset(67, 12), -.055, const Color(0xFFEBC04F)),
        (const Offset(326, 4), .07, const Color(0xFF73B6C8)),
      ]) {
        canvas.save();
        try {
          canvas.translate(center.dx, center.dy);
          canvas.rotate(rotation);
          geometry.paint(
            canvas,
            textures,
            light.inLocalSpace(rotation),
            color: color,
            insertion: insertion,
            seamCompression: seamCompression,
          );
        } finally {
          canvas.restore();
        }
      }
    } finally {
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_FabricPainter old) =>
      old.light != light ||
      old.insertion != insertion ||
      old.seamCompression != seamCompression ||
      old.textures != textures ||
      old.geometry != geometry ||
      old.band != band;
}
