import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

/// Original painting window, including transparent space for the short shadow.
const placementWindow = Rect.fromLTWH(0, 0, 180, 140);

/// Declared contour bounds, independent of the painting window's padding.
const placementVisible = Rect.fromLTWH(42, 30, 96, 72);

/// Reproducibly authored original PNG, never a consumer asset.
const placementAsset = 'assets/layers/placement-pebble.png';

/// Original cut shared by the procedural painter and PNG authoring tool.
Path placementCut() => Path()
  ..moveTo(42, 66)
  ..cubicTo(42, 40, 62, 30, 88, 30)
  ..cubicTo(110, 30, 138, 47, 138, 68)
  ..cubicTo(138, 90, 110, 102, 86, 102)
  ..cubicTo(60, 102, 42, 88, 42, 66)
  ..close();

/// Retained synthetic paint model, used identically by authoring and live vector.
class PlacementArtwork {
  /// Prepares the original cut before painting.
  PlacementArtwork() : _cut = placementCut();

  /// Existing owner-scoped paper tile.
  final textures = MaterialTextures(seed: 103);
  final Path _cut;

  /// Paints in original source coordinates, including the short shadow.
  void paint(Canvas canvas) {
    final light = CraftLight();
    textures.paint(
      canvas,
      _cut,
      material: CraftMaterial.paper,
      color: const Color(0xFFAAC6B2),
      strength: .35,
    );
    // Source-over relief preserves a transparent export. The separate volume
    // mesh recipe requires an opaque receiver and is not a sprite exporter.
    paintCraftRelief(
      canvas,
      _cut,
      kind: CraftReliefKind.raised,
      depth: 2,
      strength: .3,
      light: light.planar,
    );
    paintCraftStroke(
      canvas,
      Path()
        ..moveTo(66, 74)
        ..quadraticBezierTo(94, 51, 116, 61),
      color: const Color(0xBBFFF4D5),
      style: const CraftStrokeStyle(
        tool: CraftStrokeTool.pencil,
        width: 2,
        dryCoverage: .6,
      ),
    );
  }

  /// Releases only this model's existing texture cache.
  void dispose() => textures.dispose();
}

/// Imported and procedural pieces fit the contour, preserving shadow padding.
class VisibleFitComparison extends StatefulWidget {
  /// Explicit progress changes pose without adding a clock.
  const VisibleFitComparison({super.key, this.progress = .5});

  /// Finite host-owned pose progress, 0..1.
  final double progress;
  @override
  State<VisibleFitComparison> createState() => _VisibleFitComparisonState();
}

