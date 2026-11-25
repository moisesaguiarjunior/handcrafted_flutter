import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

import 'contact_poses.dart';
import 'gesture_surfaces.dart';
import 'showcase_theme.dart';

/// Analytic two-link contact: the hand follows the moving stool, never a second
/// independently interpolated target. All poses are random-access samples.
class SoftFigureFrame {
  /// One finite reach and pull, with an independently tilting head.
  SoftFigureFrame(double progress) {
    checkGestureProgress(progress);
    final reach = gesturePhase(progress, 0, .3);
    final pull = gesturePhase(progress, .3, .85);
    stool = PartPose(translation: Offset(406 - 48 * pull, 248));
    grip = stool.mapPoint(
      const Offset(9, 2),
      size: Size.zero,
      pivot: Alignment.topLeft,
    );
    hand = Offset.lerp(const Offset(350, 220), grip, reach)!;
    final d = hand - shoulder;
    final distance = d.distance;
    final along = d / distance;
    final a =
        (upperLength * upperLength -
            lowerLength * lowerLength +
            distance * distance) /
        (2 * distance);
    final h = math.sqrt(math.max(0, upperLength * upperLength - a * a));
    elbow = shoulder + along * a + Offset(-along.dy, along.dx) * h;
    upper = _link(shoulder, elbow);
    lower = _link(elbow, hand);
    head = PartPose(
      translation: const Offset(248, 108),
      rotation: -.12 + .26 * gesturePhase(progress, .1, .8),
    );
    touching = progress >= .3;
  }

  static PartPose _link(Offset a, Offset b) =>
      PartPose(translation: a, rotation: math.atan2((b - a).dy, (b - a).dx));

  /// Shoulder remains inside the torso.
  static const shoulder = Offset(321, 194);

  /// Segment lengths are preserved by the analytic elbow construction.
  static const upperLength = 63.0, lowerLength = 57.0;

  /// Scene poses used for both drawing and attachment mapping.
  late final PartPose stool, head, upper, lower;

  /// Stool contact and analytic arm joints in board coordinates.
  late final Offset grip, hand, elbow;

  /// Whether the finite reach has established its stool contact.
  late final bool touching;
}

class _SoftCut {
  _SoftCut(this.path)
    : nap = CraftNap(
        path,
        scale: .7,
        density: .85,
        fiberLength: 1.4,
        seed: 181,
      );
  final Path path;
  final CraftNap nap;
  final models = <FigureMaterial, CraftVolume>{};
  CraftVolume model(FigureMaterial material) => models.putIfAbsent(
    material,
    () => CraftVolume(
      path,
      material == FigureMaterial.linen
          ? CraftVolumeProfile.sheet
          : CraftVolumeProfile.rounded,
      height: material == FigureMaterial.linen ? 3 : 9,
      bevel: material == FigureMaterial.linen ? 5 : 14,
    ),
  );
}

