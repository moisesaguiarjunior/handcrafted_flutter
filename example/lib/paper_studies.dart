import 'package:flutter/material.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

import 'material_studies.dart';
import 'prepared_outline.dart';
import 'seam_studies.dart';
import 'showcase_theme.dart';

const _papers = [
  (
    'Cardstock',
    Color(0xFFF4E9D7),
    null,
    .18,
    'Smooth paper recipe, restrained grain',
  ),
  (
    'Kraft',
    Color(0xFFBF9669),
    PaperFinish.recycled,
    .55,
    'Warm substrate with visible pale fibers',
  ),
  (
    'Recycled',
    Color(0xFFD5C5A8),
    PaperFinish.recycled,
    .4,
    'Mixed short fibers and inclusions',
  ),
  (
    'Corrugated board',
    Color(0xFFB58D5E),
    PaperFinish.corrugated,
    .35,
    'Illustrative flutes, highlight and contact tone',
  ),
  (
    'Watercolor paper',
    Color(0xFFF2ECDF),
    PaperFinish.coldPress,
    .4,
    'Pitted tooth over the existing paper grain',
  ),
  (
    'Laid letter paper',
    Color(0xFFE7E7D5),
    PaperFinish.laid,
    .25,
    'Fine ribs and wider chain lines',
  ),
];

/// Six visual stock recipes; edge, finish and native printing remain separate.
class PaperStudiesSheet extends StatelessWidget {
  /// Creates deterministic paper plates without an animation clock.
  const PaperStudiesSheet({
    super.key,
    this.edge = PaperEdge.torn,
    this.depth = 3,
    this.seed = 23,
    this.strength = .7,
    this.scale = 1,
  });

  /// Independent silhouette treatment.
  final PaperEdge edge;

  /// Maximum inward edge intrusion.
  final double depth;

  /// Explicit geometry/texture/finish seed.
  final int seed;

  /// Finish strength, not the substrate opacity.
  final double strength;

  /// Finish mark scale.
  final double scale;
  @override
  Widget build(BuildContext context) => SpecimenRow(
    children: [
      for (var i = 0; i < _papers.length; i++)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: AspectRatio(
                  aspectRatio: 1.55,
                  child: _PaperPlate(
                    index: i,
                    edge: edge,
                    depth: depth,
                    seed: seed,
                    strength: strength,
                    scale: scale,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _papers[i].$1,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(_papers[i].$5, style: const TextStyle(fontFamily: 'Inter')),
          ],
        ),
    ],
  );
}

/// Side-by-side comparison of the same kraft recipe with four silhouettes.
class PaperEdgeStudiesSheet extends StatelessWidget {
  /// Creates the original edge specimens with fixed paper/finish inputs.
  const PaperEdgeStudiesSheet({super.key});
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, bounds) {
      final columns = bounds.maxWidth < 620 ? 1 : 2;
      final width = (bounds.maxWidth - 24 * (columns - 1)) / columns;
      return Wrap(
        spacing: 24,
        runSpacing: 24,
        children: [
          for (final edge in PaperEdge.values)
            SizedBox(
              width: width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 140,
                    child: _PaperPlate(
                      index: 1,
                      edge: edge,
                      depth: 4,
                      seed: 23,
                      strength: .7,
                      scale: 1,
                    ),
                  ),
                  Text(
                    switch (edge) {
                      PaperEdge.cut => 'Clean cut',
                      PaperEdge.torn => 'Torn with fibers',
                      PaperEdge.deckle => 'Handmade deckle',
                      PaperEdge.postage => 'Postage notches',
                    },
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    },
  );
}

class _PaperPlate extends StatefulWidget {
  const _PaperPlate({
    required this.index,
    required this.edge,
    required this.depth,
    required this.seed,
    required this.strength,
    required this.scale,
  });
  final int index, seed;
  final PaperEdge edge;
  final double depth, strength, scale;
  @override
  State<_PaperPlate> createState() => _PaperPlateState();
}

class _PaperPlateState extends State<_PaperPlate> {
  CraftOutline get _shape => CraftOutline.paper(
    edge: widget.edge,
    seed: widget.seed,
    edgeDepth: widget.depth,
    padding: 10,
  );
  late PreparedOutlineGeometry _geometry = PreparedOutlineGeometry(
    _shape.pathFor,
  );
  @override
  void didUpdateWidget(_PaperPlate old) {
    super.didUpdateWidget(old);
    if (widget.edge != old.edge ||
        widget.depth != old.depth ||
        widget.seed != old.seed) {
      _geometry = PreparedOutlineGeometry(_shape.pathFor);
    }
  }

  @override
  Widget build(BuildContext context) => CraftSurface(
    material: CraftMaterial.paper,
    color: _papers[widget.index].$2,
    strength: _papers[widget.index].$4,
    seed: widget.seed,
    outline: _geometry.pathFor,
    child: CustomPaint(
      foregroundPainter: _PaperDetails(
        _geometry,
        widget.index,
        widget.edge,
        widget.seed,
        widget.strength,
        widget.scale,
      ),
    ),
  );
}

class _PaperDetails extends CustomPainter {
  const _PaperDetails(
    this.geometry,
    this.index,
    this.edge,
    this.seed,
    this.strength,
    this.scale,
  );
  final PreparedOutlineGeometry geometry;
  final int index, seed;
  final PaperEdge edge;
  final double strength, scale;
  @override
  void paint(Canvas canvas, Size size) {
    final outline = geometry.pathFor(size);
    final finish = _papers[index].$3;
    if (finish != null) {
      paintPaperFinish(
        canvas,
        outline,
        finish: finish,
        ink: index == 4 ? const Color(0xFFB5AC9E) : const Color(0xFF65503D),
        highlight: const Color(0xFFFFF9EB),
        seed: seed,
        strength: index == 1 ? strength * .6 : strength,
        scale: scale,
      );
    }
    if (edge == PaperEdge.torn || edge == PaperEdge.deckle) {
      paintPaperEdgeFibers(
        canvas,
        outline,
        fiber: const Color(0xFFFFFCF4),
        seed: seed,
        strength: strength,
      );
    }
  }

  @override
  bool shouldRepaint(_PaperDetails old) =>
      geometry != old.geometry ||
      index != old.index ||
      edge != old.edge ||
      seed != old.seed ||
      strength != old.strength ||
      scale != old.scale;
}

// Native content owns the size. Only decoration is bounded; a long accessible
// paragraph must never be shrunk or rejected to fit a texture/outline budget.
class _LetterheadSurface extends StatelessWidget {
  const _LetterheadSurface({
    required this.shape,
    required this.seed,
    required this.showSeam,
    required this.child,
  });
  final CraftOutline shape;
  final int seed;
  final bool showSeam;
  final Widget child;
  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.passthrough,
    children: [
      Positioned.fill(
        child: ExcludeSemantics(
          child: IgnorePointer(
            child: LayoutBuilder(
              builder: (context, bounds) {
                if (bounds.maxWidth > 2048 || bounds.maxHeight > 2048) {
                  return const ColoredBox(
                    key: ValueKey('letterhead-plain-background'),
                    color: DemoPalette.paper,
                  );
                }
                return SeamedSurface(
                  shape: shape,
                  material: CraftMaterial.paper,
                  color: DemoPalette.paper,
                  seed: seed,
                  showSeam: showSeam,
                  child: const SizedBox.expand(),
                );
              },
            ),
          ),
        ),
      ),
      child,
    ],
  );
}

