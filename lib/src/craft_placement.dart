import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'craft_part.dart';

/// Source-window placement shared by raster art and procedural pieces.
///
/// Fitting may use a smaller visible contour rectangle while retaining the full
/// source window for transparent padding, bevels and shadows. Source bounds are
/// declared by the caller; no alpha scan, path inference or clock is introduced.
@immutable
final class CraftPlacement {
  /// Maps an explicit source window to a destination, optionally stretching it.
  /// Hinge coordinates refer to the original source, including any padding.
  CraftPlacement({
    required this.sourceRect,
    required this.rect,
    Offset? sourceHinge,
    PartPose? pose,
  }) : sourceHinge = sourceHinge ?? sourceRect.center,
       pose = pose ?? PartPose() {
    if (!_positiveFiniteRect(sourceRect) || !_positiveFiniteRect(rect)) {
      throw ArgumentError('Expected finite positive source and destination');
    }
    scaleX = rect.width / sourceRect.width;
    scaleY = rect.height / sourceRect.height;
    pivot = Alignment(
      2 * (this.sourceHinge.dx - sourceRect.left) / sourceRect.width - 1,
      2 * (this.sourceHinge.dy - sourceRect.top) / sourceRect.height - 1,
    );
    if (![
          this.sourceHinge.dx,
          this.sourceHinge.dy,
          scaleX,
          scaleY,
          pivot.x,
          pivot.y,
        ].every((v) => v.isFinite) ||
        scaleX <= 0 ||
        scaleY <= 0) {
      throw ArgumentError('Placement overflows finite transform coordinates');
    }
    final matrix = this.pose.matrixFor(rect.size, pivot);
    if (!matrix.storage.every((v) => v.isFinite)) {
      throw ArgumentError('Placement overflows finite transform coordinates');
    }
    for (final local in [
      Offset.zero,
      Offset(rect.width, 0),
      Offset(0, rect.height),
      Offset(rect.width, rect.height),
    ]) {
      final world = rect.topLeft + MatrixUtils.transformPoint(matrix, local);
      if (!world.dx.isFinite || !world.dy.isFinite) {
        throw ArgumentError(
          'Placed painting window overflows finite coordinates',
        );
      }
    }
  }

