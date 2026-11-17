import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

import 'material_studies.dart';

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

/// Soft nursery tones for foam cuts; light enough that grain and edge light
/// carry the form instead of saturated color.
abstract final class _Pastel {
  static const blush = Color(0xFFF4C9C4);
  static const butter = Color(0xFFF9DFA0);
  static const mint = Color(0xFFC4E1CC);
  static const sage = Color(0xFFA9CBB4);
  static const sky = Color(0xFFC9DFF0);
  static const cloud = Color(0xFFFFFBF4);
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
    void layer(Path path, Color fill, [FoamFinish? pattern]) {
      canvas.drawShadow(path, const Color(0x26604A40), depth, false);
      textures.paint(canvas, path, material: CraftMaterial.eva, color: fill);
      paintFoamFinish(
        canvas,
        path,
        finish: pattern ?? finish,
        ink: const Color(0xFF8C766A),
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

    final c = r.center;
    final unit = r.shortestSide * .58;
    switch (finish) {
      case FoamFinish.pebbled:
        for (final angle in [-2.5, .62]) {
          layer(_leaf(c, unit * 1.08, angle, .34), _Pastel.mint);
        }
        for (var i = 0; i < 6; i++) {
          layer(_petal(c, unit * .72, i * math.pi / 3 + .2), _Pastel.blush);
        }
        layer(
          Path()..addOval(Rect.fromCircle(center: c, radius: unit * .25)),
          _Pastel.butter,
        );
      case FoamFinish.mottled:
        final stem = c + Offset(-unit * .05, unit * .78);
        layer(_leaf(stem, unit * 1.45, -1.95, .3), _Pastel.sage);
        layer(_leaf(stem, unit * 1.3, -1.05, .32), _Pastel.mint);
      case FoamFinish.grooved:
        final base = Offset(c.dx, r.bottom - unit * .12);
        for (final (outer, color) in [
          (unit * 1.12, _Pastel.blush),
          (unit * .88, _Pastel.butter),
          (unit * .64, _Pastel.mint),
        ]) {
          layer(_arch(base, outer, outer - unit * .25), color);
        }
        for (final side in [-1.0, 1.0]) {
          layer(
            _cloud(base + Offset(side * unit * .88, -unit * .04), unit * .3),
            _Pastel.cloud,
            FoamFinish.pebbled,
          );
        }
      case FoamFinish.crosshatched:
        layer(
          Path()..addOval(
            Rect.fromCircle(
              center: c + Offset(unit * .5, -unit * .38),
              radius: unit * .4,
            ),
          ),
          _Pastel.butter,
        );
        layer(
          _cloud(c + Offset(-unit * .1, unit * .18), unit * .78),
          _Pastel.sky,
        );
    }
  }

  static Path _petal(Offset center, double length, double angle) {
    final petal = Path()
      ..addOval(
        Rect.fromCenter(
          center: Offset(0, -length * .55),
          width: length * .62,
          height: length * 1.02,
        ),
      );
    return petal.transform(
      (Matrix4.translationValues(
        center.dx,
        center.dy,
        0,
      )..rotateZ(angle)).storage,
    );
  }

  static Path _leaf(Offset base, double length, double angle, double width) {
    final leaf = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(length * .45, -length * width, length, 0)
      ..quadraticBezierTo(length * .45, length * width, 0, 0)
      ..close();
    return leaf.transform(
      (Matrix4.translationValues(base.dx, base.dy, 0)..rotateZ(angle)).storage,
    );
  }

  static Path _arch(Offset base, double outer, double inner) => Path()
    ..moveTo(base.dx - outer, base.dy)
    ..arcTo(
      Rect.fromCircle(center: base, radius: outer),
      math.pi,
      math.pi,
      false,
    )
    ..lineTo(base.dx + inner, base.dy)
    ..arcTo(Rect.fromCircle(center: base, radius: inner), 0, -math.pi, false)
    ..close();

  static Path _cloud(Offset center, double size) {
    final cloud = Path();
    for (final (dx, dy, radius) in [
      (-.55, .12, .38),
      (-.12, -.18, .52),
      (.4, -.02, .42),
      (.72, .2, .3),
      (0.05, .22, .4),
    ]) {
      cloud.addOval(
        Rect.fromCircle(
          center: center + Offset(dx * size, dy * size),
          radius: radius * size,
        ),
      );
    }
    return Path.combine(PathOperation.union, cloud, Path());
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
      MergeSemantics(
        child: Semantics(
          label: 'Raised edge',
          child: Slider(
            key: const ValueKey('foam-depth'),
            value: depth,
            max: 8,
            semanticFormatterCallback: (v) =>
                '${v.toStringAsFixed(1)} logical pixels',
            onChanged: (v) => setState(() => depth = v),
          ),
        ),
      ),
      Text('Finish contrast ${(strength * 100).round()}%'),
      MergeSemantics(
        child: Semantics(
          label: 'Finish contrast',
          child: Slider(
            key: const ValueKey('foam-strength'),
            value: strength,
            semanticFormatterCallback: (v) => '${(v * 100).round()} percent',
            onChanged: (v) => setState(() => strength = v),
          ),
        ),
      ),
      FoamStudies(depth: depth, strength: strength),
      const SizedBox(height: 16),
      const Text(
        'Illustrative grain and beveled light, not simulated foam deformation. Text and controls stay native.',
      ),
    ],
  );
}
