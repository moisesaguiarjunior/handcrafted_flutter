import 'package:flutter/widgets.dart';

/// Immutable authored pose; simulation adapters may supply the same values.
///
/// Translation is in logical pixels, rotation in radians, scale in 0.01..100.
/// Finite values are required. This is a transform, not a physical constraint.
@immutable
class PartPose {
  /// Creates a validated pose. Invalid values throw [ArgumentError].
  PartPose({
    this.translation = Offset.zero,
    this.rotation = 0,
    this.scale = 1,
  }) {
    if (!translation.dx.isFinite ||
        !translation.dy.isFinite ||
        !rotation.isFinite ||
        !scale.isFinite ||
        scale < .01 ||
        scale > 100) {
      throw ArgumentError('Expected finite pose values and scale in 0.01..100');
    }
  }

  /// Displacement in logical pixels in the parent's coordinates.
  final Offset translation;

  /// Clockwise rotation in radians in Flutter's screen coordinates.
  final double rotation;

  /// Positive uniform scale.
  final double scale;

  /// One matrix used by rendering, inverse hit testing and mapped anchors.
  Matrix4 matrixFor(Size size, Alignment pivot) {
    if (!size.width.isFinite ||
        !size.height.isFinite ||
        size.width < 0 ||
        size.height < 0 ||
        !pivot.x.isFinite ||
        !pivot.y.isFinite) {
      throw ArgumentError('Expected finite nonnegative size and finite pivot');
    }
    final anchor = pivot.alongSize(size);
    return Matrix4.identity()
      ..translateByDouble(
        anchor.dx + translation.dx,
        anchor.dy + translation.dy,
        0,
        1,
      )
      ..rotateZ(rotation)
      ..scaleByDouble(scale, scale, 1, 1)
      ..translateByDouble(-anchor.dx, -anchor.dy, 0, 1);
  }

  /// Maps a local attachment to parent coordinates through that same matrix.
  /// Throws [ArgumentError] if either local coordinate is nonfinite.
  Offset mapPoint(
    Offset point, {
    required Size size,
    Alignment pivot = Alignment.topCenter,
  }) {
    if (!point.dx.isFinite || !point.dy.isFinite) {
      throw ArgumentError.value(point, 'point', 'Coordinates must be finite');
    }
    return MatrixUtils.transformPoint(matrixFor(size, pivot), point);
  }
}

/// A keyed native-widget artwork part with one paint/input transform.
///
/// Compose parts using ordinary Stack/Positioned and nest them for parent/child
/// pivots. Supplied artwork and Material buttons remain ordinary children.
/// The host owns stable keys, actions, semantics, focus order, stacking, clipping,
/// content-safe regions and minimum targets. Reserve enough parent space for the
/// transformed part: Flutter cannot hit-test outside an ancestor's bounds.
/// No timer, automatic randomization or content scaling is introduced.
class CraftPart extends StatelessWidget {
  /// Creates a part. [size] must be finite and positive when built.
  const CraftPart({
    required super.key,
    required this.size,
    required this.pose,
    required this.child,
    this.pivot = Alignment.topCenter,
  });

  /// Logical artwork bounds, independent of the scene viewport.
  final Size size;

  /// Authored or simulated pose.
  final PartPose pose;

  /// Normalized pivot; defaults to the center of the top edge.
  final Alignment pivot;

  /// Supplied art, material composition or real interactive control.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!size.width.isFinite ||
        !size.height.isFinite ||
        size.isEmpty ||
        !pivot.x.isFinite ||
        !pivot.y.isFinite) {
      throw ArgumentError('Expected finite positive size and finite pivot');
    }
    return Transform(
      transform: pose.matrixFor(size, pivot),
      transformHitTests: true,
      child: SizedBox.fromSize(size: size, child: child),
    );
  }
}
