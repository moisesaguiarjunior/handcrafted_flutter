import 'package:flutter/material.dart';

import 'showcase_theme.dart';
import 'stuffed_shapes.dart';

/// Native controls over an original, clock-free stuffed-shape recipe.
class PillowStudy extends StatefulWidget {
  /// Contains no artwork or business policy from a consumer application.
  const PillowStudy({super.key});
  @override
  State<PillowStudy> createState() => _PillowStudyState();
}

class _PillowStudyState extends State<PillowStudy> {
  PillowFabric fabric = PillowFabric.cotton;
  double filling = .65;
  bool sewing = true;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        'A small sky, sewn by hand',
        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
          fontFamily: 'Caveat',
          fontSize: 38,
        ),
      ),
      const Text(
        'Choose a fabric, then give the same shapes less or more filling.',
      ),
      const SizedBox(height: 16),
      DropdownButtonFormField<PillowFabric>(
        initialValue: fabric,
        isExpanded: true,
        decoration: const InputDecoration(labelText: 'Fabric'),
        items: [
          for (final value in PillowFabric.values)
            DropdownMenuItem(
              value: value,
              child: Text(pillowFabricLabel(value)),
            ),
        ],
        onChanged: (value) {
          if (value != null) setState(() => fabric = value);
        },
      ),
      const SizedBox(height: 12),
      Text('Filling ${(filling * 100).round()}%'),
      Slider(
        value: filling,
        min: 0,
        max: 1,
        divisions: 20,
        label: '${(filling * 100).round()}%',
        semanticFormatterCallback: (v) =>
            '${(v * 100).round()} percent filling',
        onChanged: (value) => setState(() => filling = value),
      ),
      SwitchListTile(
        title: const Text('Show sewing'),
        value: sewing,
        onChanged: (value) => setState(() => sewing = value),
      ),
      const SizedBox(height: 12),
      Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          for (final shape in PillowShape.values)
            Column(
              children: [
                StuffedShape(
                  shape: shape,
                  fabric: fabric,
                  filling: filling,
                  sewing: sewing,
                  color: switch (shape) {
                    PillowShape.star => DemoPalette.ochre,
                    PillowShape.moon => DemoPalette.indigo,
                    PillowShape.sun => DemoPalette.rose,
                  },
                ),
                Text(switch (shape) {
                  PillowShape.star => 'Star',
                  PillowShape.moon => 'Moon',
                  PillowShape.sun => 'Sun',
                }),
              ],
            ),
        ],
      ),
      const SizedBox(height: 24),
      const Text(
        'Filling changes the height and rolled edge; the sewing pattern stays put. '
        'Short pile uses the existing matte fiber finish. No stretch, long fur or stuffing physics is simulated.',
      ),
    ],
  );
}

/// Controlled comparisons using the same shape/color/light within each row.
class PillowComparison extends StatelessWidget {
  /// No knobs or timers: intended for deterministic inspection and capture.
  const PillowComparison({super.key});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'A little more filling',
        style: TextStyle(fontFamily: 'Caveat', fontSize: 38),
      ),
      const Text('One cotton star. One light. Three amounts of filling.'),
      Wrap(
        spacing: 28,
        children: [
          for (final value in [.1, .5, 1.0])
            Column(
              children: [
                StuffedShape(
                  shape: PillowShape.star,
                  filling: value,
                  size: 220,
                ),
                Text('${(value * 100).round()}% filling'),
              ],
            ),
        ],
      ),
      const SizedBox(height: 28),
      const Text(
        'Three cloth surfaces',
        style: TextStyle(fontFamily: 'Caveat', fontSize: 38),
      ),
      const Text('Same moon, color and filling. Change only the fabric.'),
      Wrap(
        spacing: 28,
        children: [
          for (final fabric in PillowFabric.values)
            Column(
              children: [
                StuffedShape(
                  shape: PillowShape.moon,
                  fabric: fabric,
                  filling: .8,
                  color: DemoPalette.sage,
                  size: 220,
                ),
                Text(pillowFabricLabel(fabric)),
              ],
            ),
        ],
      ),
      const SizedBox(height: 28),
      const Text(
        'Shapes to make your own',
        style: TextStyle(fontFamily: 'Caveat', fontSize: 38),
      ),
      Wrap(
        spacing: 28,
        children: [
          for (final shape in PillowShape.values)
            StuffedShape(
              shape: shape,
              fabric: PillowFabric.shortPile,
              filling: .85,
              size: 220,
              color: switch (shape) {
                PillowShape.star => DemoPalette.rose,
                PillowShape.moon => DemoPalette.indigo,
                PillowShape.sun => DemoPalette.ochre,
              },
            ),
        ],
      ),
    ],
  );
}