/// Prepared original cuts; geometry/fibers survive every progress/light change.
class SoftFigureArt {
  /// Prepared body silhouette and local finish.
  final body = _SoftCut(
    Path()..addRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(0, 0, 92, 112),
        const Radius.circular(32),
      ),
    ),
  );

  /// Prepared head silhouette and local finish.
  final head = _SoftCut(Path()..addOval(const Rect.fromLTWH(0, 0, 80, 76)));

  /// Prepared nose silhouette and local finish.
  final nose = _SoftCut(Path()..addOval(const Rect.fromLTWH(0, 0, 23, 17)));

  /// Prepared collar silhouette and local finish.
  final collar = _SoftCut(
    Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(37, 13, 74, 0)
      ..lineTo(62, 15)
      ..quadraticBezierTo(37, 23, 12, 15)
      ..close(),
  );

  /// Prepared upper silhouette and local finish.
  final upper = _SoftCut(
    Path()..addRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-9, -11, 81, 22),
        const Radius.circular(11),
      ),
    ),
  );

  /// Prepared lower silhouette and local finish.
  final lower = _SoftCut(
    Path()..addRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(-9, -10, 75, 20),
        const Radius.circular(10),
      ),
    ),
  );

  /// Prepared hand silhouette and local finish.
  final hand = _SoftCut(Path()..addOval(const Rect.fromLTWH(-12, -10, 24, 20)));

  void _piece(
    Canvas c,
    _SoftCut cut,
    PartPose pose,
    FigureMaterial material,
    Color color,
    MaterialTextures textures,
    CraftLight world, {
    Path? receiver,
  }) {
    final matrix = pose.matrixFor(Size.zero, Alignment.topLeft);
    final light = world.inLocalSpace(pose.rotation);
    if (receiver != null) {
      c.save();
      c.clipPath(receiver);
      c.transform(matrix.storage);
      cut.model(material).shadow(c, light);
      c.restore();
    }
    c.save();
    c.transform(matrix.storage);
    final substrate = switch (material) {
      FigureMaterial.felt => CraftMaterial.felt,
      FigureMaterial.linen => CraftMaterial.linen,
      FigureMaterial.clay => CraftMaterial.eva,
    };
    textures.paint(
      c,
      cut.path,
      material: substrate,
      color: color,
      strength: material == FigureMaterial.clay ? .08 : .8,
    );
    if (material == FigureMaterial.felt) {
      cut.nap.paint(
        c,
        ink: Color.lerp(color, DemoPalette.ink, .18)!,
        highlight: Color.lerp(color, Colors.white, .5)!,
        contrast: .65,
      );
    }
    cut.model(material).shade(c, light);
    c.restore();
  }

  /// One scene light is converted into each piece's local coordinates.
  void paint(
    Canvas c,
    SoftFigureFrame frame,
    FigureMaterial material,
    MaterialTextures textures,
    CraftLight light, {
    bool guides = false,
  }) {
    final torsoPose = PartPose(translation: const Offset(245, 175));
    final torso = body.path.transform(
      torsoPose.matrixFor(Size.zero, Alignment.topLeft).storage,
    );
    c.drawOval(
      const Rect.fromLTWH(241, 285, 112, 14),
      Paint()
        ..color = DemoPalette.ink.withValues(alpha: .12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    // Feet belong beneath the torso; the seat shares its contact transform.
    c.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(251, 274, 34, 17),
        const Radius.circular(8),
      ),
      Paint()..color = DemoPalette.ochre,
    );
    c.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(310, 274, 34, 17),
        const Radius.circular(8),
      ),
      Paint()..color = DemoPalette.ochre,
    );
    c.save();
    c.transform(frame.stool.matrixFor(Size.zero, Alignment.topLeft).storage);
    c.drawOval(
      const Rect.fromLTWH(-2, 43, 78, 10),
      Paint()
        ..color = DemoPalette.ink.withValues(alpha: .1)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    for (final x in [8.0, 60.0]) {
      c.drawLine(
        Offset(x, 8),
        Offset(x - 3, 48),
        Paint()
          ..color = DemoPalette.wood
          ..strokeWidth = 9
          ..strokeCap = StrokeCap.round,
      );
    }
    textures.paint(
      c,
      Path()..addRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(0, 0, 72, 13),
          const Radius.circular(5),
        ),
      ),
      material: CraftMaterial.wood,
      color: DemoPalette.wood,
    );
    c.restore();
    _piece(c, body, torsoPose, material, DemoPalette.sage, textures, light);
    _piece(
      c,
      collar,
      PartPose(translation: const Offset(254, 174)),
      material,
      DemoPalette.cream,
      textures,
      light,
      receiver: torso,
    );
    _piece(
      c,
      head,
      frame.head,
      material,
      DemoPalette.ochre,
      textures,
      light,
      receiver: torso,
    );
    // These details are children of the same head matrix, including shadows.
    c.save();
    c.transform(frame.head.matrixFor(Size.zero, Alignment.topLeft).storage);
    final localLight = light.inLocalSpace(frame.head.rotation);
    _piece(
      c,
      nose,
      PartPose(translation: const Offset(65, 38)),
      material,
      DemoPalette.rose,
      textures,
      localLight,
      receiver: head.path,
    );
    c.drawCircle(const Offset(53, 29), 2.2, Paint()..color = DemoPalette.ink);
    c.drawArc(
      const Rect.fromLTWH(48, 43, 15, 9),
      .1,
      1.8,
      false,
      Paint()
        ..color = DemoPalette.ink.withValues(alpha: .55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3,
    );
    c.restore();
    _piece(
      c,
      upper,
      frame.upper,
      material,
      DemoPalette.sage,
      textures,
      light,
      receiver: torso,
    );
    _piece(c, lower, frame.lower, material, DemoPalette.sage, textures, light);
    _piece(
      c,
      hand,
      PartPose(translation: frame.hand),
      material,
      DemoPalette.ochre,
      textures,
      light,
    );
    if (guides) {
      for (final p in [SoftFigureFrame.shoulder, frame.elbow, frame.hand]) {
        c.drawCircle(
          p,
          3,
          Paint()
            ..color = p == SoftFigureFrame.shoulder
                ? DemoPalette.indigo
                : DemoPalette.terracotta,
        );
      }
    }
  }
}
