import 'package:flutter/material.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

import 'showcase_theme.dart';

/// Original compositions sharing the public trim renderer and real substrates.
class TrimStudies extends StatelessWidget {
  /// Builds three deterministic material plates.
  const TrimStudies({
    super.key,
    this.width = 10,
    this.gap = 10,
    this.relief = .8,
  });

  /// Band width in logical pixels.
  final double width;

  /// Nominal edge clearance excluding shadow.
  final double gap;

  /// Illustrative shading strength.
  final double relief;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => Wrap(
      spacing: 24,
      runSpacing: 24,
      children: [
        for (final kind in CraftTrimKind.values)
          SizedBox(
            width: constraints.maxWidth.clamp(0, 300).toDouble(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(switch (kind) {
                  CraftTrimKind.rope => 'Cord on linen',
                  CraftTrimKind.ribbon => 'Ribbon on cut paper',
                  CraftTrimKind.embroidered => 'Thread on twill',
                }, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                CraftSurface(
                  material: switch (kind) {
                    CraftTrimKind.rope => CraftMaterial.linen,
                    CraftTrimKind.ribbon => CraftMaterial.paper,
                    CraftTrimKind.embroidered => CraftMaterial.twill,
                  },
                  color: kind == CraftTrimKind.embroidered
                      ? DemoPalette.sage
                      : DemoPalette.paper,
                  seed: 31,
                  strength: .8,
                  outline: kind == CraftTrimKind.rope ? null : _trimOutline,
                  shape: kind == CraftTrimKind.rope
                      ? const CraftOutline.pigment(
                          seed: 31,
                          broad: true,
                          padding: 4,
                        )
                      : null,
                  child: SizedBox(
                    width: double.infinity,
                    height: 220,
                    child: CustomPaint(
                      painter: _TrimPlate(kind, width, gap, relief),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  kind == CraftTrimKind.rope
                      ? 'An open looping cord; no motion clock.'
                      : 'A shaped border with $gap px nominal clearance.',
                ),
              ],
            ),
          ),
      ],
    ),
  );
}

Path _trimOutline(Size size) {
  final x = size.width / 300;
  final y = size.height / 220;
  return Path()
    ..moveTo(30 * x, 110 * y)
    ..cubicTo(60 * x, 20 * y, 210 * x, 12 * y, 270 * x, 95 * y)
    ..cubicTo(292 * x, 168 * y, 163 * x, 210 * y, 67 * x, 180 * y)
    ..quadraticBezierTo(10 * x, 165 * y, 30 * x, 110 * y)
    ..close();
}

class _TrimPlate extends CustomPainter {
  _TrimPlate(this.kind, this.width, this.gap, this.relief) {
    outline = _trimOutline(const Size(300, 220));
    border = contourTrimPath(outline, width: width, gap: gap, sampleSpacing: 1);
    cord = craftCurveThrough(const [
      Offset(32, 157),
      Offset(72, 65),
      Offset(157, 54),
      Offset(220, 110),
      Offset(147, 163),
      Offset(114, 108),
      Offset(258, 65),
    ]);
    sprig = Path()
      ..moveTo(102, 160)
      ..quadraticBezierTo(152, 115, 190, 67)
      ..moveTo(139, 126)
      ..quadraticBezierTo(96, 80, 121, 77)
      ..quadraticBezierTo(143, 83, 139, 126)
      ..moveTo(160, 102)
      ..quadraticBezierTo(207, 102, 208, 81)
      ..quadraticBezierTo(185, 73, 160, 102);
  }
  final CraftTrimKind kind;
  final double width;
  final double gap;
  final double relief;
  late final Path outline;
  late final Path border;
  late final Path cord;
  late final Path sprig;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 300, size.height / 220);
    if (kind != CraftTrimKind.rope) canvas.clipPath(outline);
    paintCraftTrim(
      canvas,
      kind == CraftTrimKind.rope ? cord : border,
      color: kind == CraftTrimKind.ribbon
          ? DemoPalette.thread
          : DemoPalette.wood,
      kind: kind,
      width: width,
      pitch: kind == CraftTrimKind.embroidered ? 3 : 6,
      relief: relief,
    );
    if (kind == CraftTrimKind.embroidered) {
      paintCraftTrim(
        canvas,
        sprig,
        color: DemoPalette.paper,
        kind: kind,
        width: 5,
        pitch: 2,
        relief: relief,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_TrimPlate old) =>
      old.kind != kind ||
      old.width != width ||
      old.gap != gap ||
      old.relief != relief;
}

/// Native controls remain independent of the painted plates.
class TrimPlayground extends StatefulWidget {
  /// Creates native controls for the material plates.
  const TrimPlayground({super.key});
  @override
  State<TrimPlayground> createState() => _TrimPlaygroundState();
}

class _TrimPlaygroundState extends State<TrimPlayground> {
  double width = 10;
  double gap = 10;
  double relief = .8;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'A line you can almost touch',
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      const SizedBox(height: 12),
      const Text(
        'Cord, ribbon and stitched sprigs over real material recipes.',
      ),
      Text('Band width: ${width.round()} px'),
      Slider(
        value: width,
        min: 2,
        max: 20,
        divisions: 18,
        label: '${width.round()} px',
        onChanged: (v) => setState(() => width = v),
      ),
      Text('Nominal edge gap: ${gap.round()} px'),
      Slider(
        value: gap,
        max: 20,
        divisions: 20,
        label: '${gap.round()} px',
        onChanged: (v) => setState(() => gap = v),
      ),
      Text('Illustrative relief: ${(relief * 100).round()}%'),
      Slider(value: relief, onChanged: (v) => setState(() => relief = v)),
      const SizedBox(height: 20),
      TrimStudies(width: width, gap: gap, relief: relief),
    ],
  );
}
