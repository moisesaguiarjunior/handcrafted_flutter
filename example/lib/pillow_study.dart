import 'package:flutter/material.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

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
  final fillingFocus = FocusNode(debugLabel: 'Pillow filling');
  @override
  void dispose() {
    fillingFocus.dispose();
    super.dispose();
  }

  PillowFabric fabric = PillowFabric.cotton;
  double filling = .65;
  double previewFilling = .65;
  bool sewing = true;
  bool moreDepth = false;
  bool rakingLight = false;

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
        focusNode: fillingFocus,
        value: filling,
        min: 0,
        max: 1,
        divisions: 20,
        label: '${(filling * 100).round()}%',
        semanticFormatterCallback: (v) =>
            '${(v * 100).round()} percent filling',
        onChanged: (value) => setState(() {
          filling = value;
          if (!moreDepth) previewFilling = value;
        }),
        onChangeEnd: (value) => setState(() => previewFilling = value),
      ),
      SwitchListTile(
        title: const Text('More depth'),
        subtitle: const Text(
          'Rounded sides; release the filling slider to update',
        ),
        value: moreDepth,
        onChanged: (value) => setState(() {
          moreDepth = value;
          previewFilling = filling;
        }),
      ),
      SwitchListTile(
        title: const Text('Raking light'),
        subtitle: const Text(
          'Use the same lower light across all three shapes',
        ),
        value: rakingLight,
        onChanged: (value) => setState(() => rakingLight = value),
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
                  filling: previewFilling,
                  sewing: sewing,
                  moreDepth: moreDepth,
                  light: rakingLight ? pillowRakingLight() : null,
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

/// Same original cut/color/filling/light with the optional deeper side panel.
class PillowDepthComparison extends StatelessWidget {
  /// The original comparison remains unchanged and is captured separately.
  const PillowDepthComparison({super.key});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'A little more dimension',
        style: TextStyle(fontFamily: 'Caveat', fontSize: 40),
      ),
      const Text(
        'Same pattern, cloth, filling and light. Rounded sides add an oblique view.',
      ),
      const SizedBox(height: 16),
      for (final shape in PillowShape.values) ...[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final depth in [false, true])
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(depth ? 'Rounded depth' : 'Original relief'),
                    StuffedShape(
                      shape: shape,
                      filling: .9,
                      size: 245,
                      moreDepth: depth,
                      light: pillowRakingLight(),
                      color: switch (shape) {
                        PillowShape.star => DemoPalette.ochre,
                        PillowShape.moon => DemoPalette.indigo,
                        PillowShape.sun => DemoPalette.rose,
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
      ],
    ],
  );
}

/// One explicit shared light for the optional raking-light study/comparison.
CraftLight pillowRakingLight() =>
    CraftLight(z: .55, ambient: .65, direct: .5, softness: .5, warmth: .18);

/// Native finite input over two textile studies on the same padded body.
class PlushPillowStudy extends StatefulWidget {
  /// Does not change the approved relief or oblique-depth specimens.
  const PlushPillowStudy({super.key});
  @override
  State<PlushPillowStudy> createState() => _PlushPillowStudyState();
}

class _PlushPillowStudyState extends State<PlushPillowStudy> {
  final paddingFocus = FocusNode(debugLabel: 'Plush padding');
  @override
  void dispose() {
    paddingFocus.dispose();
    super.dispose();
  }

  double filling = .85;
  double committedFilling = .85;
  bool reverseLight = false;
  bool showJunction = false;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Soft all the way to the tips',
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      const Text(
        'One padded star, two fabrics. Same color, filling and light.',
      ),
      Text('Padding ${(filling * 100).round()}%'),
      Slider(
        value: filling,
        focusNode: paddingFocus,
        divisions: 20,
        semanticFormatterCallback: (v) =>
            '${(v * 100).round()} percent padding',
        onChanged: (v) => setState(() => filling = v),
        onChangeEnd: (v) => setState(() => committedFilling = v),
      ),
      const Text('Release to update the prepared body.'),
      SwitchListTile(
        title: const Text('Light from the right'),
        value: reverseLight,
        onChanged: (v) => setState(() => reverseLight = v),
      ),
      SwitchListTile(
        title: const Text('Show junction stitch'),
        value: showJunction,
        onChanged: (v) => setState(() => showJunction = v),
      ),
      Wrap(
        spacing: 24,
        runSpacing: 16,
        children: [
          for (final fabric in PlushFabric.values)
            Column(
              children: [
                PlushPillow(
                  fabric: fabric,
                  filling: committedFilling,
                  light: plushPillowLight(fromRight: reverseLight),
                  sewing: showJunction,
                ),
                Text(
                  fabric == PlushFabric.shortPile
                      ? 'Short plush'
                      : 'Curled sherpa',
                ),
              ],
            ),
        ],
      ),
      const Text(
        'Illustrative padding and fibers; not cloth physics or a 3D camera.',
      ),
    ],
  );
}

/// Deterministic controlled proof, separate from the approved original PNG.
class PlushPillowComparison extends StatelessWidget {
  /// All rows compare equal geometry, filling, color and incoming light.
  const PlushPillowComparison({super.key});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Soft little stars',
        style: TextStyle(fontFamily: 'Caveat', fontSize: 42),
      ),
      const Text('Short plush and curled sherpa. One shape, one light.'),
      for (final filling in [.25, .65, 1.0]) ...[
        const SizedBox(height: 14),
        Text('${(filling * 100).round()}% padding'),
        Row(
          children: [
            for (final fabric in PlushFabric.values)
              Expanded(
                child: Column(
                  children: [
                    PlushPillow(fabric: fabric, filling: filling, size: 270),
                    Text(
                      fabric == PlushFabric.shortPile
                          ? 'Short plush'
                          : 'Curled sherpa',
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    ],
  );
}
