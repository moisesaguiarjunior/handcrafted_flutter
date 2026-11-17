import 'package:flutter/material.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

import 'material_studies.dart';
import 'showcase_theme.dart';

/// Six stitch families on the same closed-cut construction.
class StitchStudies extends StatelessWidget {
  /// Creates a bounded, shared-contour comparison.
  const StitchStudies({
    super.key,
    this.pitch = 16,
    this.depth = 8,
    this.width = 1.8,
    this.compression = .7,
  });

  /// Nominal seam interval in logical pixels.
  final double pitch;

  /// Transverse motif reach in logical pixels.
  final double depth;

  /// Thread width in logical pixels.
  final double width;

  /// Illustrative puncture shading strength.
  final double compression;
  @override
  Widget build(BuildContext context) => SpecimenRow(
    children: [
      for (final kind in CraftStitchKind.values)
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 210,
              child: LayoutBuilder(
                builder: (context, box) {
                  const shape = CraftOutline.pigment(
                    seed: 52,
                    broad: true,
                    padding: 5,
                  );
                  final outline = shape.pathFor(Size(box.maxWidth, 210));
                  final seam = insetCraftPath(
                    outline,
                    distance: depth + width * 4 + 2,
                    sampleSpacing: 1,
                  );
                  final pair = _pairs[kind]!;
                  return CraftSurface(
                    material: pair.material,
                    color: pair.cloth,
                    seed: 52,
                    shape: shape,
                    child: SizedBox.expand(
                      child: CustomPaint(
                        painter: _StitchPainter(
                          outline,
                          seam,
                          kind,
                          pair.thread,
                          pitch,
                          depth,
                          width,
                          compression,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Text(
              kind.name,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 19),
            ),
            Text(switch (kind) {
              CraftStitchKind.running => 'Short spans, airy gaps',
              CraftStitchKind.backstitch => 'A continuous surface seam',
              CraftStitchKind.blanket => 'Edge rail and transverse stitches',
              CraftStitchKind.chain => 'Linked loops along the curve',
              CraftStitchKind.cross => 'Crossing threads, same centerline',
              CraftStitchKind.basting => 'Long spans, short gaps',
            }),
          ],
        ),
    ],
  );
}

/// Cloth and thread pairs chosen as one palette, so each sample contrasts
/// clearly while the six read as a set.
const _pairs = {
  CraftStitchKind.running: (
    material: CraftMaterial.felt,
    cloth: DemoPalette.sage,
    thread: DemoPalette.cream,
  ),
  CraftStitchKind.backstitch: (
    material: CraftMaterial.linen,
    cloth: Color(0xFFE6D6B4),
    thread: DemoPalette.indigo,
  ),
  CraftStitchKind.blanket: (
    material: CraftMaterial.felt,
    cloth: DemoPalette.rose,
    thread: DemoPalette.cream,
  ),
  CraftStitchKind.chain: (
    material: CraftMaterial.cotton,
    cloth: DemoPalette.paper,
    thread: DemoPalette.terracotta,
  ),
  CraftStitchKind.cross: (
    material: CraftMaterial.twill,
    cloth: DemoPalette.indigo,
    thread: DemoPalette.ochre,
  ),
  CraftStitchKind.basting: (
    material: CraftMaterial.leather,
    cloth: DemoPalette.cognac,
    thread: DemoPalette.cream,
  ),
};

class _StitchPainter extends CustomPainter {
  const _StitchPainter(
    this.outline,
    this.seam,
    this.kind,
    this.thread,
    this.pitch,
    this.depth,
    this.width,
    this.compression,
  );
  final Path outline, seam;
  final CraftStitchKind kind;
  final Color thread;
  final double pitch, depth, width, compression;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipPath(outline);
    paintCraftStitch(
      canvas,
      seam,
      thread: thread,
      kind: kind,
      pitch: pitch,
      depth: depth,
      width: width,
      compression: compression,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_StitchPainter old) =>
      old.seam != seam ||
      old.kind != kind ||
      old.thread != thread ||
      old.pitch != pitch ||
      old.depth != depth ||
      old.width != width ||
      old.compression != compression;
}

/// Native parameter controls around decorative thread samples.
class StitchPlayground extends StatefulWidget {
  /// Creates the six-family comparison.
  const StitchPlayground({super.key});
  @override
  State<StitchPlayground> createState() => _StitchPlaygroundState();
}

class _StitchPlaygroundState extends State<StitchPlayground> {
  double pitch = 16, depth = 8, width = 1.8, compression = .7;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'A different way to join the edges',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      const Text(
        'Six thread patterns. One shared cut. Native controls stay outside the painting.',
      ),
      Text('Nominal spacing: ${pitch.round()} px'),
      Slider(
        value: pitch,
        min: 8,
        max: 28,
        onChanged: (v) => setState(() => pitch = v),
      ),
      Text('Transverse reach: ${depth.round()} px'),
      Slider(
        value: depth,
        min: 2,
        max: 14,
        onChanged: (v) => setState(() => depth = v),
      ),
      Text('Thread width: ${width.toStringAsFixed(1)} px'),
      Slider(
        value: width,
        min: .5,
        max: 3,
        onChanged: (v) => setState(() => width = v),
      ),
      Text('Puncture shading: ${(compression * 100).round()}%'),
      Slider(
        value: compression,
        onChanged: (v) => setState(() => compression = v),
      ),
      const SizedBox(height: 20),
      StitchStudies(
        pitch: pitch,
        depth: depth,
        width: width,
        compression: compression,
      ),
    ],
  );
}
