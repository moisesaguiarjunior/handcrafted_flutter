import 'package:flutter/material.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

import 'local_volume.dart';
import 'material_studies.dart';
import 'mixed_volume_study.dart';

const _coral = Color(0xFFEFA07C);

/// Controlled shape/color/light comparison of existing and experimental relief.
class VolumeStudies extends StatefulWidget {
  /// Small-screen strips keep all three treatments visible together.
  const VolumeStudies({super.key, this.light, this.compact = false});

  /// Explicit host-controlled light; null chooses the fixed capture condition.
  final VolumeLight? light;

  /// A single row suitable for a 320/390px screen comparison.
  final bool compact;
  @override
  State<VolumeStudies> createState() => _VolumeStudiesState();
}

class _VolumeStudiesState extends State<VolumeStudies> {
  final textures = MaterialTextures(seed: 71);
  late final models = _VolumeModels();
  @override
  void dispose() {
    textures.dispose();
    super.dispose();
  }

  Widget _specimen(int mode) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      AspectRatio(
        aspectRatio: widget.compact ? 300 / 160 : 300 / 430,
        child: ExcludeSemantics(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _VolumePainter(
                textures,
                models,
                mode,
                widget.light ?? VolumeLight(),
                widget.compact,
              ),
            ),
          ),
        ),
      ),
      const SizedBox(height: 8),
      Text(
        ['Current relief', 'Foam profile', 'Rounded profile'][mode],
        style: Theme.of(context).textTheme.titleMedium,
      ),
      if (!widget.compact)
        Text(
          [
            'Directional rims, the current package painter.',
            '3px sheet, 4px bevel, a flat matte face.',
            '10px rounded height, 16px roll and pressure marks.',
          ][mode],
        ),
    ],
  );
  @override
  Widget build(BuildContext context) => widget.compact
      ? Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < 3; i++)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: _specimen(i),
                ),
              ),
          ],
        )
      : SpecimenRow(children: [for (var i = 0; i < 3; i++) _specimen(i)]);
}

class _VolumeModels {
  _VolumeModels() {
    final cloud = Path.combine(
      PathOperation.union,
      Path()..addRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(45, 65, 210, 56),
          const Radius.circular(26),
        ),
      ),
      Path()
        ..addOval(const Rect.fromLTWH(72, 35, 86, 86))
        ..addOval(const Rect.fromLTWH(132, 23, 92, 98)),
    );
    final corner = Path()
      ..fillType = PathFillType.evenOdd
      ..moveTo(47, 166)
      ..quadraticBezierTo(140, 146, 245, 168)
      ..lineTo(230, 253)
      ..quadraticBezierTo(145, 270, 52, 250)
      ..lineTo(105, 217)
      ..lineTo(49, 199)
      ..close()
      ..addOval(const Rect.fromLTWH(177, 188, 26, 26));
    Path tile(double y) => Path()
      ..moveTo(57, y)
      ..quadraticBezierTo(146, y - 13, 242, y)
      ..lineTo(242, y + 40)
      ..quadraticBezierTo(196, y + 80, 148, y + 44)
      ..quadraticBezierTo(102, y + 80, 57, y + 40)
      ..close();
    cuts = [cloud, corner, tile(344), tile(306)];
    sheet = [for (final p in cuts) PreparedVolume(p, VolumeProfile.sheet)];
    rounded = [for (final p in cuts) PreparedVolume(p, VolumeProfile.rounded)];
  }
  late final List<Path> cuts;
  late final List<PreparedVolume> sheet, rounded;
}

class _VolumePainter extends CustomPainter {
  const _VolumePainter(
    this.textures,
    this.models,
    this.mode,
    this.light,
    this.compact,
  );
  final MaterialTextures textures;
  final _VolumeModels models;
  final int mode;
  final VolumeLight light;
  final bool compact;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    if (compact) {
      canvas.scale(size.width / 300, size.height / 160);
    } else {
      canvas.scale(size.width / 300, size.height / 430);
    }
    final board = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, 300, compact ? 160 : 430),
          const Radius.circular(15),
        ),
      );
    textures.paint(
      canvas,
      board,
      material: CraftMaterial.paper,
      color: const Color(0xFFFFFAF2),
      strength: .3,
    );
    final field = mode == 1 ? models.sheet : models.rounded;
    final count = compact ? 1 : models.cuts.length;
    for (var i = 0; i < count; i++) {
      final shape = models.cuts[i];
      if (mode != 0) {
        field[i].shadow(
          canvas,
          light,
          receiver: i == 3 ? models.cuts[2] : board,
          lift: i == 3 ? 3 : 0,
        );
      }
      textures.paint(
        canvas,
        shape,
        material: CraftMaterial.eva,
        color: _coral,
        strength: .3,
      );
      if (mode == 0) {
        paintCraftRelief(
          canvas,
          shape,
          kind: CraftReliefKind.raised,
          depth: 3,
          strength: .65,
          light: light.planar,
        );
      } else {
        field[i].shade(canvas, light);
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_VolumePainter old) =>
      old.textures != textures ||
      old.models != models ||
      old.mode != mode ||
      old.light != light ||
      old.compact != compact;
}

