import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

import 'showcase_theme.dart';

/// Example-only point lamp, sampled at each piece center in a 640x360 board.
/// This is a bounded approximation over the package's directional shader.
@immutable
class StudioLamp {
  /// Board coordinates and height above the board, all in artboard units.
  const StudioLamp({this.position = const Offset(210, 95), this.height = 220});

  /// Position in the scene plane.
  final Offset position;

  /// Positive height above the scene plane.
  final double height;

  /// Distance changes intensity, rather than just scaling a normalized vector.
  CraftLight sample(Offset center, double rotation) {
    const scale = 320.0;
    final delta = (position - center) / scale;
    final z = height / scale;
    final distance = delta.distanceSquared + z * z;
    return CraftLight(
      x: delta.dx,
      y: delta.dy,
      z: z,
      ambient: .64,
      direct: .85 / (1 + distance),
      softness: .28,
      warmth: .3,
    ).inLocalSpace(rotation);
  }
}

/// Prepared original shapes and profiles; relighting never rebuilds geometry.
class StudioCuts {
  /// Prepares two silhouettes for each of the three substrates.
  StudioCuts() {
    final petal = Path()
      ..moveTo(-61, 38)
      ..cubicTo(-108, -6, -39, -72, 0, -47)
      ..cubicTo(42, -75, 107, -9, 61, 38)
      ..quadraticBezierTo(0, 65, -61, 38)
      ..close();
    final scallop = Path();
    for (var i = 0; i <= 120; i++) {
      final a = i / 120 * math.pi * 2;
      final r = 61 + 8 * math.cos(a * 5);
      final p = Offset(math.cos(a) * r, math.sin(a) * r);
      if (i == 0) {
        scallop.moveTo(p.dx, p.dy);
      } else {
        scallop.lineTo(p.dx, p.dy);
      }
    }
    scallop.close();
    cuts = [petal, scallop];
    models = [
      for (var material = 0; material < 3; material++)
        [
          for (final cut in cuts)
            CraftVolume(
              cut,
              material == 0
                  ? CraftVolumeProfile.rounded
                  : CraftVolumeProfile.sheet,
              height: [13.0, 3.5, 1.0][material],
              bevel: [19.0, 5.0, 2.0][material],
            ),
        ],
    ];
  }

  /// Original copied silhouettes.
  late final List<Path> cuts;

  /// Material-specific prepared profiles, indexed by substrate then shape.
  late final List<List<CraftVolume>> models;
}

/// Fixed scene-space centers, independent of piece rotation.
const studioCenters = [Offset(130, 220), Offset(320, 220), Offset(510, 220)];

/// Native control labels in the same order as the pieces.
const studioNames = ['Clay', 'EVA', 'Paper'];

/// A single interactive scene using public material and volume primitives.
class SpatialLightStudy extends StatefulWidget {
  /// Owns only example controls and seeded texture resources.
  const SpatialLightStudy({super.key, this.previewOnly = false});

  /// Shows the same introductory artwork without the interactive controls.
  final bool previewOnly;
  @override
  State<SpatialLightStudy> createState() => _SpatialLightStudyState();
}

class _SpatialLightStudyState extends State<SpatialLightStudy> {
  final textures = MaterialTextures(seed: 71);
  final cuts = StudioCuts();
  StudioLamp lamp = const StudioLamp();
  final shapes = [0, 0, 0];
  final rotations = [-.15, .12, -.12];
  int selected = 0;

  @override
  void dispose() {
    textures.dispose();
    super.dispose();
  }

  void moveLamp(Offset position) => setState(() {
    lamp = StudioLamp(
      position: Offset(position.dx.clamp(24, 616), position.dy.clamp(24, 336)),
      height: lamp.height,
    );
  });

