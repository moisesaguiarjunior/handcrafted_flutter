import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

import 'relief_motifs.dart';
import 'showcase_theme.dart';

/// Parallel specimen layout shared by live pages and documentation captures.
class SpecimenRow extends StatelessWidget {
  /// Creates a responsive group of material specimens.
  const SpecimenRow({super.key, required this.children});

  /// Native widgets, each given a readable width instead of being scaled down.
  final List<Widget> children;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth < 620
          ? 1
          : constraints.maxWidth < 940
          ? 2
          : 3;
      final width = (constraints.maxWidth - (columns - 1) * 24) / columns;
      return Wrap(
        spacing: 24,
        runSpacing: 28,
        children: [
          for (final child in children) SizedBox(width: width, child: child),
        ],
      );
    },
  );
}

const _fabrics = [
  ('Indigo twill', CraftMaterial.twill, DemoPalette.indigo, 'Sea'),
  ('Flax linen', CraftMaterial.linen, Color(0xFFE2D2AE), 'Home'),
  ('Clay felt', CraftMaterial.felt, DemoPalette.rose, 'Slowly'),
];

/// Every material family shown as large swatches from one shared palette.
class MaterialsSheet extends StatelessWidget {
  /// Creates a texture collection with an explicit grain seed.
  const MaterialsSheet({super.key, this.seed = 23});

  /// Seed used by each independently owned specimen cache.
  final int seed;
  @override
  Widget build(BuildContext context) => SpecimenRow(
    children: [
      for (final sample in [
        ..._fabrics.map((f) => (f.$1, f.$2, f.$3)),
        ('Drawing paper', CraftMaterial.paper, const Color(0xFFF3EBDC)),
        ('Honey wood', CraftMaterial.wood, DemoPalette.wood),
        ('Cognac leather', CraftMaterial.leather, DemoPalette.cognac),
        ('Ochre EVA foam', CraftMaterial.eva, DemoPalette.ochre),
        ('Sage cotton', CraftMaterial.cotton, DemoPalette.sage),
        ('Terracotta nap', CraftMaterial.suede, DemoPalette.terracotta),
      ])
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.45,
              child: _Artwork(
                plate: _Plate.swatch,
                material: sample.$2,
                color: sample.$3,
                seed: seed,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              sample.$1,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(switch (sample.$2) {
              CraftMaterial.linen => 'Crossed threads and irregular slubs',
              CraftMaterial.twill => 'Diagonal ribs and small fiber breaks',
              CraftMaterial.felt => 'Dense, short, matted fibers',
              CraftMaterial.paper => 'Fine paired creases',
              CraftMaterial.wood => 'Long, wavy grain',
              CraftMaterial.eva => 'Fine closed-cell pores',
              CraftMaterial.cotton => 'Compact plain weave',
              CraftMaterial.suede => 'Soft, short nap',
              CraftMaterial.leather => 'Pebbled grain and fine creases',
            }),
          ],
        ),
    ],
  );
}

/// Original botanical motifs impressed into three different fabric specimens.
class ImpressionsSheet extends StatelessWidget {
  /// Creates raised or inset specimens with reversible directional lighting.
  const ImpressionsSheet({
    super.key,
    this.raised = false,
    this.reverseLight = false,
    this.seed = 23,
  });

  /// Whether rims appear raised instead of pressed inward.
  final bool raised;

  /// Reverses the supplied light direction without changing the motif.
  final bool reverseLight;

