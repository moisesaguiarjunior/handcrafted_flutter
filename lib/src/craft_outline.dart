import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'pigment_outline.dart';
import 'paper_edge.dart';

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
      edge = PaperEdge.cut,
      edgeDepth = 0,
      edgePitch = 12,
      radius = 0;

  /// A rounded rectangle. [radius] is measured in logical pixels.
  const CraftOutline.roundedRectangle({this.radius = 12, this.padding = 0})
    : _kind = 1,
      seed = 0,
      broad = false,
      edge = PaperEdge.cut,
      edgeDepth = 0,
      edgePitch = 12;

  /// A seeded organic contour using the canonical [pigmentOutline] algorithm.
  const CraftOutline.pigment({
    required this.seed,
    this.broad = false,
    this.padding = 0,
  }) : _kind = 2,
       edge = PaperEdge.cut,
       edgeDepth = 0,
       edgePitch = 12,
       radius = 0;

  /// A rectangular paper recipe with independent edge treatment and texture.
  const CraftOutline.paper({
    this.edge = PaperEdge.torn,
    this.seed = 7,
    this.edgeDepth = 3,
    this.edgePitch = 12,
    this.padding = 0,
  }) : _kind = 3,
       broad = false,
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

  /// Paper silhouette treatment; cut for non-paper recipes.
  final PaperEdge edge;

  /// Maximum inward paper-edge intrusion, following paperOutline's limits.
  final double edgeDepth;

  /// Paper notch/tear period in logical pixels.
  final double edgePitch;

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
    if (bounds.isEmpty) {
      if (_kind == 3) {
        paperOutline(
          Rect.zero,
          edge: edge,
          seed: seed,
          depth: edgeDepth,
          pitch: edgePitch,
        );
      }
      return Path();
    }
    return switch (_kind) {
      0 => Path()..addRect(bounds),
      1 =>
        Path()
          ..addRRect(RRect.fromRectAndRadius(bounds, Radius.circular(radius))),
      2 => pigmentOutline(bounds, seed: seed, broad: broad),
      _ => paperOutline(
        bounds,
        edge: edge,
        seed: seed,
        depth: edgeDepth,
        pitch: edgePitch,
      ),
    };
  }

  @override
  bool operator ==(Object other) =>
      other is CraftOutline &&
      _kind == other._kind &&
      seed == other.seed &&
      broad == other.broad &&
      edge == other.edge &&
      edgeDepth == other.edgeDepth &&
      edgePitch == other.edgePitch &&
      padding == other.padding &&
      radius == other.radius;

  @override
  int get hashCode => Object.hash(
    _kind,
    seed,
    broad,
    padding,
    radius,
    edge,
    edgeDepth,
    edgePitch,
  );
}