  Widget control(
    String label,
    String id,
    double value,
    double min,
    double max,
    ValueChanged<double> update, {
    String? display,
  }) => MergeSemantics(
    child: Semantics(
      label: label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ${display ?? value.round()}'),
          Slider(
            key: ValueKey(id),
            value: value,
            min: min,
            max: max,
            semanticFormatterCallback: (v) => v.round().toString(),
            onChanged: update,
          ),
        ],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'A little light changes everything.',
        style: TextStyle(fontFamily: 'Caveat', fontSize: 40),
      ),
      const Text(
        'Drag the lamp across clay, EVA and paper. Lower it to bring the light closer; lift it for a gentler pool of light.',
      ),
      const SizedBox(height: 16),
      LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth.clamp(0.0, 900.0);
          final scale = width / 640;
          if (width < 48 || width * 360 / 640 < 48) {
            return const SizedBox.shrink();
          }
          return SizedBox(
            width: width,
            height: width * 360 / 640,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: ExcludeSemantics(
                    child: CustomPaint(
                      key: const ValueKey('studio-board'),
                      painter: StudioPainter(
                        textures: textures,
                        cuts: cuts,
                        lamp: lamp,
                        shapes: List.of(shapes),
                        rotations: List.of(rotations),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: (lamp.position.dx * scale - 24).clamp(0.0, width - 48),
                  top: (lamp.position.dy * scale - 24).clamp(
                    0.0,
                    width * 360 / 640 - 48,
                  ),
                  child: Tooltip(
                    message: 'Drag the lamp; sliders also control its position',
                    child: GestureDetector(
                      key: const ValueKey('studio-lamp'),
                      behavior: HitTestBehavior.opaque,
                      dragStartBehavior: DragStartBehavior.down,
                      onPanUpdate: (details) {
                        moveLamp(lamp.position + details.delta / scale);
                      },
                      child: const SizedBox(width: 48, height: 48),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      const SizedBox(height: 12),
      if (!widget.previewOnly) ...[
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < 3; i++)
              ChoiceChip(
                key: ValueKey('studio-piece-$i'),
                label: Text(studioNames[i]),
                selected: selected == i,
                onSelected: (_) => setState(() => selected = i),
              ),
            OutlinedButton(
              key: const ValueKey('studio-shape'),
              onPressed: () =>
                  setState(() => shapes[selected] = 1 - shapes[selected]),
              child: Text(
                'Change ${studioNames[selected].toLowerCase()} shape',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        control(
          'Lamp left / right',
          'studio-x',
          lamp.position.dx,
          24,
          616,
          (v) => moveLamp(Offset(v, lamp.position.dy)),
        ),
        control(
          'Lamp front / back',
          'studio-y',
          lamp.position.dy,
          24,
          336,
          (v) => moveLamp(Offset(lamp.position.dx, v)),
        ),
        control(
          'Height above the pieces',
          'studio-height',
          lamp.height,
          80,
          480,
          (v) => setState(
            () => lamp = StudioLamp(position: lamp.position, height: v),
          ),
          display: '${lamp.height.round()} — lower is closer',
        ),
        control(
          '${studioNames[selected]} rotation',
          'studio-rotation',
          rotations[selected] * 180 / math.pi,
          -90,
          90,
          (v) => setState(() => rotations[selected] = v * math.pi / 180),
          display: '${(rotations[selected] * 180 / math.pi).round()}°',
        ),
        TextButton(
          onPressed: () => setState(() {
            lamp = const StudioLamp();
            selected = 0;
            shapes.setAll(0, [0, 0, 0]);
            rotations.setAll(0, [-.15, .12, -.12]);
          }),
          child: const Text('Reset the scene'),
        ),
        const Text(
          'The lamp stays put when a piece turns. Light is sampled at each piece’s center; this is an illustrative volume recipe, without per-pixel point lighting or mutual shadows. Clay is a rounded profile, not a separate simulated material.',
        ),
      ],
    ],
  );
}

/// Shared painter used unchanged by live, raster and device checks.
class StudioPainter extends CustomPainter {
  /// Paints the exact scene used by the gallery and captures.
  StudioPainter({
    required this.textures,
    required this.cuts,
    required this.lamp,
    required this.shapes,
    required this.rotations,
  });

  /// Caller-owned material tiles.
  final MaterialTextures textures;

  /// Reusable prepared geometry.
  final StudioCuts cuts;

  /// Shared world-space lamp.
  final StudioLamp lamp;

  /// Per-piece silhouette indices.
  final List<int> shapes;

  /// Per-piece planar rotations in radians.
  final List<double> rotations;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    try {
      canvas.scale(size.width / 640, size.height / 360);
      final board = Path()
        ..addRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(0, 0, 640, 360),
            const Radius.circular(22),
          ),
        );
      canvas.clipPath(board);
      textures.paint(
        canvas,
        board,
        material: CraftMaterial.paper,
        color: DemoPalette.paper,
        strength: .3,
      );
      canvas.drawCircle(
        lamp.position,
        150,
        Paint()
          ..shader = RadialGradient(
            colors: [const Color(0x32FFE8A0), const Color(0x00FFE8A0)],
          ).createShader(Rect.fromCircle(center: lamp.position, radius: 150)),
      );
      for (var i = 0; i < 3; i++) {
        canvas.save();
        try {
          final center = studioCenters[i];
          canvas.translate(center.dx, center.dy);
          canvas.rotate(rotations[i]);
          final model = cuts.models[i][shapes[i]];
          final light = lamp.sample(center, rotations[i]);
          model.shadow(canvas, light);
          textures.paint(
            canvas,
            model.outline,
            material: i == 2 ? CraftMaterial.paper : CraftMaterial.eva,
            color: [DemoPalette.rose, DemoPalette.sage, DemoPalette.cream][i],
            strength: [.055, .36, .55][i],
          );
          model.shade(canvas, light);
        } finally {
          canvas.restore();
        }
        final label = TextPainter(
          text: TextSpan(
            text: studioNames[i],
            style: const TextStyle(
              fontFamily: 'Caveat',
              fontSize: 25,
              color: DemoPalette.ink,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        label.paint(canvas, Offset(studioCenters[i].dx - label.width / 2, 303));
        label.dispose();
      }
      // Keep the visible source at its true scene coordinate. Only the invisible
      // 48px hit target is clamped to fit the viewport near an edge.
      canvas.drawCircle(
        lamp.position,
        16,
        Paint()..color = const Color(0xFFFFD66D),
      );
      final sunInk = Paint()
        ..color = DemoPalette.ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(lamp.position, 4, sunInk);
      for (var i = 0; i < 8; i++) {
        final a = i * math.pi / 4;
        final direction = Offset(math.cos(a), math.sin(a));
        canvas.drawLine(
          lamp.position + direction * 8,
          lamp.position + direction * 11,
          sunInk,
        );
      }
    } finally {
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(StudioPainter old) =>
      old.textures != textures ||
      old.cuts != cuts ||
      old.lamp != lamp ||
      !listEquals(old.shapes, shapes) ||
      !listEquals(old.rotations, rotations);
}
