import 'package:flutter/material.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';
import 'showcase_theme.dart';
import 'stuffed_shapes.dart';

/// The same independent finish over every substrate and original padded cut.
class FluffySwatch extends StatefulWidget {
  /// Geometry is retained across material/color changes; no clock is owned.
  const FluffySwatch({
    super.key,
    this.material = CraftMaterial.felt,
    this.shape,
    this.fiberLength = 3.5,
    this.curl = .65,
    this.edgeFuzz = .8,
    this.density = 1,
    this.size = 180,
    this.color = const Color(0xFF9FC5DC),
  });

  /// Existing underlying substrate.
  final CraftMaterial material;

  /// Null uses a flat cut; otherwise an original padded silhouette.
  final PillowShape? shape;

  /// Independent length multiplier, .25..6.
  final double fiberLength;

  /// Curved strand amount, 0..1.
  final double curl;

  /// Optional outward fringe fraction, 0..1.
  final double edgeFuzz;

  /// Candidate admission rate, 0..1.
  final double density;

  /// Display window with a 24px source margin on each side.
  final double size;

  /// Opaque substrate and fiber tone.
  final Color color;
  @override
  State<FluffySwatch> createState() => _FluffySwatchState();
}

class _FluffySwatchState extends State<FluffySwatch> {
  final textures = MaterialTextures(seed: 71);
  late CraftVolume volume;
  late CraftNap nap;
  @override
  void initState() {
    super.initState();
    _prepare();
  }

  void _prepare({bool body = true}) {
    final cut = widget.shape == null
        ? (Path()..addRRect(
            RRect.fromRectAndRadius(
              const Rect.fromLTWH(11, 18, 90, 76),
              const Radius.circular(19),
            ),
          ))
        : pillowCut(widget.shape!);
    if (body) {
      volume = CraftVolume(
        cut,
        widget.shape == null
            ? CraftVolumeProfile.sheet
            : CraftVolumeProfile.padded,
        height: widget.shape == null ? 3 : 22,
      );
    }
    nap = CraftNap(
      volume.outline,
      scale: 1.25,
      density: widget.density,
      fiberLength: widget.fiberLength,
      curl: widget.curl,
      edgeFuzz: widget.edgeFuzz,
    );
  }

  @override
  void didUpdateWidget(FluffySwatch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.shape != widget.shape ||
        oldWidget.fiberLength != widget.fiberLength ||
        oldWidget.curl != widget.curl ||
        oldWidget.edgeFuzz != widget.edgeFuzz ||
        oldWidget.density != widget.density) {
      _prepare(body: oldWidget.shape != widget.shape);
    }
  }

  @override
  void dispose() {
    textures.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.size.isFinite || widget.size <= 0 || widget.color.a != 1) {
      throw ArgumentError('Expected positive finite size and opaque substrate');
    }
    return ExcludeSemantics(
      child: IgnorePointer(
        child: RepaintBoundary(
          child: SizedBox.square(
            dimension: widget.size,
            child: CustomPaint(
              painter: _FluffyPainter(volume, nap, textures, widget),
            ),
          ),
        ),
      ),
    );
  }
}

class _FluffyPainter extends CustomPainter {
  _FluffyPainter(this.volume, this.nap, this.textures, this.specimen);
  final CraftVolume volume;
  final CraftNap nap;
  final MaterialTextures textures;
  final FluffySwatch specimen;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    try {
      canvas.scale(size.width / 160, size.height / 160);
      canvas.translate(24, 24);
      final light = plushPillowLight();
      volume.shadow(canvas, light);
      textures.paint(
        canvas,
        volume.outline,
        material: specimen.material,
        color: specimen.color,
        strength: .45,
      );
      nap.paint(
        canvas,
        contrast: 1,
        ink: Color.lerp(specimen.color, DemoPalette.ink, .3)!,
        highlight: Color.lerp(specimen.color, Colors.white, .5)!,
      );
      volume.shade(canvas, light);
    } finally {
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_FluffyPainter old) =>
      old.volume != volume ||
      old.nap != nap ||
      old.specimen.material != specimen.material ||
      old.specimen.color != specimen.color;
}

