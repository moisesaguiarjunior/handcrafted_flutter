import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'pigment_outline.dart';

/// An immutable silhouette recipe compared by value rather than callback identity.
///
/// Recreate equivalent recipes freely during build. [padding] reserves space
/// inside the layout rectangle; it is not a constant-distance path inset.
/// Paths returned by [pathFor] are fresh and may be modified by their owner.
@immutable
final class CraftOutline {
  /// The rectangular layout bounds, optionally padded inward.
  const CraftOutline.rectangle({this.padding = 0})
    : _kind = 0,
      seed = 0,
      broad = false,
      radius = 0;

  /// A rounded rectangle. [radius] is measured in logical pixels.
  const CraftOutline.roundedRectangle({this.radius = 12, this.padding = 0})
    : _kind = 1,
      seed = 0,
      broad = false;

  /// A seeded organic contour using the canonical [pigmentOutline] algorithm.
  const CraftOutline.pigment({
    required this.seed,
    this.broad = false,
    this.padding = 0,
  }) : _kind = 2,
       radius = 0;

  final int _kind;

  /// Deterministic organic contour seed; zero for geometric recipes.
  final int seed;

  /// Whether the organic contour has a squarer silhouette.
  final bool broad;

  /// Layout margin, finite and nonnegative.
  final double padding;

  /// Rounded-rectangle radius, finite and nonnegative.
  final double radius;

  /// Builds the silhouette in local layout coordinates.
  ///
  /// Invalid recipe values or negative/nonfinite sizes throw [ArgumentError].
  /// Empty sizes or padding consuming the bounds yield an empty path.
  Path pathFor(Size size) {
    if (!size.width.isFinite ||
        !size.height.isFinite ||
        size.width < 0 ||
        size.height < 0 ||
        !padding.isFinite ||
        padding < 0 ||
        !radius.isFinite ||
        radius < 0) {
      throw ArgumentError(
        'Expected finite nonnegative size, padding and radius',
      );
    }
    final bounds = (Offset.zero & size).deflate(padding);
    if (bounds.isEmpty) return Path();
    return switch (_kind) {
      0 => Path()..addRect(bounds),
      1 =>
        Path()
          ..addRRect(RRect.fromRectAndRadius(bounds, Radius.circular(radius))),
      _ => pigmentOutline(bounds, seed: seed, broad: broad),
    };
  }

  @override
  bool operator ==(Object other) =>
      other is CraftOutline &&
      _kind == other._kind &&
      seed == other.seed &&
      broad == other.broad &&
      padding == other.padding &&
      radius == other.radius;

  @override
  int get hashCode => Object.hash(_kind, seed, broad, padding, radius);
}
