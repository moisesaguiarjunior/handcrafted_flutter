import 'package:flutter/material.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

import 'material_studies.dart';
import 'showcase_theme.dart';

/// Original generic foam specimens; no application artwork is imported.
class FoamStudies extends StatelessWidget {
  /// Composes independently seeded finish, grain and raised edge.
  const FoamStudies({super.key, this.depth = 4, this.strength = .6});

  /// Existing relief depth in logical pixels, 0..8.
  final double depth;

  /// Finish contrast, 0..1.
  final double strength;

  @override
  Widget build(BuildContext context) => SpecimenRow(
    children: [
      for (final finish in FoamFinish.values)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.4,
              child: _FoamSample(finish, depth, strength),
            ),
            Text(switch (finish) {
              FoamFinish.pebbled => 'Pebbled foam',
              FoamFinish.mottled => 'Mottled foam',
              FoamFinish.grooved => 'Pressed grooves',
              FoamFinish.crosshatched => 'Crossed impressions',
            }, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
    ],
  );
}

class _FoamSample extends StatefulWidget {
  const _FoamSample(this.finish, this.depth, this.strength);
  final FoamFinish finish;
  final double depth, strength;
  @override
  State<_FoamSample> createState() => _FoamSampleState();
}

class _FoamSampleState extends State<_FoamSample> {
  final textures = MaterialTextures(seed: 71);
  @override
  void dispose() {
    textures.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: IgnorePointer(
      child: CustomPaint(
        painter: _FoamPainter(
          textures,
          widget.finish,
          widget.depth,
          widget.strength,
        ),
      ),
    ),
  );
}

class _FoamPainter extends CustomPainter {
  const _FoamPainter(this.textures, this.finish, this.depth, this.strength);
  final MaterialTextures textures;
  final FoamFinish finish;
  final double depth, strength;
  @override
  void paint(Canvas canvas, Size size) {
    final r = (Offset.zero & size).deflate(18);
    if (r.isEmpty) return;
    final color = switch (finish) {
      FoamFinish.pebbled => DemoPalette.rose,
      FoamFinish.mottled => DemoPalette.sage,
      FoamFinish.grooved => DemoPalette.wood,
      FoamFinish.crosshatched => const Color(0xFFB7D3E4),
    };
    final outline = switch (finish) {
      FoamFinish.pebbled => pigmentOutline(r, seed: 41),
      FoamFinish.mottled =>
        Path()
          ..moveTo(r.left, r.bottom)
          ..cubicTo(r.left, r.top, r.right, r.top, r.right, r.top)
          ..cubicTo(r.right, r.bottom, r.center.dx, r.bottom, r.left, r.bottom)
          ..close(),
      FoamFinish.grooved =>
        Path()..addRRect(
          RRect.fromRectAndRadius(r.deflate(9), const Radius.circular(17)),
        ),
      FoamFinish.crosshatched =>
        Path()
          ..addOval(
            Rect.fromLTWH(
              r.left,
              r.top + r.height * .3,
              r.width * .52,
              r.height * .65,
            ),
          )
          ..addOval(
            Rect.fromLTWH(
              r.left + r.width * .25,
              r.top,
              r.width * .5,
              r.height,
            ),
          )
          ..addOval(
            Rect.fromLTWH(
              r.left + r.width * .53,
              r.top + r.height * .3,
              r.width * .47,
              r.height * .65,
            ),
          ),
    };
    void layer(Path path, Color fill, FoamFinish pattern) {
      canvas.drawShadow(path, const Color(0x33000000), depth, false);
      textures.paint(canvas, path, material: CraftMaterial.eva, color: fill);
      paintFoamFinish(
        canvas,
        path,
        finish: pattern,
        ink: const Color(0xFF584437),
        seed: 71,
        strength: strength,
      );
      paintCraftRelief(
        canvas,
        path,
        kind: CraftReliefKind.raised,
        depth: depth,
      );
    }

    layer(outline, color, finish);
    if (finish == FoamFinish.pebbled) {
      final inner = Path()
        ..addOval(
          Rect.fromCenter(
            center: r.center,
            width: r.width * .4,
            height: r.height * .4,
          ),
        );
      layer(inner, const Color(0xFFFFDCA2), FoamFinish.crosshatched);
    }
  }

  @override
  bool shouldRepaint(_FoamPainter old) =>
      old.textures != textures ||
      old.finish != finish ||
      old.depth != depth ||
      old.strength != strength;
}

/// Native controls for finishing and raised-layer examples.
class FoamPlayground extends StatefulWidget {
  /// Creates the foam study.
  const FoamPlayground({super.key});
  @override
  State<FoamPlayground> createState() => _FoamPlaygroundState();
}

class _FoamPlaygroundState extends State<FoamPlayground> {
  double depth = 4, strength = .6;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'One foam. Different impressions.',
        style: TextStyle(fontFamily: 'Caveat', fontSize: 38),
      ),
      const Text(
        'Fine pores, rough cells, color islands and pressed grooves. Stack cuts with their own finish and edge light.',
      ),
      Text('Raised edge ${depth.round()} px'),
      Slider(
        key: const ValueKey('foam-depth'),
        value: depth,
        max: 8,
        onChanged: (v) => setState(() => depth = v),
      ),
      Text('Finish contrast ${(strength * 100).round()}%'),
      Slider(
        key: const ValueKey('foam-strength'),
        value: strength,
        onChanged: (v) => setState(() => strength = v),
      ),
      FoamStudies(depth: depth, strength: strength),
      const SizedBox(height: 16),
      const Text(
        'Illustrative grain and beveled light, not simulated foam deformation. Text and controls stay native.',
      ),
    ],
  );
}