  /// Fits the declared visible contour to [target] without trimming source paint.
  /// Uniform contain fit; alignment is finite in `-1..1` on each axis. The default
  /// hinge is the visible center. [rect] can extend beyond target because it also
  /// retains padding/shadow; reserve that full transformed region in the parent.
  factory CraftPlacement.fit({
    required Rect sourceRect,
    required Rect target,
    Rect? visibleBounds,
    Alignment alignment = Alignment.center,
    Offset? sourceHinge,
    PartPose? pose,
  }) {
    final visible = visibleBounds ?? sourceRect;
    if (!_positiveFiniteRect(sourceRect) ||
        !_positiveFiniteRect(target) ||
        !_positiveFiniteRect(visible) ||
        visible.left < sourceRect.left ||
        visible.top < sourceRect.top ||
        visible.right > sourceRect.right ||
        visible.bottom > sourceRect.bottom ||
        !alignment.x.isFinite ||
        !alignment.y.isFinite ||
        alignment.x.abs() > 1 ||
        alignment.y.abs() > 1) {
      throw ArgumentError(
        'Expected a contained visible rectangle and finite target/alignment',
      );
    }
    final fitted = alignment.inscribe(
      applyBoxFit(BoxFit.contain, visible.size, target.size).destination,
      target,
    );
    final scale = fitted.width / visible.width;
    final rect = Rect.fromLTWH(
      fitted.left + (sourceRect.left - visible.left) * scale,
      fitted.top + (sourceRect.top - visible.top) * scale,
      sourceRect.width * scale,
      sourceRect.height * scale,
    );
    final placement = CraftPlacement(
      sourceRect: sourceRect,
      rect: rect,
      sourceHinge: sourceHinge ?? visible.center,
      pose: pose,
    );
    final tx = math.max(1.0, fitted.width) * 1e-7;
    final ty = math.max(1.0, fitted.height) * 1e-7;
    for (final (point, expected) in [
      (visible.topLeft, fitted.topLeft),
      (visible.topRight, fitted.topRight),
      (visible.bottomLeft, fitted.bottomLeft),
      (visible.bottomRight, fitted.bottomRight),
      (visible.center, fitted.center),
    ]) {
      // Validate the actual retained window, not just an independently corrected
      // anchor mapper: painting uses this same source-to-local layout.
      final mapped =
          placement.rect.topLeft + placement._localSourcePoint(point);
      if (!mapped.dx.isFinite ||
          !mapped.dy.isFinite ||
          (mapped.dx - expected.dx).abs() > tx ||
          (mapped.dy - expected.dy).abs() > ty) {
        throw ArgumentError('Retained margin loses fitted-contour precision');
      }
    }
    // Validation only: use the canonical pose around a stable target-local
    // origin instead of reproducing the retained window's large cancellation.
    final linear = PartPose(
      rotation: placement.pose.rotation,
      scale: placement.pose.scale,
    ).matrixFor(Size.zero, Alignment.topLeft);
    final hingeLocal = Offset(
      (placement.sourceHinge.dx - visible.left) * scale,
      (placement.sourceHinge.dy - visible.top) * scale,
    );
    final pivotWorld = fitted.topLeft + hingeLocal + placement.pose.translation;
    final actualOrigin = placement.mapSourcePoint(visible.topLeft);
    for (final point in [
      visible.topLeft,
      visible.topRight,
      visible.bottomLeft,
      visible.bottomRight,
      visible.center,
      placement.sourceHinge,
    ]) {
      final local = Offset(
        (point.dx - visible.left) * scale,
        (point.dy - visible.top) * scale,
      );
      final expected =
          pivotWorld + MatrixUtils.transformPoint(linear, local - hingeLocal);
      final actual = placement.mapSourcePoint(point);
      final expectedDelta = MatrixUtils.transformPoint(linear, local);
      final actualDelta = actual - actualOrigin;
      if (!_withinPlacementPrecision(actual, expected, tx, ty) ||
          !_withinPlacementPrecision(actualDelta, expectedDelta, tx, ty)) {
        throw ArgumentError('Supplied pose loses fitted-contour precision');
      }
    }
    return placement;
  }

  /// Full painting window in source coordinates, including retained margins.
  final Rect sourceRect;

  /// Full unposed painting window in the parent Stack's coordinates.
  final Rect rect;

  /// Hinge in the same source coordinate system as [sourceRect].
  final Offset sourceHinge;

  /// Caller-owned pose; no time or motion policy is read here.
  final PartPose pose;

  /// Horizontal source-to-destination scale before the pose.
  late final double scaleX;

  /// Vertical source-to-destination scale before the pose.
  late final double scaleY;

  /// Normalized source hinge for the existing CraftPart transform.
  late final Alignment pivot;

  Offset _localSourcePoint(Offset point) => Offset(
    (point.dx - sourceRect.left) * scaleX,
    (point.dy - sourceRect.top) * scaleY,
  );

  /// Maps a source anchor through the same PartPose used by CraftPart.
  /// Ancestor artboard transforms are outside this local coordinate contract.
  Offset mapSourcePoint(Offset point) {
    if (!point.dx.isFinite || !point.dy.isFinite) {
      throw ArgumentError('Expected a finite attachment');
    }
    final local = _localSourcePoint(point);
    final mapped =
        rect.topLeft + pose.mapPoint(local, size: rect.size, pivot: pivot);
    if (!mapped.dx.isFinite || !mapped.dy.isFinite) {
      throw ArgumentError('Mapped attachment overflows');
    }
    return mapped;
  }
}

bool _positiveFiniteRect(Rect rect) =>
    rect.isFinite &&
    !rect.isEmpty &&
    rect.width.isFinite &&
    rect.height.isFinite;

bool _withinPlacementPrecision(
  Offset actual,
  Offset expected,
  double tx,
  double ty,
) =>
    actual.dx.isFinite &&
    actual.dy.isFinite &&
    expected.dx.isFinite &&
    expected.dy.isFinite &&
    (actual.dx - expected.dx).abs() <= tx &&
    (actual.dy - expected.dy).abs() <= ty;