/// Native controls around prepared local volume; no clock is created.
class LocalVolumePlayground extends StatefulWidget {
  /// Creates the first local-light proof, not a public material API.
  const LocalVolumePlayground({super.key});
  @override
  State<LocalVolumePlayground> createState() => _LocalVolumePlaygroundState();
}

class _LocalVolumePlaygroundState extends State<LocalVolumePlayground> {
  double direction = .12,
      elevation = 1,
      ambient = .65,
      softness = .25,
      warmth = .4;
  Widget _slider(
    String label,
    String key,
    double value,
    double min,
    double max,
    ValueChanged<double> set,
    String unit,
  ) => MergeSemantics(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Slider(
          key: ValueKey(key),
          value: value,
          min: min,
          max: max,
          semanticFormatterCallback: (v) => unit == 'relative units'
              ? '${v.toStringAsFixed(2)} $unit'
              : '${(v * 100).round()} $unit',
          onChanged: set,
        ),
      ],
    ),
  );
  @override
  Widget build(BuildContext context) {
    final light = VolumeLight(
      x: -.85 + 1.7 * direction,
      y: -.7,
      z: elevation,
      ambient: ambient,
      softness: softness,
      warmth: warmth,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Light that belongs to the piece',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const Text(
          'Same contour, color, grain seed and light. Compare an edge-only rim, a thin sheet and a rounded sculpted profile.',
        ),
        _slider(
          'Light travel',
          'volume-direction',
          direction,
          0,
          1,
          (v) => setState(() => direction = v),
          'percent',
        ),
        _slider(
          'Light elevation',
          'volume-elevation',
          elevation,
          .6,
          1.6,
          (v) => setState(() => elevation = v),
          'relative units',
        ),
        _slider(
          'Ambient light',
          'volume-ambient',
          ambient,
          .4,
          .9,
          (v) => setState(() => ambient = v),
          'percent',
        ),
        _slider(
          'Light softness',
          'volume-softness',
          softness,
          0,
          1,
          (v) => setState(() => softness = v),
          'percent',
        ),
        _slider(
          'Warm light',
          'volume-warmth',
          warmth,
          0,
          1,
          (v) => setState(() => warmth = v),
          'percent',
        ),
        const Text('One shared light, thin and rounded pieces'),
        const Text(
          'Original cuts rotate independently. Light stays in scene space; grain and profile remain separate.',
        ),
        const SizedBox(height: 12),
        MixedVolumeStudy(light: light),
        const SizedBox(height: 24),
        VolumeStudies(light: light),
        const SizedBox(height: 24),
        const Text('At screen size: the same three cuts together'),
        const SizedBox(height: 8),
        VolumeStudies(light: light, compact: true),
        const SizedBox(height: 16),
        const Text(
          'Experimental local height/normal shading and receiver-clipped shadows. Both new profiles intentionally share the same subtle EVA grain, isolating volume. The rounded profile is a clay study, not a shipped clay material or a full 3D solver. Shared light here covers planar rotation only, without perspective, mutual occlusion or a 3D light solver. Phone measurements remain separate.',
        ),
      ],
    );
  }
}

/// The same fixed-condition comparison used by documentation and private review.
class VolumeComparisonSheet extends StatelessWidget {
  /// Keeps native headings separate from the decorative specimens.
  const VolumeComparisonSheet({super.key});
  @override
  Widget build(BuildContext context) => const Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Same cut. A different kind of volume.',
        style: TextStyle(fontFamily: 'Caveat', fontSize: 42),
      ),
      SizedBox(height: 6),
      Text(
        'One shape, one color, one grain seed, one light. Cloud, narrow corner and overlapping pieces.',
      ),
      SizedBox(height: 20),
      VolumeStudies(),
    ],
  );
}