class _VisibleFitComparisonState extends State<VisibleFitComparison> {
  late final artwork = PlacementArtwork();
  final selected = [false, false];
  @override
  void dispose() {
    artwork.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.progress.isFinite ||
        widget.progress < 0 ||
        widget.progress > 1) {
      throw ArgumentError('Expected progress0..1');
    }
    final model = artwork; // Prepare before either painter is constructed.
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        if (w <= 0 || constraints.maxHeight <= 0) {
          return const SizedBox.shrink();
        }
        final visibleWidth = math.min(150.0, w * .25);
        return Column(
          children: [
            SizedBox(
              height: 220,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  for (var i = 0; i < 2; i++)
                    _piece(
                      i,
                      model,
                      CraftPlacement.fit(
                        sourceRect: placementWindow,
                        visibleBounds: placementVisible,
                        target: Rect.fromCenter(
                          center: Offset(w * (i == 0 ? .25 : .75), 108),
                          width: visibleWidth,
                          height: visibleWidth * .75,
                        ),
                        pose: PartPose(
                          rotation: (widget.progress - .5) * .7,
                          translation: Offset(
                            0,
                            -8 * math.sin(widget.progress * math.pi),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const Row(
              children: [
                Expanded(
                  child: Text('Imported PNG', textAlign: TextAlign.center),
                ),
                Expanded(
                  child: Text('Procedural', textAlign: TextAlign.center),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _piece(int i, PlacementArtwork model, CraftPlacement placement) {
    final hinge = placement.sourceHinge;
    final overlay = Stack(
      children: [
        Positioned(
          left: (hinge.dx - placement.sourceRect.left) * placement.scaleX - 24,
          top: (hinge.dy - placement.sourceRect.top) * placement.scaleY - 24,
          width: 48,
          height: 48,
          child: Semantics(
            label: i == 0 ? 'Select imported piece' : 'Select procedural piece',
            child: Checkbox(
              value: selected[i],
              onChanged: (v) => setState(() => selected[i] = v!),
            ),
          ),
        ),
      ],
    );
    if (i == 0) {
      return CraftImagePart.placed(
        key: const ValueKey('visible-fit-image'),
        image: const AssetImage(placementAsset),
        sourceSize: placementWindow.size,
        placement: placement,
        child: overlay,
      );
    }
    return Positioned.fromRect(
      rect: placement.rect,
      child: CraftPart(
        key: const ValueKey('visible-fit-vector'),
        size: placement.rect.size,
        pose: placement.pose,
        pivot: placement.pivot,
        child: ClipRect(
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(painter: _SourcePainter(model, placement)),
              overlay,
            ],
          ),
        ),
      ),
    );
  }
}

class _SourcePainter extends CustomPainter {
  const _SourcePainter(this.artwork, this.placement);
  final PlacementArtwork artwork;
  final CraftPlacement placement;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    try {
      canvas.scale(placement.scaleX, placement.scaleY);
      canvas.translate(-placement.sourceRect.left, -placement.sourceRect.top);
      artwork.paint(canvas);
    } finally {
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_SourcePainter old) =>
      old.artwork != artwork ||
      old.placement.scaleX != placement.scaleX ||
      old.placement.scaleY != placement.scaleY ||
      old.placement.sourceRect != placement.sourceRect;
}

/// A dry mark fitted using its full conservative footprint, not its centerline.
class StrokeClearanceStudy extends StatelessWidget {
  /// Creates an original curved chalk mark with visible reserved margins.
  const StrokeClearanceStudy({super.key});
  @override
  Widget build(BuildContext context) => const SizedBox(
    width: double.infinity,
    height: 170,
    child: IgnorePointer(
      child: ExcludeSemantics(child: CustomPaint(painter: _ClearancePainter())),
    ),
  );
}

class _ClearancePainter extends CustomPainter {
  const _ClearancePainter();
  @override
  void paint(Canvas canvas, Size size) {
    final target = (Offset.zero & size).deflate(8);
    if (target.isEmpty) {
      return;
    }
    final path = Path()
      ..moveTo(12, 60)
      ..cubicTo(35, 2, 70, 115, 108, 44)
      ..quadraticBezierTo(133, 5, 155, 50);
    const style = CraftStrokeStyle(
      tool: CraftStrokeTool.chalk,
      width: 18,
      dryCoverage: 1,
      variation: 1,
    );
    final bounds = craftStrokeBounds(path, style: style);
    // An output-pixel gutter remains outside the mapped envelope, even when the
    // parent scales the mark down. The helper itself is in source coordinates.
    final fit = CraftPlacement.fit(sourceRect: bounds, target: target);
    canvas.save();
    try {
      canvas.translate(fit.rect.left, fit.rect.top);
      canvas.scale(fit.scaleX, fit.scaleY);
      canvas.translate(-bounds.left, -bounds.top);
      canvas.drawRect(
        bounds,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = .6 / fit.scaleX
          ..color = const Color(0xFFAEAAA3),
      );
      paintCraftStroke(
        canvas,
        path,
        color: const Color(0xFFC26B87),
        style: style,
        seed: 97,
      );
    } finally {
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ClearancePainter old) => false;
}

/// Native controls and native selection over original imported/procedural art.
class VisibleFitPlayground extends StatefulWidget {
  /// Creates the contour-fit and dry-clearance comparison.
  const VisibleFitPlayground({super.key});
  @override
  State<VisibleFitPlayground> createState() => _VisibleFitPlaygroundState();
}

class _VisibleFitPlaygroundState extends State<VisibleFitPlayground> {
  double progress = .5;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Fit the cut, keep the shadow',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      const Text(
        'The PNG and live painter share one original contour and source window. '
        'Visible bounds fit the target while transparent/shadow margins remain. The checkboxes keep native input.',
      ),
      MergeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Placement progress'),
            Slider(
              key: const ValueKey('placement-progress'),
              value: progress,
              semanticFormatterCallback: (v) => '${(v * 100).round()} percent',
              onChanged: (v) => setState(() => progress = v),
            ),
          ],
        ),
      ),
      VisibleFitComparison(progress: progress),
      const SizedBox(height: 20),
      const Text(
        'Chalk with declared clearance',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      const StrokeClearanceStudy(),
      const Text(
        'The frame includes pigment dispersion, caps and raster padding. '
        'Keep an additional output-pixel gutter when scaling down. The fit does not shrink native text.',
      ),
    ],
  );
}

/// Fixed synthetic sheet using the actual gallery pieces and dry-mark painter.
class VisibleFitSheet extends StatelessWidget {
  /// Captures the full painting window, native selection and declared clearance.
  const VisibleFitSheet({super.key});
  @override
  Widget build(BuildContext context) => const Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Fit the piece. Keep its shadow.',
        style: TextStyle(fontFamily: 'Caveat', fontSize: 42),
      ),
      Text(
        'Declared contour bounds align imported art and a live painter. The full paint window survives; selection stays native.',
      ),
      VisibleFitComparison(progress: .7),
      SizedBox(height: 24),
      Text(
        'Room for the pigment',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      StrokeClearanceStudy(),
      Text(
        'The gray frame is a conservative envelope including dry dispersion and caps, fitted with a separate output-pixel gutter.',
      ),
    ],
  );
}
