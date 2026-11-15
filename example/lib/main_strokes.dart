import 'package:flutter/material.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

import 'use_cases.dart';

void main() => runApp(const StrokePlaygroundApp());

/// Interactive, synthetic drawing study; the same widgets can be captured.
class StrokePlaygroundApp extends StatelessWidget {
  /// Creates the drawing playground.
  const StrokePlaygroundApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: showcaseTheme(),
    home: const RepaintBoundary(
      key: ValueKey('stroke-playground'),
      child: StrokePlayground(),
    ),
  );
}

/// Native controls composing geometry, instrument, pattern and explicit time.
class StrokePlayground extends StatefulWidget {
  /// Creates a study without starting automatic movement.
  const StrokePlayground({super.key});
  @override
  State<StrokePlayground> createState() => _StrokePlaygroundState();
}

class _StrokePlaygroundState extends State<StrokePlayground> {
  CraftStrokeTool _tool = CraftStrokeTool.pen;
  CraftLinePattern _pattern = CraftLinePattern.dashed;
  CraftMaterial _material = CraftMaterial.paper;
  double _width = 3;
  double _curvature = .8;
  double? _manualProgress = .62;
  int _seed = 23;
  int _replay = 0;

  CraftStrokeStyle get _style => CraftStrokeStyle(
    tool: _tool,
    pattern: _pattern,
    width: _width,
    dash: 10,
    gap: _width + 8,
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: SceneEntrance(
        key: ValueKey(_replay),
        active: _manualProgress == null,
        startSettled: _manualProgress != null,
        builder: (context, time) {
          final progress = _manualProgress ?? time;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'A line takes a walk',
                      style: TextStyle(
                        fontFamily: 'Caveat',
                        fontSize: 48,
                        color: DemoPalette.ink,
                      ),
                    ),
                    const Text(
                      'Choose the curve, then choose what leaves the mark.',
                    ),
                    const SizedBox(height: 24),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final preview = _preview(progress);
                        final controls = _controls(progress);
                        if (constraints.maxWidth < 820) {
                          return Column(
                            children: [
                              preview,
                              const SizedBox(height: 24),
                              controls,
                            ],
                          );
                        }
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: preview),
                            const SizedBox(width: 32),
                            SizedBox(width: 285, child: controls),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Three ways to leave a mark',
                      style: TextStyle(fontFamily: 'Caveat', fontSize: 32),
                    ),
                    const SizedBox(height: 8),
                    const StrokeComparison(),
                    const SizedBox(height: 20),
                    const Text(
                      'Ink and brush grain are visual approximations. '
                      'The same path works with your own widgets and frame timeline.',
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    ),
  );

  Widget _preview(double progress) => CraftSurface(
    material: _material,
    color: DemoPalette.paper,
    seed: _seed,
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_toolLabel(_tool)} on ${_material.name}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Semantics(
            label:
                'Curved ${_pattern.name} ${_toolLabel(_tool).toLowerCase()} line, '
                '${(progress * 100).round()} percent drawn',
            child: SizedBox(
              height: 270,
              width: double.infinity,
              child: CustomPaint(
                painter: _StrokePainter(
                  style: _style,
                  progress: progress,
                  curvature: _curvature,
                  seed: _seed,
                  track: true,
                ),
              ),
            ),
          ),
          const Text(
            'A small detour',
            style: TextStyle(
              fontFamily: 'Caveat',
              fontSize: 28,
              color: Color(0xFF79445F),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _controls(double progress) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      DropdownButtonFormField<CraftStrokeTool>(
        isExpanded: true,
        itemHeight: null,
        initialValue: _tool,
        decoration: const InputDecoration(labelText: 'Instrument'),
        items: [
          for (final tool in CraftStrokeTool.values)
            DropdownMenuItem(value: tool, child: Text(_toolLabel(tool))),
        ],
        onChanged: (value) => setState(() {
          _tool = value!;
          _width = switch (_tool) {
            CraftStrokeTool.pen => 3,
            CraftStrokeTool.marker => 14,
            CraftStrokeTool.brush => 12,
          };
        }),
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<CraftLinePattern>(
        isExpanded: true,
        itemHeight: null,
        initialValue: _pattern,
        decoration: const InputDecoration(labelText: 'Pattern'),
        items: [
          for (final pattern in CraftLinePattern.values)
            DropdownMenuItem(
              value: pattern,
              child: Text(_patternLabel(pattern)),
            ),
        ],
        onChanged: (value) => setState(() => _pattern = value!),
      ),
      const SizedBox(height: 12),
      DropdownButtonFormField<CraftMaterial>(
        isExpanded: true,
        itemHeight: null,
        initialValue: _material,
        decoration: const InputDecoration(labelText: 'Surface'),
        items: [
          for (final material in [
            CraftMaterial.paper,
            CraftMaterial.linen,
            CraftMaterial.felt,
          ])
            DropdownMenuItem(value: material, child: Text(material.name)),
        ],
        onChanged: (value) => setState(() => _material = value!),
      ),
      const SizedBox(height: 20),
      Text('Width ${_width.toStringAsFixed(1)}'),
      Slider(
        key: const ValueKey('stroke-width'),
        value: _width,
        min: .5,
        max: 24,
        semanticFormatterCallback: (v) =>
            '${v.toStringAsFixed(1)} logical pixels',
        onChanged: (v) => setState(() => _width = v),
      ),
      Text('Curvature ${(_curvature * 100).round()}%'),
      Slider(
        key: const ValueKey('stroke-curvature'),
        value: _curvature,
        onChanged: (v) => setState(() => _curvature = v),
      ),
      Text('Drawn ${(progress * 100).round()}%'),
      Slider(
        key: const ValueKey('stroke-progress'),
        value: progress,
        semanticFormatterCallback: (v) => '${(v * 100).round()} percent drawn',
        onChanged: (v) => setState(() => _manualProgress = v),
      ),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          FilledButton(
            onPressed: () => setState(() {
              _manualProgress = null;
              _replay++;
            }),
            child: const Text('Draw again'),
          ),
          OutlinedButton(
            onPressed: () => setState(() => _manualProgress = 1),
            child: const Text('Complete line'),
          ),
          TextButton(
            onPressed: () => setState(() => _seed++),
            child: const Text('Change grain'),
          ),
        ],
      ),
    ],
  );
}

