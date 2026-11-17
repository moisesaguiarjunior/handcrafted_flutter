import 'package:flutter/material.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

import 'showcase_theme.dart';

/// The actual colored-cord painter at a readable yarn scale, live and captured.
class CordSamples extends StatelessWidget {
  /// Creates three example-owned palettes on one linen panel.
  const CordSamples({super.key});

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 760),
    child: CraftPanel(
      style: CraftPanelStyle(
        material: CraftMaterial.linen,
        color: DemoPalette.paper,
        strength: .55,
        shape: const CraftOutline.pigment(seed: 47, broad: true, padding: 4),
        padding: const EdgeInsets.all(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final sample in const [
            ('Two twisted strands', [Color(0xFF587D91), Color(0xFFEBD4AD)]),
            (
              'Three braided strands',
              [Color(0xFFB76994), Color(0xFF87CBD9), Color(0xFFF3DEB8)],
            ),
            (
              'Natural cotton tones',
              [Color(0xFFB59C7B), Color(0xFFF0E7D4), Color(0xFFD5C7AB)],
            ),
          ]) ...[
            Text(sample.$1, style: Theme.of(context).textTheme.titleMedium),
            ExcludeSemantics(
              child: IgnorePointer(
                child: SizedBox(
                  height: 94,
                  width: double.infinity,
                  child: CustomPaint(painter: _CordSample(sample.$2)),
                ),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

class _CordSample extends CustomPainter {
  const _CordSample(this.colors);
  final List<Color> colors;
  @override
  void paint(Canvas canvas, Size size) {
    if (size.width < 40) return;
    final path = Path()
      ..moveTo(18, 50)
      ..cubicTo(size.width * .22, 2, size.width * .57, 95, size.width - 18, 38);
    paintCraftTrim(
      canvas,
      path,
      color: colors.first,
      width: 26,
      pitch: 6,
      strandColors: colors,
      relief: .9,
      texture: .85,
    );
  }

  @override
  bool shouldRepaint(_CordSample old) => old.colors != colors;
}
