import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

import 'showcase_theme.dart';

/// Example adapter for an authored crop; source coordinates remain explicit.
/// This is not a package manifest or an alpha-hit-test implementation.
@immutable
class SourceLayer {
  /// Validates a crop against its complete finite source canvas.
  SourceLayer({
    required this.sourceSize,
    required this.crop,
    required this.hinge,
  }) {
    if (!sourceSize.width.isFinite ||
        !sourceSize.height.isFinite ||
        sourceSize.isEmpty ||
        !crop.isFinite ||
        crop.isEmpty ||
        !(Offset.zero & sourceSize).contains(crop.topLeft) ||
        crop.right > sourceSize.width ||
        crop.bottom > sourceSize.height ||
        !hinge.dx.isFinite ||
        !hinge.dy.isFinite) {
      throw ArgumentError('Expected finite source dimensions, crop and hinge');
    }
  }

  /// Full image dimensions before cropping.
  final Size sourceSize;

  /// Visible source rectangle.
  final Rect crop;

  /// Authored hinge in full source coordinates.
  final Offset hinge;

  /// Hinge normalized to the crop, independent of display size.
  Alignment get pivot => Alignment(
    2 * (hinge.dx - crop.left) / crop.width - 1,
    2 * (hinge.dy - crop.top) / crop.height - 1,
  );

  /// Converts a source coordinate into the actual laid-out crop.
  Offset localPoint(Offset sourcePoint, Size effectiveSize) => Offset(
    (sourcePoint.dx - crop.left) * effectiveSize.width / crop.width,
    (sourcePoint.dy - crop.top) * effectiveSize.height / crop.height,
  );

  /// Maps a source attachment through the same pose as its artwork.
  Offset mapPoint(Offset sourcePoint, Size effectiveSize, PartPose pose) =>
      pose.mapPoint(
        localPoint(sourcePoint, effectiveSize),
        size: effectiveSize,
        pivot: pivot,
      );
}

/// Original synthetic sprite sheet, bundled only with the example.
const layerAsset = 'assets/layers/cabinet.png';

/// Asymmetric lid crop with an off-center hinge.
final lidLayer = SourceLayer(
  sourceSize: const Size(600, 360),
  crop: const Rect.fromLTWH(300, 20, 240, 120),
  hinge: const Offset(316, 32),
);

/// Stationary cabinet crop from the same sprite sheet.
final baseLayer = SourceLayer(
  sourceSize: const Size(600, 360),
  crop: const Rect.fromLTWH(20, 170, 240, 140),
  hinge: const Offset(36, 182),
);

/// Authored hit silhouette, independent of transparent image pixels.
Path lidHitPath(Size size) {
  final path = Path()
    ..moveTo(8, 10)
    ..lineTo(215, 3)
    ..lineTo(236, 31)
    ..lineTo(228, 110)
    ..lineTo(22, 118)
    ..lineTo(3, 94)
    ..close();
  return path.transform(
    Matrix4.diagonal3Values(size.width / 240, size.height / 120, 1).storage,
  );
}

class _LidClip extends CustomClipper<Path> {
  const _LidClip();
  @override
  Path getClip(Size size) => lidHitPath(size);
  @override
  bool shouldReclip(_LidClip oldClipper) => false;
}

/// Displays the supplied source pixels; no scene artwork is redrawn at runtime.
class CroppedArtwork extends StatelessWidget {
  /// Displays a crop in its parent's finite bounds.
  const CroppedArtwork({super.key, required this.layer});

  /// Source image crop to display.
  final SourceLayer layer;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, bounds) {
      final sx = bounds.maxWidth / layer.crop.width;
      final sy = bounds.maxHeight / layer.crop.height;
      return ClipRect(
        child: Stack(
          children: [
            Positioned(
              left: -layer.crop.left * sx,
              top: -layer.crop.top * sy,
              width: layer.sourceSize.width * sx,
              height: layer.sourceSize.height * sy,
              child: Image.asset(
                layerAsset,
                fit: BoxFit.fill,
                excludeFromSemantics: true,
                filterQuality: FilterQuality.medium,
              ),
            ),
          ],
        ),
      );
    },
  );
}

/// An imported lid and a native action, driven solely by caller-supplied time.
class ImportedComposition extends StatelessWidget {
  /// Creates a static pose and optional native actions.
  const ImportedComposition({
    super.key,
    required this.progress,
    this.onLidPressed,
    this.onInspect,
  });

  /// Explicit opening progress in 0..1.
  final double progress;

  /// Optional action on the moving lid.
  final VoidCallback? onLidPressed;