/// Native parameter controls plus letterhead composed with real text/actions.
class PaperPlayground extends StatefulWidget {
  /// Creates the synthetic paper inventory.
  const PaperPlayground({super.key});
  @override
  State<PaperPlayground> createState() => _PaperPlaygroundState();
}

class _PaperPlaygroundState extends State<PaperPlayground> {
  PaperEdge _edge = PaperEdge.torn;
  double _strength = .7, _scale = 1, _depth = 3;
  int _seed = 23, _actions = 0;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'A drawer full of paper',
        style: TextStyle(fontFamily: 'Caveat', fontSize: 44),
      ),
      const Text(
        'Stock recipes, cut edges, surface marks and native printing.',
      ),
      Wrap(
        spacing: 12,
        runSpacing: 8,
        children: [
          for (final edge in PaperEdge.values)
            ChoiceChip(
              label: Text(switch (edge) {
                PaperEdge.cut => 'Clean cut',
                PaperEdge.torn => 'Torn',
                PaperEdge.deckle => 'Handmade deckle',
                PaperEdge.postage => 'Postage',
              }),
              selected: edge == _edge,
              onSelected: (_) => setState(() => _edge = edge),
            ),
        ],
      ),
      Text('Finish strength ${(_strength * 100).round()}%'),
      Slider(
        key: const ValueKey('paper-strength'),
        value: _strength,
        onChanged: (v) => setState(() => _strength = v),
      ),
      Text('Finish scale ${_scale.toStringAsFixed(1)}'),
      Slider(
        key: const ValueKey('paper-scale'),
        value: _scale,
        min: .5,
        max: 2,
        onChanged: (v) => setState(() => _scale = v),
      ),
      Text('Edge depth ${_depth.toStringAsFixed(1)}'),
      Slider(
        key: const ValueKey('paper-depth'),
        value: _depth,
        min: 0,
        max: 4,
        onChanged: (v) => setState(() => _depth = v),
      ),
      TextButton(
        onPressed: () => setState(() => _seed++),
        child: const Text('Change paper seed'),
      ),
      PaperStudiesSheet(
        edge: _edge,
        depth: _depth,
        seed: _seed,
        strength: _strength,
        scale: _scale,
      ),
      const SizedBox(height: 28),
      const ExpansionTile(
        title: Text('Compare four edges'),
        children: [PaperEdgeStudiesSheet()],
      ),
      const SizedBox(height: 20),
      Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: _LetterheadSurface(
            shape: CraftOutline.paper(
              edge: _edge,
              edgeDepth: _depth,
              seed: _seed,
              padding: 3,
            ),
            seed: _seed,
            showSeam: MediaQuery.textScalerOf(context).scale(16) < 24,
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'FIELD NOTES',
                    style: TextStyle(fontFamily: 'Inter', letterSpacing: 2),
                  ),
                  const Divider(),
                  const Text(
                    'Letterhead is printing over paper.',
                    style: TextStyle(fontFamily: 'Caveat', fontSize: 32),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _actions++),
                    child: const Text('Use this paper'),
                  ),
                  Text('Selections $_actions'),
                ],
              ),
            ),
          ),
        ),
      ),
      const SizedBox(height: 20),
      const Text(
        'These are visual stock recipes, not physical thickness or optical transmission. '
        'Finishes add marks over the existing substrate. Letterhead keeps native text and controls.',
      ),
    ],
  );
}