  /// Material grain seed.
  final int seed;
  @override
  Widget build(BuildContext context) => SpecimenRow(
    children: [
      for (var i = 0; i < _fabrics.length; i++) _impression(context, i),
    ],
  );
  Widget _impression(BuildContext context, int index) {
    final sample = _fabrics[index];
    final inside = MediaQuery.textScalerOf(context).scale(26) < 39;
    final kind = raised ? CraftReliefKind.raised : CraftReliefKind.inset;
    Widget lettering(Color ink) => CraftReliefText(
      sample.$4,
      kind: kind,
      depth: 1.4,
      light: reverseLight ? const Offset(1, 1) : const Offset(-1, -1),
      textAlign: TextAlign.center,
      style: TextStyle(fontFamily: 'Caveat', fontSize: 32, color: ink),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AspectRatio(
          aspectRatio: 1.1,
          child: Stack(
            children: [
              Positioned.fill(
                child: _Artwork(
                  plate: _Plate.impression,
                  material: sample.$2,
                  color: sample.$3,
                  seed: seed,
                  variant: index,
                  raised: raised,
                  reverseLight: reverseLight,
                ),
              ),
              if (inside)
                Positioned(
                  left: 24,
                  right: 24,
                  bottom: 46,
                  child: lettering(
                    index == 0
                        ? const Color(0xFFD8E5E9)
                        : const Color(0xFF554139),
                  ),
                ),
            ],
          ),
        ),
        if (!inside) lettering(DemoPalette.ink),
        Text(sample.$1, style: const TextStyle(fontWeight: FontWeight.w600)),
        Text(
          raised
              ? 'Raised motif, fabric grain retained'
              : 'Pressed motif, fabric grain retained',
        ),
      ],
    );
  }
}

/// Distinct pigment compositions over the same procedural paper substrate.
class WatercolorsSheet extends StatelessWidget {
  /// Creates explicit-palette washes, a botanical painting and a resist study.
  const WatercolorsSheet({
    super.key,
    this.seed = 23,
    this.opacity = .7,
    this.granulation = .8,
  });

  /// Fixed pigment and paper seed.
  final int seed;

  /// Pigment opacity, 0..1.
  final double opacity;

  /// Deposit/pore strength, 0..1.
  final double granulation;
  @override
  Widget build(BuildContext context) => SpecimenRow(
    children: [
      for (var i = 0; i < 3; i++)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.1,
              child: _Artwork(
                plate: _Plate.watercolor,
                material: CraftMaterial.paper,
                color: const Color(0xFFFFFCF5),
                seed: seed,
                variant: i,
                opacity: opacity,
                granulation: granulation,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              [
                'Overlapping washes',
                'A botanical painting',
                'Paper left untouched',
              ][i],
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Text(
              [
                'Puddles, blooms and drying lines',
                'Petals and leaves share one pigment painter',
                'A hole in the supplied silhouette stays clear',
              ][i],
            ),
          ],
        ),
    ],
  );
}

enum _Plate { swatch, impression, watercolor }

class _Artwork extends StatefulWidget {
  const _Artwork({
    required this.plate,
    required this.material,
    required this.color,
    required this.seed,
    this.variant = 0,
    this.raised = false,
    this.reverseLight = false,
    this.opacity = .7,
    this.granulation = .8,
  });
  final _Plate plate;
  final CraftMaterial material;
  final Color color;
  final int seed, variant;
  final bool raised, reverseLight;
  final double opacity, granulation;
  @override
  State<_Artwork> createState() => _ArtworkState();
}

class _ArtworkState extends State<_Artwork> {
  late MaterialTextures textures = MaterialTextures(seed: widget.seed);
  @override
  void didUpdateWidget(_Artwork old) {
    super.didUpdateWidget(old);
    if (old.seed != widget.seed) {
      textures.dispose();
      textures = MaterialTextures(seed: widget.seed);
    }
  }

  @override
  void dispose() {
    textures.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: CustomPaint(painter: _SpecimenPainter(textures, widget)),
  );
}

