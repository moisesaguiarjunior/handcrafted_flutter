import 'package:flutter/widgets.dart';

import 'craft_part.dart';
import 'craft_placement.dart';

/// Places an image crop in an authored artboard rectangle, without a clock.
///
/// Place directly in a Stack. [rect] is expressed in that Stack's logical
/// artboard coordinates. Apply responsive scaling once to the whole artboard,
/// or supply an already scaled rect/pose. Source coordinates describe the full
/// image before cropping and need not equal decoded device-pixel dimensions.
///
/// CraftPart supplies one native transform for image, overlay and inverse hit
/// testing. [mapSourcePoint] uses that same PartPose for attachments. The image
/// provider/cache belongs to Flutter; no decoded image is manually disposed here.
/// Native controls belong in [child] or outside the artwork. The host owns their
/// focus/semantics, minimum targets, content padding, visibility and occlusion.
/// Transparent image pixels do not automatically exclude input; supply a matching
/// [sourceClip] when needed. Reserve the complete transformed hit area in the
/// parent: painting outside its bounds does not extend Flutter hit testing.
class CraftImagePart extends StatelessWidget {
  /// Creates a stable keyed image part from explicit source/artboard geometry.
  const CraftImagePart({
    required super.key,
    required this.image,
    required this.sourceSize,
    required this.sourceRect,
    required this.rect,
    this.sourceHinge,
    this.pose,
    this.sourceClip,
    this.child,
    this.semanticLabel,
    this.filterQuality = FilterQuality.medium,
  });

  /// Reuses a source/visible-contour placement for the existing image adapter.
  factory CraftImagePart.placed({
    required Key? key,
    required ImageProvider<Object> image,
    required Size sourceSize,
    required CraftPlacement placement,
    Path? sourceClip,
    Widget? child,
    String? semanticLabel,
    FilterQuality filterQuality = FilterQuality.medium,
  }) => CraftImagePart(
    key: key,
    image: image,
    sourceSize: sourceSize,
    sourceRect: placement.sourceRect,
    rect: placement.rect,
    sourceHinge: placement.sourceHinge,
    pose: placement.pose,
    sourceClip: sourceClip,
    child: child,
    semanticLabel: semanticLabel,
    filterQuality: filterQuality,
  );

  /// Any normal Flutter image provider, retaining Flutter's cache/lifecycle.
  final ImageProvider<Object> image;

  /// Positive finite dimensions of the complete source coordinate space.
  final Size sourceSize;

  /// Positive finite crop contained in the full source image.
  final Rect sourceRect;

  /// Positive finite destination rectangle in the parent artboard Stack.
  /// Different source/target aspect ratios deliberately stretch the crop.
  final Rect rect;

  /// Hinge in full source coordinates, defaulting to the crop's center.
  /// An authored hinge may lie outside the crop.
  final Offset? sourceHinge;

  /// Optional caller-supplied pose, defaulting to identity. No time is read.
  final PartPose? pose;

  /// Optional mask in full source coordinates. It clips image, overlay and input.
  /// Supply a new Path when changing it; do not mutate a supplied path in place.
  /// This is authored clipping, not alpha-pixel or occlusion detection.
  final Path? sourceClip;

  /// Optional native overlay filling the untransformed destination rectangle.
  /// Overlay padding does not resize or reposition the image underneath it.
  final Widget? child;

  /// Optional label for a meaningful image; null excludes image semantics.
  /// An interactive overlay normally supplies its own native action label.
  final String? semanticLabel;

  /// Native image sampling quality.
  final FilterQuality filterQuality;

  CraftPlacement _geometry() {
    if (!sourceSize.width.isFinite ||
        !sourceSize.height.isFinite ||
        sourceSize.isEmpty ||
        !sourceRect.isFinite ||
        sourceRect.isEmpty ||
        sourceRect.left < 0 ||
        sourceRect.top < 0 ||
        sourceRect.right > sourceSize.width ||
        sourceRect.bottom > sourceSize.height ||
        !rect.isFinite ||
        rect.isEmpty) {
      throw ArgumentError(
        'Expected finite positive source/crop/destination and a contained crop',
      );
    }
    final placement = CraftPlacement(
      sourceRect: sourceRect,
      rect: rect,
      sourceHinge: sourceHinge,
      pose: pose,
    );
    if (![
      sourceSize.width * placement.scaleX,
      sourceSize.height * placement.scaleY,
      sourceRect.left * placement.scaleX,
      sourceRect.top * placement.scaleY,
    ].every((v) => v.isFinite)) {
      throw ArgumentError(
        'Image placement overflows finite transform coordinates',
      );
    }
    final clipBounds = sourceClip?.getBounds();
    if (clipBounds != null && !clipBounds.isFinite) {
      throw ArgumentError('Expected a finite source clip');
    }
    return placement;
  }

  /// Maps an attachment from full source coordinates into the parent artboard.
  /// Ancestor responsive transforms are intentionally outside this coordinate space.
  Offset mapSourcePoint(Offset point) => _geometry().mapSourcePoint(point);

  @override
  Widget build(BuildContext context) {
    final geometry = _geometry();
    Widget content = Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          left: -sourceRect.left * geometry.scaleX,
          top: -sourceRect.top * geometry.scaleY,
          width: sourceSize.width * geometry.scaleX,
          height: sourceSize.height * geometry.scaleY,
          child: Image(
            image: image,
            fit: BoxFit.fill,
            filterQuality: filterQuality,
            semanticLabel: semanticLabel,
            excludeFromSemantics: semanticLabel == null,
          ),
        ),
        if (child != null) Positioned.fill(child: child!),
      ],
    );
    // Keep wrapper topology stable when an optional mask is added or removed.
    // Otherwise native editable/focus state in the overlay would be remounted.
    content = ClipPath(
      clipper: _SourceClip(
        sourceClip == null ? null : Path.from(sourceClip!),
        sourceRect,
      ),
      clipBehavior: sourceClip == null ? Clip.hardEdge : Clip.antiAlias,
      child: content,
    );
    return Positioned.fromRect(
      rect: rect,
      child: CraftPart(
        key: const ValueKey('image-crop'),
        size: rect.size,
        pose: geometry.pose,
        pivot: geometry.pivot,
        child: ClipRect(child: content),
      ),
    );
  }
}

class _SourceClip extends CustomClipper<Path> {
  const _SourceClip(this.source, this.crop);
  final Path? source;
  final Rect crop;
  @override
  Path getClip(Size size) => source == null
      ? (Path()..addRect(Offset.zero & size))
      : source!
            .shift(-crop.topLeft)
            .transform(
              Matrix4.diagonal3Values(
                size.width / crop.width,
                size.height / crop.height,
                1,
              ).storage,
            );
  @override
  bool shouldReclip(_SourceClip old) =>
      source != old.source || crop != old.crop;
}