String _toolLabel(CraftStrokeTool tool) => switch (tool) {
  CraftStrokeTool.pen => 'Pen',
  CraftStrokeTool.marker => 'Broad marker',
  CraftStrokeTool.brush => 'Brush',
};
String _patternLabel(CraftLinePattern pattern) => switch (pattern) {
  CraftLinePattern.solid => 'Continuous',
  CraftLinePattern.dashed => 'Dashed',
  CraftLinePattern.dotted => 'Dotted',
};

/// Nine static combinations, shared by the playground and explicit captures.
class StrokeComparison extends StatelessWidget {
  /// Creates a comparison with no clocks or asynchronous resources.
  const StrokeComparison({super.key});
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => Wrap(
      spacing: 20,
      runSpacing: 20,
      children: [
        for (final tool in CraftStrokeTool.values)
          SizedBox(
            width: constraints.maxWidth < 600
                ? constraints.maxWidth
                : (constraints.maxWidth - 40) / 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _toolLabel(tool),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                for (final pattern in CraftLinePattern.values)
                  SizedBox(
                    height: 56,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: _StrokePainter(
                        style: CraftStrokeStyle(
                          tool: tool,
                          pattern: pattern,
                          width: tool == CraftStrokeTool.pen ? 2 : 10,
                          dash: tool == CraftStrokeTool.pen ? 8 : 16,
                          gap: tool == CraftStrokeTool.pen ? 6 : 16,
                        ),
                        progress: 1,
                        curvature: .8,
                        seed: 23,
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    ),
  );
}

class _StrokePainter extends CustomPainter {
  _StrokePainter({
    required this.style,
    required this.progress,
    required this.curvature,
    required this.seed,
    this.track = false,
  });
  final CraftStrokeStyle style;
  final double progress;
  final double curvature;
  final int seed;
  final bool track;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = (Offset.zero & size).deflate(18);
    if (bounds.isEmpty) return;
    final path = craftCurveThrough([
      Offset(bounds.left, bounds.top + bounds.height * .6),
      Offset(
        bounds.left + bounds.width * .26,
        bounds.top + bounds.height * .15,
      ),
      Offset(
        bounds.left + bounds.width * .56,
        bounds.top + bounds.height * .85,
      ),
      Offset(bounds.right, bounds.top + bounds.height * .35),
    ], curvature: curvature);
    if (track) {
      paintCraftStroke(
        canvas,
        path,
        color: const Color(0xFFC7CBC8),
        style: const CraftStrokeStyle(
          pattern: CraftLinePattern.dotted,
          width: 1.5,
          gap: 7,
        ),
      );
    }
    paintCraftStroke(
      canvas,
      path,
      color: const Color(0xFF79445F),
      style: style,
      progress: progress,
      seed: seed,
    );
  }

  @override
  bool shouldRepaint(_StrokePainter old) =>
      old.style != style ||
      old.progress != progress ||
      old.curvature != curvature ||
      old.seed != seed ||
      old.track != track;
}