class _SpecimenPainter extends CustomPainter {
  _SpecimenPainter(this.textures, this.sample);
  final MaterialTextures textures;
  final _Artwork sample;
  @override
  void paint(Canvas canvas, Size size) {
    final bounds = (Offset.zero & size).deflate(16);
    if (bounds.isEmpty) return;
    switch (sample.plate) {
      case _Plate.swatch:
        final r = bounds.deflate(4);
        final shape = switch (sample.material) {
          CraftMaterial.twill =>
            Path()..addOval(
              Rect.fromCenter(
                center: r.center,
                width: r.width * .9,
                height: r.height,
              ),
            ),
          CraftMaterial.linen =>
            Path()
              ..moveTo(r.left + 12, r.top)
              ..lineTo(r.right, r.top + 14)
              ..lineTo(r.right - 14, r.bottom)
              ..lineTo(r.left, r.bottom - 12)
              ..close(),
          CraftMaterial.felt =>
            Path()
              ..moveTo(r.center.dx, r.top)
              ..lineTo(r.right, r.center.dy - 10)
              ..lineTo(r.right - 24, r.bottom)
              ..lineTo(r.left + 22, r.bottom)
              ..lineTo(r.left, r.center.dy - 10)
              ..close(),
          CraftMaterial.paper => paperOutline(
            r,
            edge: PaperEdge.torn,
            depth: 4,
            pitch: 22,
            seed: sample.seed,
          ),
          CraftMaterial.eva ||
          CraftMaterial.cotton ||
          CraftMaterial.suede ||
          CraftMaterial.leather => pigmentOutline(r, seed: sample.seed),
          CraftMaterial.wood =>
            Path()
              ..addRRect(RRect.fromRectAndRadius(r, const Radius.circular(26))),
        };
        canvas.drawShadow(shape, const Color(0x44000000), 3, false);
        textures.paint(
          canvas,
          shape,
          material: sample.material,
          color: sample.color,
          scale: 1.4,
        );
      case _Plate.impression:
        final center = bounds.center;
        final radius = math.min(bounds.width, bounds.height) * .46;
        final disc = Path()
          ..addOval(Rect.fromCircle(center: center, radius: radius));
        canvas.drawShadow(disc, const Color(0x44000000), 3, false);
        textures.paint(
          canvas,
          disc,
          material: sample.material,
          color: sample.color,
          scale: 1.25,
        );
        final hoop = Path()
          ..fillType = PathFillType.evenOdd
          ..addOval(Rect.fromCircle(center: center, radius: radius + 6))
          ..addOval(Rect.fromCircle(center: center, radius: radius - 1));
        textures.paint(
          canvas,
          hoop,
          material: CraftMaterial.wood,
          color: const Color(0xFFBE9A6E),
        );
        paintCraftRelief(
          canvas,
          hoop,
          kind: CraftReliefKind.raised,
          depth: 1.2,
        );
        // A circle's concentric seam is an exact inset, with room for punctures.
        final seam = Path()
          ..addOval(Rect.fromCircle(center: center, radius: radius - 12));
        paintRunningStitch(
          canvas,
          seam,
          thread: const Color(0xFFECE2CA),
          dash: 4.5,
          gap: 3.5,
          width: 1.1,
          compression: .65,
        );
        final motifBounds = Rect.fromCenter(
          center: center - Offset(0, radius * .16),
          width: radius * 1.3,
          height: radius * 1.2,
        );
        paintReliefMotif(
          canvas,
          const [
            ReliefMotif.whale,
            ReliefMotif.house,
            ReliefMotif.snail,
          ][sample.variant % 3],
          motifBounds,
          strength: .95,
          kind: sample.raised ? CraftReliefKind.raised : CraftReliefKind.inset,
          light: sample.reverseLight
              ? const Offset(1, 1)
              : const Offset(-1, -1),
        );
      case _Plate.watercolor:
        final paper = Path()..addRect(Offset.zero & size);
        textures.paint(
          canvas,
          paper,
          material: CraftMaterial.paper,
          color: sample.color,
        );
        _paintWatercolor(canvas, bounds);
    }
  }