/// Native controls over a finish independent from the selected material.
class FluffyMaterialsStudy extends StatefulWidget {
  /// Flat and padded specimens share geometry parameters and palette.
  const FluffyMaterialsStudy({super.key});
  @override
  State<FluffyMaterialsStudy> createState() => _FluffyMaterialsStudyState();
}

class _FluffyMaterialsStudyState extends State<FluffyMaterialsStudy> {
  final focus = {
    for (final label in ['Fiber length', 'Curl', 'Edge fuzz', 'Density'])
      label: FocusNode(debugLabel: label),
  };
  @override
  void dispose() {
    for (final node in focus.values) {
      node.dispose();
    }
    super.dispose();
  }

  CraftMaterial material = CraftMaterial.felt;
  double length = 3.5, curl = .65, fringe = .8, density = 1;
  Widget slider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> changed,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label),
      Slider(
        key: ValueKey(label),
        focusNode: focus[label],
        value: value,
        min: min,
        max: max,
        divisions: 20,
        label: value.toStringAsFixed(2),
        onChanged: changed,
      ),
    ],
  );
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('A softer edge', style: Theme.of(context).textTheme.headlineMedium),
      const Text(
        'One fluffy finish on any substrate, including a padded star.',
      ),
      DropdownButtonFormField<CraftMaterial>(
        initialValue: material,
        isExpanded: true,
        decoration: const InputDecoration(labelText: 'Underlying material'),
        items: [
          for (final value in CraftMaterial.values)
            DropdownMenuItem(value: value, child: Text(value.name)),
        ],
        onChanged: (value) {
          if (value != null) setState(() => material = value);
        },
      ),
      slider('Fiber length', length, .25, 6, (v) => setState(() => length = v)),
      slider('Curl', curl, 0, 1, (v) => setState(() => curl = v)),
      slider('Edge fuzz', fringe, 0, 1, (v) => setState(() => fringe = v)),
      slider('Density', density, 0, 1, (v) => setState(() => density = v)),
      Wrap(
        spacing: 24,
        runSpacing: 16,
        children: [
          for (final pillow in [false, true])
            Column(
              children: [
                FluffySwatch(
                  material: material,
                  shape: pillow ? PillowShape.star : null,
                  fiberLength: length,
                  curl: curl,
                  edgeFuzz: fringe,
                  density: density,
                ),
                Text(pillow ? 'Padded star' : 'Flat substrate'),
              ],
            ),
        ],
      ),
      const Text(
        'Seeded matte fibers with reserved fringe space. No fur physics or extra clock.',
      ),
    ],
  );
}

/// Fixed atlas of nine substrates and three padded cuts using the same finish.
class FluffyComparison extends StatelessWidget {
  /// New original study, not a replacement for approved images.
  const FluffyComparison({super.key});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'A softer edge',
        style: TextStyle(fontFamily: 'Caveat', fontSize: 42),
      ),
      const Text(
        'One curled finish over nine substrates, then three padded cuts.',
      ),
      Wrap(
        spacing: 20,
        runSpacing: 8,
        children: [
          for (final material in CraftMaterial.values)
            Column(
              children: [
                FluffySwatch(
                  material: material,
                  size: 225,
                  color: switch (material.index % 3) {
                    0 => const Color(0xFF9FC5DC),
                    1 => const Color(0xFFCDC6AE),
                    _ => const Color(0xFFD6A9A1),
                  },
                ),
                Text(material.name),
              ],
            ),
        ],
      ),
      const SizedBox(height: 18),
      const Text(
        'The finish follows the shape',
        style: TextStyle(fontFamily: 'Caveat', fontSize: 32),
      ),
      Wrap(
        spacing: 20,
        children: [
          for (final shape in PillowShape.values)
            Column(
              children: [
                FluffySwatch(shape: shape, size: 225),
                Text(shape.name),
              ],
            ),
        ],
      ),
    ],
  );
}
