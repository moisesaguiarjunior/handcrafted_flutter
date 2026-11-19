import 'package:flutter/material.dart';

import 'showcase_theme.dart';
import 'surface_proofs.dart';

void main() =>
    runApp(MaterialApp(theme: showcaseTheme(), home: const SurfaceLab()));

/// Native controls surrounding a retained, scrollable decorative field.
class SurfaceLab extends StatefulWidget {
  /// Standalone example; no second timeline or private scene content.
  const SurfaceLab({super.key});

  @override
  State<SurfaceLab> createState() => _SurfaceLabState();
}

class _SurfaceLabState extends State<SurfaceLab> {
  SurfaceRecipe _recipe = SurfaceRecipe.featheredWash;
  late SurfaceProof _scene = SurfaceProof(recipe: _recipe);

  void _select(SurfaceRecipe value) {
    if (_recipe == value) return;
    final replacement = SurfaceProof(recipe: value);
    setState(() {
      _scene.dispose();
      _scene = replacement;
      _recipe = value;
    });
  }

  @override
  void dispose() {
    _scene.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('One surface, many windows')),
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: DropdownButtonFormField<SurfaceRecipe>(
            initialValue: _recipe,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Surface recipe'),
            items: SurfaceRecipe.values
                .map(
                  (value) => DropdownMenuItem(
                    value: value,
                    child: Text(switch (value) {
                      SurfaceRecipe.watercolor => 'Layered wash',
                      SurfaceRecipe.featheredWash => 'Soft wash',
                      SurfaceRecipe.fibers => 'Fibers',
                      SurfaceRecipe.checker => 'Checks',
                      SurfaceRecipe.diamonds => 'Diamonds',
                    }),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) _select(value);
            },
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Scroll through a retained 960 × 1728 source. The texture '
            'and print keep their position. Text stays outside the painting.',
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth.clamp(1.0, 640.0);
              return Center(
                child: SizedBox(
                  width: width,
                  child: SingleChildScrollView(
                    child: ExcludeSemantics(
                      child: IgnorePointer(
                        child: CustomPaint(
                          size: Size(width, _scene.domain.height),
                          painter: _SurfacePainter(_scene, width),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
}

class _SurfacePainter extends CustomPainter {
  _SurfacePainter(this.scene, this.width);
  final SurfaceProof scene;
  final double width;

  @override
  void paint(Canvas canvas, Size size) => scene.paintViewport(
    canvas,
    Rect.fromLTWH(
      (scene.domain.width - width) / 2,
      0,
      width,
      scene.domain.height,
    ),
  );

  @override
  bool shouldRepaint(_SurfacePainter oldDelegate) =>
      oldDelegate.scene != scene || oldDelegate.width != width;
}