  void _paintWatercolor(Canvas canvas, Rect bounds) {
    const blue = Color(0xFF648FA9),
        green = Color(0xFF6A9577),
        rose = Color(0xFFB06B88),
        ochre = Color(0xFFCEA956);
    void wash(Path shape, Color pigment, Color companion, int seed) =>
        paintWatercolor(
          canvas,
          shape,
          pigment: pigment,
          companion: companion,
          paper: sample.color,
          seed: seed,
          opacity: sample.opacity,
          granulation: sample.granulation,
        );
    if (sample.variant == 0) {
      final samples = [
        (Alignment(-.4, -.35), blue, green),
        (Alignment(.4, .1), rose, ochre),
        (Alignment(-.1, .55), ochre, green),
      ];
      for (var i = 0; i < samples.length; i++) {
        final data = samples[i];
        final center =
            bounds.center +
            Offset(
              data.$1.x * bounds.width * .3,
              data.$1.y * bounds.height * .3,
            );
        wash(
          pigmentOutline(
            Rect.fromCenter(
              center: center,
              width: bounds.width * .68,
              height: bounds.height * .55,
            ),
            seed: sample.seed + i * 11,
          ),
          data.$2,
          data.$3,
          sample.seed + i * 17,
        );
      }
    } else if (sample.variant == 1) {
      final center = bounds.center - Offset(0, bounds.height * .14);
      final radius = bounds.shortestSide * .2;
      final stem = craftCurveThrough([
        center,
        center + Offset(8, radius * 2.8),
      ]);
      paintCraftStroke(
        canvas,
        stem,
        color: green.withValues(alpha: sample.opacity),
        style: const CraftStrokeStyle(tool: CraftStrokeTool.brush, width: 3),
      );
      for (var i = 0; i < 5; i++) {
        final angle = i * math.pi * 2 / 5;
        final petalCenter =
            center + Offset(math.cos(angle), math.sin(angle)) * radius * .65;
        final petal = Path()
          ..addOval(
            Rect.fromCenter(
              center: petalCenter,
              width: radius * 1.35,
              height: radius * 1.2,
            ),
          );
        wash(petal, i.isEven ? rose : ochre, rose, sample.seed + i);
      }
      wash(
        Path()..addOval(Rect.fromCircle(center: center, radius: radius * .32)),
        ochre,
        green,
        sample.seed + 10,
      );
      wash(
        _botanical(
          Rect.fromLTWH(
            center.dx - radius * .65,
            center.dy + radius,
            radius * 1.4,
            radius * 1.8,
          ),
          0,
        ),
        green,
        blue,
        sample.seed + 20,
      );
    } else {
      final shape =
          pigmentOutline(bounds.deflate(12), seed: sample.seed, broad: true)
            ..fillType = PathFillType.evenOdd
            ..addOval(
              Rect.fromCenter(
                center: bounds.center,
                width: bounds.width * .25,
                height: bounds.height * .43,
              ),
            );
      wash(shape, blue, green, sample.seed);
    }
  }

  @override
  bool shouldRepaint(_SpecimenPainter old) =>
      old.textures != textures ||
      old.sample.plate != sample.plate ||
      old.sample.material != sample.material ||
      old.sample.color != sample.color ||
      old.sample.variant != sample.variant ||
      old.sample.raised != sample.raised ||
      old.sample.reverseLight != sample.reverseLight ||
      old.sample.opacity != sample.opacity ||
      old.sample.granulation != sample.granulation;
}

Path _botanical(Rect r, int variant) {
  final path = Path();
  if (variant == 1) {
    final center = r.center;
    for (var i = 0; i < 6; i++) {
      final a = i * math.pi / 3;
      path.addOval(
        Rect.fromCircle(
          center: center + Offset(math.cos(a), math.sin(a)) * r.width * .22,
          radius: r.width * .14,
        ),
      );
    }
    path.addOval(Rect.fromCircle(center: center, radius: r.width * .13));
    return path;
  }
  path.addRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(
        r.center.dx - 1.4,
        r.top + r.height * .12,
        2.8,
        r.height * .85,
      ),
      const Radius.circular(1.4),
    ),
  );
  for (var i = 0; i < 4; i++) {
    final y = r.top + r.height * (.2 + i * .18);
    final direction = i.isEven ? -1 : 1;
    final width = r.width * (variant == 2 ? .32 : .46);
    path.moveTo(r.center.dx, y + r.height * .19);
    path.cubicTo(
      r.center.dx + width * direction,
      y + r.height * .22,
      r.center.dx + width * direction,
      y - r.height * .03,
      r.center.dx + width * direction,
      y - r.height * .03,
    );
    path.cubicTo(
      r.center.dx + width * direction * .15,
      y,
      r.center.dx,
      y + r.height * .08,
      r.center.dx,
      y + r.height * .19,
    );
    path.close();
  }
  return path;
}
