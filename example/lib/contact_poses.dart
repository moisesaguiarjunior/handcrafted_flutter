import 'package:flutter/material.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

/// Smooth authored phase, independent of frame history.
double gesturePhase(double value, double from, double to) {
  final t = ((value - from) / (to - from)).clamp(0.0, 1.0);
  return t * t * (3 - 2 * t);
}

/// Validates an external normalized timeline before sampling geometry.
void checkGestureProgress(double progress) {
  if (!progress.isFinite || progress < 0 || progress > 1) {
    throw ArgumentError('Expected progress in 0..1');
  }
}

/// Example-owned sheet transfer; every sample is independent of previous frames.
class TransferPose {
  /// Samples approach, shared support and release from an external timeline.
  TransferPose(double progress) {
    checkGestureProgress(progress);
    final travel = gesturePhase(progress, .15, .85);
    sheet = PartPose(
      translation: Offset(-30 + travel * 60, -12 * travel),
      rotation: -.16 + .3 * travel,
    );
    leftRelease = gesturePhase(progress, .68, 1);
    rightApproach = 1 - gesturePhase(progress, 0, .32);
  }

  /// Source sheet dimensions; its native child uses these same layout bounds.
  static const sheetSize = Size(184, 136);

  /// Sheet placement before applying its local pose.
  static const sheetOrigin = Offset(228, 104);

  /// Safe central area, deliberately outside both finger bands.
  static const printArea = Rect.fromLTWH(32, 23, 120, 76);

  /// One pose for the sheet, its mapped contacts and the foreground fingers.
  late final PartPose sheet;

  /// Finite free-hand withdrawal after the other hand supports the sheet.
  late final double leftRelease;

  /// Finite free-hand approach before shared support.
  late final double rightApproach;

  /// True while the left hand must remain registered to the sheet.
  bool get leftSupports => leftRelease == 0;

  /// True once the right hand has completed its approach.
  bool get rightSupports => rightApproach == 0;

  /// Local contact mapped through the actual sheet matrix.
  Offset contact(bool left) =>
      sheetOrigin +
      sheet.mapPoint(
        Offset(left ? 7 : 177, 88),
        size: sheetSize,
        pivot: Alignment.center,
      );

  /// Hand displacement is zero for its entire supporting interval.
  Offset handOffset(bool left) => left
      ? Offset(-66 * leftRelease, 44 * leftRelease)
      : Offset(70 * rightApproach, 26 * rightApproach);

  /// Both rear palms and front fingers use this exact same matrix.
  Matrix4 handMatrix(bool left) => Matrix4.identity()
    ..translateByDouble(
      sheetOrigin.dx + handOffset(left).dx,
      sheetOrigin.dy + handOffset(left).dy,
      0,
      1,
    )
    ..multiply(sheet.matrixFor(sheetSize, Alignment.center));

  /// Original soft fingertip; the front ink stays inside a narrow edge band.
  static Path fingers(bool left) {
    final path = Path()
      ..moveTo(-8, 78)
      ..cubicTo(5, 73, 18, 75, 18, 81)
      ..cubicTo(18, 85, 9, 86, 5, 86)
      ..cubicTo(15, 85, 20, 91, 15, 95)
      ..quadraticBezierTo(4, 101, -8, 98)
      ..close();
    return left
        ? path
        : path.transform(
            (Matrix4.identity()
                  ..translateByDouble(sheetSize.width, 0, 0, 1)
                  ..scaleByDouble(-1, 1, 1, 1))
                .storage,
          );
  }
}

/// Two original link dimensions; the same choreography supports both cuts.
enum ClothCut {
  /// Longer, narrow textile strip.
  sleeve,

  /// Shorter, wider textile strip.
  scarf,
}

/// An authored cloth-joint study, not a flexible-cloth simulation.
class ClothPose {
  /// Keeps the shoulder fixed, then releases the distal link with a delay.
  ClothPose(double progress, this.cut) {
    checkGestureProgress(progress);
    final upperRelease = gesturePhase(progress, .3, .7);
    final tipRelease = gesturePhase(progress, .48, .94);
    upper = PartPose(rotation: .32 - .4 * upperRelease);
    lower = PartPose(rotation: 2.05 - 2.13 * tipRelease);
  }

  /// Authored cut; geometry changes without changing the timeline contract.
  final ClothCut cut;

  /// Fixed board-space shoulder.
  static const shoulder = Offset(340, 84);

  /// Width in material coordinates.
  double get width => cut == ClothCut.sleeve ? 54 : 74;

  /// Proximal material length.
  double get upperLength => cut == ClothCut.sleeve ? 102 : 80;

  /// Distal material length.
  double get lowerLength => cut == ClothCut.sleeve ? 98 : 82;

  /// Proximal world rotation about its pinned top center.
  late final PartPose upper;

  /// Distal world rotation; delayed relative to the proximal release.
  late final PartPose lower;

  /// First link's untransformed top-left, centered on the shoulder.
  Offset get upperOrigin => shoulder - Offset(width / 2, 0);

  /// The distal pivot is always mapped from the actual proximal endpoint.
  Offset get elbow =>
      upperOrigin +
      upper.mapPoint(
        Offset(width / 2, upperLength),
        size: Size(width, upperLength),
      );

  /// Second link's untransformed top-left.
  Offset get lowerOrigin => elbow - Offset(width / 2, 0);

  /// The free end follows the distal surface transform.
  Offset get cuff =>
      lowerOrigin +
      lower.mapPoint(
        Offset(width / 2, lowerLength),
        size: Size(width, lowerLength),
      );
}