  /// Optional action on the revealed contents.
  final VoidCallback? onInspect;

  @override
  Widget build(BuildContext context) {
    if (!progress.isFinite || progress < 0 || progress > 1) {
      throw ArgumentError.value(progress, 'progress', 'Expected 0..1');
    }
    return LayoutBuilder(
      builder: (context, bounds) {
        final scale = math.min(bounds.maxWidth / 400, 1.0);
        final size = Size(240 * scale, 120 * scale);
        final origin = Offset(54, 218) * scale;
        final pose = PartPose(rotation: -1.15 * progress);
        final anchor =
            origin + lidLayer.mapPoint(const Offset(520, 75), size, pose);
        return SizedBox(
          width: 400 * scale,
          height: 440 * scale,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: origin.dx,
                top: origin.dy,
                width: size.width,
                height: 140 * scale,
                child: CroppedArtwork(layer: baseLayer),
              ),
              // Hidden contents leave input, focus and semantics by being unmounted.
              if (progress >= .85)
                Positioned(
                  left: origin.dx + size.width / 2 - 24,
                  top: origin.dy + 60 * scale - 24,
                  child: IconButton(
                    key: const ValueKey('inspect-specimen'),
                    tooltip: 'Inspect the specimen',
                color: DemoPalette.paper,
                    onPressed: onInspect,
                    icon: const Icon(Icons.local_florist_outlined),
                  ),
                ),
              Positioned(
                left: origin.dx,
                top: origin.dy,
                width: size.width,
                height: size.height,
                child: CraftPart(
                  key: const ValueKey('imported-lid'),
                  size: size,
                  pose: pose,
                  pivot: lidLayer.pivot,
                  child: ClipPath(
                    clipper: const _LidClip(),
                    child: TextButton(
                      onPressed: onLidPressed,
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: const RoundedRectangleBorder(),
                      ),
                      child: Semantics(
                        label: 'Lift or close the lid',
                        child: CroppedArtwork(layer: lidLayer),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _AttachmentPainter(
                      anchor,
                      Offset(350, 395) * scale,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: anchor.dx - 5,
                top: anchor.dy - 5,
                child: const IgnorePointer(
                  child: SizedBox(
                    key: ValueKey('lid-anchor'),
                    width: 10,
                    height: 10,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: DemoPalette.rose,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AttachmentPainter extends CustomPainter {
  const _AttachmentPainter(this.start, this.end);
  final Offset start, end;
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(end.dx + 12, start.dy + 80, end.dx, end.dy);
    paintCraftStroke(
      canvas,
      path,
      color: DemoPalette.thread,
      style: const CraftStrokeStyle(pattern: CraftLinePattern.dashed, width: 2),
    );
    canvas.drawCircle(end, 4, Paint()..color = DemoPalette.thread);
  }

  @override
  bool shouldRepaint(_AttachmentPainter old) =>
      start != old.start || end != old.end;
}

/// Native controls for a reversible, externally timed imported composition.
class ImportedLayerPlayground extends StatefulWidget {
  /// Creates the standalone composition controls.
  const ImportedLayerPlayground({super.key});
  @override
  State<ImportedLayerPlayground> createState() =>
      _ImportedLayerPlaygroundState();
}

class _ImportedLayerPlaygroundState extends State<ImportedLayerPlayground> {
  double _progress = 0;
  int _inspections = 0;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'A cabinet of pressed flowers',
        style: TextStyle(fontFamily: 'Caveat', fontSize: 38),
      ),
      const Text(
        'Imported pixels, an authored hinge, and a thread attached to the lid.',
      ),
      Center(
        child: ImportedComposition(
          progress: _progress,
          onLidPressed: () =>
              setState(() => _progress = _progress < .5 ? 1 : 0),
          onInspect: () => setState(() => _inspections++),
        ),
      ),
      Text('Lid ${(_progress * 100).round()}% · inspections $_inspections'),
      Slider(
        key: const ValueKey('lid-progress'),
        value: _progress,
        onChanged: (v) => setState(() => _progress = v),
      ),
      Wrap(
        spacing: 12,
        children: [
          TextButton(
            onPressed: () => setState(() => _progress = 0),
            child: const Text('Close lid'),
          ),
          TextButton(
            onPressed: () => setState(() => _progress = 1),
            child: const Text('Open lid'),
          ),
        ],
      ),
      const Text(
        'Only artwork scales. The native action retains its touch size. '
        'Closed contents leave focus and semantics; progress creates no clock.',
      ),
    ],
  );
}
