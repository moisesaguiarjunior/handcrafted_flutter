import 'hanging_study.dart';

import 'package:flutter/material.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

void main() => runApp(const ContourExample());

/// Independent synthetic gallery for the extracted materials and seam study.
class ContourExample extends StatelessWidget {
  /// Creates the standalone gallery.
  const ContourExample({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: ThemeData(colorSchemeSeed: const Color(0xFF51685F)),
    home: const _MaterialStudy(),
  );
}

class _MaterialStudy extends StatefulWidget {
  const _MaterialStudy();

  @override
  State<_MaterialStudy> createState() => _MaterialStudyState();
}

class _MaterialStudyState extends State<_MaterialStudy> {
  var _seed = 7;
  var _textures = MaterialTextures();
  double _grain = 1;
  double _scale = 1;
  double _compression = .7;
  bool _reverseLight = false;

  @override
  void dispose() {
    _textures.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Material & stitch study')),
    body: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'Five extracted textures. One shared contour. Running stitch.',
        ),
        const Text(
          'Puncture relief is shading only; the weave is not deformed.',
        ),
        Wrap(
          spacing: 16,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _control('Grain', _grain, 0, 1, (v) => setState(() => _grain = v)),
            _control(
              'Texture scale',
              _scale,
              .5,
              4,
              (v) => setState(() => _scale = v),
            ),
            _control(
              'Puncture compression',
              _compression,
              0,
              1,
              (v) => setState(() => _compression = v),
            ),
            OutlinedButton(
              onPressed: () => setState(() {
                _textures.dispose();
                _textures = MaterialTextures(seed: ++_seed);
              }),
              child: Text('Reseed ($_seed)'),
            ),
            FilterChip(
              label: const Text('Reverse light'),
              selected: _reverseLight,
              onSelected: (v) => setState(() => _reverseLight = v),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const HangingStudy(),
        Wrap(
          spacing: 24,
          runSpacing: 24,
          children: [
            for (final material in CraftMaterial.values)
              SizedBox(
                width: 240,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      material.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    RepaintBoundary(
                      child: SizedBox(
                        width: 240,
                        height: 180,
                        child: CustomPaint(
                          painter: _MaterialPainter(
                            _textures,
                            material,
                            _seed,
                            _grain,
                            _scale,
                            _compression,
                            _reverseLight,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'Next: paper recipes (cardstock, kraft, solid/corrugated board) '
          'and letterhead as printing over a substrate. See docs/materials-map.md.',
        ),
      ],
    ),
  );

  Widget _control(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) => SizedBox(
    width: 240,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label ${value.toStringAsFixed(2)}'),
        Slider(
          label: label,
          value: value,
          min: min,
          max: max,
          onChanged: onChanged,
        ),
      ],
    ),
  );
}

class _MaterialPainter extends CustomPainter {
  _MaterialPainter(
    this.textures,
    this.material,
    this.seed,
    this.grain,
    this.scale,
    this.compression,
    this.reverseLight,
  );

  final MaterialTextures textures;
  final CraftMaterial material;
  final int seed;
  final double grain;
  final double scale;
  final double compression;
  final bool reverseLight;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = (Offset.zero & size).deflate(12);
    final outline = pigmentOutline(bounds, seed: seed, broad: true);
    textures.paint(
      canvas,
      outline,
      material: material,
      color: const Color(0xFFB8B09C),
      strength: grain,
      scale: scale,
    );
    // Scale the same outline around its center for this convex sample.
    // This is not a general constant-distance inset for concave shapes.
    canvas.save();
    canvas.clipPath(outline);
    // Transform once for both seam painting and puncture positions.
    final transform = Matrix4.identity()
      ..translateByDouble(bounds.center.dx, bounds.center.dy, 0, 1)
      ..scaleByDouble(.86, .82, 1, 1)
      ..translateByDouble(-bounds.center.dx, -bounds.center.dy, 0, 1);
    paintRunningStitch(
      canvas,
      outline.transform(transform.storage),
      thread: const Color(0xFF704136),
      compression: compression,
      light: reverseLight ? const Offset(1, 1) : const Offset(-1, -1),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_MaterialPainter old) =>
      old.textures != textures ||
      old.material != material ||
      old.seed != seed ||
      old.grain != grain ||
      old.scale != scale ||
      old.compression != compression ||
      old.reverseLight != reverseLight;
}
