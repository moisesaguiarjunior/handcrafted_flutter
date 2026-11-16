import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

import 'showcase_theme.dart';

/// Original synthetic sprite sheet, bundled only with the example.
const layerAsset = 'assets/layers/cabinet.png';

/// Complete coordinate size of the original sprite sheet.
const layerSourceSize = Size(600, 360);

/// Crop containing the asymmetrical lid.
const lidSourceRect = Rect.fromLTWH(300, 20, 240, 120);

/// Authored hinge in the complete source coordinate space.
const lidSourceHinge = Offset(316, 32);

/// Stationary cabinet crop.
const baseSourceRect = Rect.fromLTWH(20, 170, 240, 140);

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

/// Shared authored lid geometry; no responsive fit or clock is added here.
CraftImagePart importedLidPart({
  required double progress,
  double scale = 1,
  Widget? child,
}) {
  if (!progress.isFinite ||
      progress < 0 ||
      progress > 1 ||
      !scale.isFinite ||
      scale <= 0) {
    throw ArgumentError('Expected progress 0..1 and a positive finite scale');
  }
  return CraftImagePart(
    key: const ValueKey('imported-lid'),
    image: const AssetImage(layerAsset),
    sourceSize: layerSourceSize,
    sourceRect: lidSourceRect,
    sourceHinge: lidSourceHinge,
    rect: Rect.fromLTWH(54 * scale, 218 * scale, 240 * scale, 120 * scale),
    pose: PartPose(rotation: -1.15 * progress),
    sourceClip: lidHitPath(const Size(240, 120)).shift(lidSourceRect.topLeft),
    child: child,
  );
}

/// Shared stationary crop, in the same authored coordinates as the lid.
CraftImagePart importedBasePart({double scale = 1}) => CraftImagePart(
  key: const ValueKey('imported-base'),
  image: const AssetImage(layerAsset),
  sourceSize: layerSourceSize,
  sourceRect: baseSourceRect,
  rect: Rect.fromLTWH(54 * scale, 218 * scale, 240 * scale, 140 * scale),
);

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
        final lid = importedLidPart(
          progress: progress,
          scale: scale,
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
              child: SizedBox.expand(),
            ),
          ),
        );
        final anchor = lid.mapSourcePoint(const Offset(520, 75));
        return SizedBox(
          width: 400 * scale,
          height: 440 * scale,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              importedBasePart(scale: scale),
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
              lid,
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
