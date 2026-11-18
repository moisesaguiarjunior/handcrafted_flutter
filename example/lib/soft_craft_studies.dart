import 'nap_studies.dart';

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

import 'material_studies.dart';

const _pocketColors = [Color(0xFFF1BD4E), Color(0xFF73B8C7), Color(0xFFF09599)];

/// Original pockets, powdery marks and folded cardstock using public painters.
class SoftCraftSamples extends StatelessWidget {
  /// Creates a shared live/capture composition; no animation clock is added.
  const SoftCraftSamples({
    super.key,
    this.irregularity = .75,
    this.pucker = .8,
    this.satin = true,
  });

  /// Seeded deviation from regular stitch geometry, 0..1.
  final double irregularity;

  /// Illustrative gathering around punctures, 0..1.
  final double pucker;

  /// Whether the folded-cardstock example includes the satin overlay.
  final bool satin;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Small things, softly made',
        style: Theme.of(context).textTheme.headlineMedium
            ?.copyWith(fontFamily: 'Caveat', fontSize: 42),
      ),
      const Text(
        'Compact weave, a soft nap, and thread that gently gathers the cloth.',
      ),
      const SizedBox(height: 16),
      SpecimenRow(
        children: [
          for (final (index, material, title) in [
            (0, CraftMaterial.cotton, 'Fine cotton'),
            (1, CraftMaterial.suede, 'Velvety cloth'),
            (2, CraftMaterial.felt, 'Soft felt'),
          ])
            _Specimen(
              title,
              'Irregular running stitch · recessed punctures',
              _SampleArt(index, material, irregularity, pucker, satin),
            ),
        ],
      ),
      const SizedBox(height: 28),
      LayoutBuilder(
        builder: (context, box) {
          final width = box.maxWidth >= 620
              ? (box.maxWidth - 24) / 2
              : box.maxWidth;
          return Wrap(
            spacing: 24,
            runSpacing: 24,
            children: [
              SizedBox(
                width: width,
                child: _Specimen(
                  'A little chalk garden',
                  'Powdery strokes on light paper',
                  _SampleArt(
                    3,
                    CraftMaterial.paper,
                    irregularity,
                    pucker,
                    satin,
                  ),
                ),
              ),
              SizedBox(
                width: width,
                child: _Specimen(
                  'Folded color',
                  'Playful card · soft folds · no wooden stick',
                  _SampleArt(
                    4,
                    CraftMaterial.paper,
                    irregularity,
                    pucker,
                    satin,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    ],
  );
}

class _Specimen extends StatelessWidget {
  const _Specimen(this.title, this.description, this.art);
  final String title, description;
  final Widget art;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      AspectRatio(aspectRatio: 1.18, child: art),
      const SizedBox(height: 10),
      Text(title, style: Theme.of(context).textTheme.titleMedium),
      Text(description),
    ],
  );
}

class _SampleArt extends StatefulWidget {
  const _SampleArt(
    this.index,
    this.material,
    this.irregularity,
    this.pucker,
    this.satin,
  );
  final int index;
  final CraftMaterial material;
  final double irregularity, pucker;
  final bool satin;
  @override
  State<_SampleArt> createState() => _SampleArtState();
}

class _SampleArtState extends State<_SampleArt> {
  final textures = MaterialTextures(seed: 83);
  @override
  void dispose() {
    textures.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: IgnorePointer(
      child: CustomPaint(
        painter: _SoftPainter(
          textures,
          widget.index,
          widget.material,
          widget.irregularity,
          widget.pucker,
          widget.satin,
        ),
      ),
    ),
  );
}

class _SoftPainter extends CustomPainter {
  _SoftPainter(
    this.textures,
    this.index,
    this.material,
    this.irregularity,
    this.pucker,
    this.satin,
  ) {
    if (index >= 3) {
      pocket = Path();
      prepared = Path();
      return;
    }
    pocket = Path()
      ..moveTo(83, 145)
      ..quadraticBezierTo(150, 161, 217, 145)
      ..lineTo(216, 241)
      ..quadraticBezierTo(217, 266, 194, 268)
      ..quadraticBezierTo(150, 276, 106, 268)
      ..quadraticBezierTo(82, 266, 84, 242)
      ..close();
    final seam = insetCraftPath(pocket, distance: 10);
    prepared = runningStitchPath(
      seam,
      dash: 7,
      gap: 4,
      irregularity: irregularity,
      seed: 83 + index,
    );
  }
  final MaterialTextures textures;
  final int index;
  final CraftMaterial material;
  final double irregularity, pucker;
  final bool satin;
  late final Path pocket, prepared;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 300, size.height / 300);
    final board = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(0, 0, 300, 300),
          const Radius.circular(18),
        ),
      );
    textures.paint(
      canvas,
      board,
      material: CraftMaterial.paper,
      color: const Color(0xFFFFFAF2),
      strength: .45,
    );
    if (index < 3) {
      _pocket(canvas);
    } else if (index == 3) {
      _chalk(canvas);
    } else {
      _pinwheel(canvas);
    }
    canvas.restore();
  }

  void _surface(
    Canvas canvas,
    Path shape,
    CraftMaterial material,
    Color color, {
    double depth = 2,
    double strength = 1,
  }) {
    canvas.drawShadow(shape, const Color(0x28392A21), depth * 1.3, false);
    textures.paint(
      canvas,
      shape,
      material: material,
      color: color,
      strength: strength,
    );
    paintCraftRelief(
      canvas,
      shape,
      kind: CraftReliefKind.raised,
      depth: depth,
      strength: .2,
    );
  }

  void _pocket(Canvas canvas) {
    final color = _pocketColors[index];
    final cord = Path()
      ..moveTo(15, 36)
      ..quadraticBezierTo(150, 72, 285, 36);
    paintCraftTrim(
      canvas,
      cord,
      color: const Color(0xFFBA8B56),
      width: 3,
      texture: .7,
    );
    final flag = Path()
      ..moveTo(122, 52)
      ..lineTo(183, 52)
      ..lineTo(179, 108)
      ..lineTo(151, 94)
      ..lineTo(125, 107)
      ..close();
    _surface(canvas, flag, material, color, depth: 1.5);
    canvas.save();
    canvas.clipPath(flag);
    paintRunningStitch(
      canvas,
      insetCraftPath(flag, distance: 5),
      thread: const Color(0xFFFFECD0),
      dash: 5,
      gap: 3,
      width: .9,
      irregularity: irregularity,
      seed: 90 + index,
      compression: .4,
      pucker: pucker,
    );
    canvas.restore();
    paintCraftTrim(
      canvas,
      Path()
        ..moveTo(151, 99)
        ..lineTo(151, 155),
      color: const Color(0xFFB68C5D),
      width: 2.8,
    );
    final lining = Path.from(pocket).shift(const Offset(0, -3));
    _surface(
      canvas,
      lining,
      material,
      Color.lerp(color, const Color(0xFF8C6B46), .1)!,
      depth: 1,
    );
    final tag = Path()
      ..moveTo(115, 127)
      ..quadraticBezierTo(150, 130, 183, 124)
      ..lineTo(187, 199)
      ..lineTo(113, 201)
      ..close();
    _surface(
      canvas,
      tag,
      CraftMaterial.paper,
      const Color(0xFFFFEAC8),
      depth: 1,
    );
    canvas.drawCircle(
      const Offset(150, 139),
      3,
      Paint()..color = const Color(0xFF9E7952),
    );
    _surface(canvas, pocket, material, color, depth: 1.5, strength: .65);
    // Broad pale cloth light, without a dark outlined rim.
    canvas.drawPath(
      pocket,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-.3, -.5),
          radius: 1.2,
          colors: [Color(0x28FFFFFF), Color(0x00FFFFFF)],
        ).createShader(pocket.getBounds()),
    );
    canvas.save();
    canvas.clipPath(pocket);
    CraftStitchFrame.sample(prepared, progress: 1).paint(
      canvas,
      thread: const Color(0xFFFFEED4),
      width: 1.5,
      compression: .5,
      pucker: pucker,
    );
    canvas.restore();
    // An original pressed sprig, deliberately different from the reference badge.
    final sprig = Path()
      ..moveTo(148, 231)
      ..quadraticBezierTo(148, 210, 159, 195)
      ..quadraticBezierTo(176, 199, 153, 213)
      ..quadraticBezierTo(130, 211, 137, 200)
      ..quadraticBezierTo(152, 204, 148, 231)
      ..close();
    paintCraftRelief(
      canvas,
      sprig,
      kind: CraftReliefKind.inset,
      depth: .65,
      strength: .2,
    );
  }

  void _chalk(Canvas canvas) {
    final paths = <(Path, Color)>[];
    const center = Offset(150, 104);
    for (var i = 0; i < 5; i++) {
      final angle = i * math.pi * 2 / 5;
      final tip = center + Offset(math.sin(angle), -math.cos(angle)) * 47;
      final side = Offset(math.cos(angle), math.sin(angle)) * 26;
      paths.add((
        Path()
          ..moveTo(center.dx, center.dy)
          ..cubicTo(
            tip.dx - side.dx,
            tip.dy - side.dy,
            tip.dx + side.dx,
            tip.dy + side.dy,
            center.dx,
            center.dy,
          ),
        const Color(0xFFCF7386),
      ));
    }
    paths.add((
      craftCurveThrough(const [
        Offset(150, 109),
        Offset(147, 172),
        Offset(158, 232),
      ], curvature: .7),
      const Color(0xFF84A56A),
    ));
    paths.add((
      Path()
        ..moveTo(150, 186)
        ..quadraticBezierTo(82, 135, 94, 177)
        ..quadraticBezierTo(110, 201, 150, 186),
      const Color(0xFF8AAA69),
    ));
    paths.add((
      craftCurveThrough(const [
        Offset(48, 249),
        Offset(84, 234),
        Offset(115, 254),
        Offset(160, 246),
        Offset(200, 229),
        Offset(251, 243),
      ]),
      const Color(0xFF65A3BD),
    ));
    for (final (path, color) in paths) {
      paintCraftStroke(
        canvas,
        path,
        color: color,
        style: const CraftStrokeStyle(
          tool: CraftStrokeTool.chalk,
          width: 6,
          variation: .9,
          dryCoverage: .85,
        ),
        seed: 63,
      );
    }
    canvas.drawCircle(center, 8, Paint()..color = const Color(0xFFE5BA57));
    for (final (p, color, angle) in [
      (const Offset(44, 205), const Color(0xFF73BAD0), -.5),
      (const Offset(245, 168), const Color(0xFFE5A3AA), .4),
    ]) {
      canvas.save();
      canvas.translate(p.dx, p.dy);
      canvas.rotate(angle);
      _surface(
        canvas,
        Path()..addRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(-14, -4, 28, 9),
            const Radius.circular(2),
          ),
        ),
        CraftMaterial.eva,
        color,
        depth: 1,
      );
      canvas.restore();
    }
  }

  void _pinwheel(Canvas canvas) {
    canvas.save();
    canvas.translate(150, 150);
    for (var i = 0; i < 4; i++) {
      canvas.save();
      canvas.rotate(i * math.pi / 2 + .15);
      final color = i.isEven
          ? const Color(0xFFFFCB48)
          : const Color(0xFFF68D80);
      final blade = Path()
        ..moveTo(0, 0)
        ..lineTo(-100, -95)
        ..lineTo(-105, -30)
        ..quadraticBezierTo(-70, 8, 0, 0)
        ..close();
      _surface(
        canvas,
        blade,
        CraftMaterial.paper,
        color,
        depth: 1,
        strength: .15,
      );
      if (satin) {
        paintPaperFinish(
          canvas,
          blade,
          finish: PaperFinish.satin,
          ink: const Color(0xFF6E392A),
          strength: .3,
        );
      }
      final curl = Path()
        ..moveTo(-100, -95)
        ..quadraticBezierTo(-48, -16, 0, 0)
        ..quadraticBezierTo(-77, -20, -100, -95)
        ..close();
      canvas.drawPath(
        curl,
        Paint()..color = Color.lerp(color, Colors.white, .32)!,
      );
      paintCraftRelief(
        canvas,
        curl,
        kind: CraftReliefKind.raised,
        depth: .45,
        strength: .12,
      );
      canvas.restore();
    }
    _surface(
      canvas,
      Path()..addOval(const Rect.fromLTWH(-12, -12, 24, 24)),
      CraftMaterial.paper,
      const Color(0xFFFFDF9A),
      depth: 2,
    );
    canvas.drawCircle(Offset.zero, 4, Paint()..color = const Color(0xFFDB9D52));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SoftPainter old) =>
      old.textures != textures ||
      old.index != index ||
      old.material != material ||
      old.irregularity != irregularity ||
      old.pucker != pucker ||
      old.satin != satin;
}

/// Native controls for optional sewing irregularity and illustrative gathering.
class SoftCraftPlayground extends StatefulWidget {
  /// Creates native controls around the shared specimen sheet.
  const SoftCraftPlayground({super.key});
  @override
  State<SoftCraftPlayground> createState() => _SoftCraftPlaygroundState();
}

class _SoftCraftPlaygroundState extends State<SoftCraftPlayground> {
  double irregularity = .75, pucker = .8;
  bool satin = true;
  Widget _slider(
    String label,
    String key,
    double value,
    ValueChanged<double> changed,
  ) => MergeSemantics(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Slider(
          key: ValueKey(key),
          value: value,
          semanticFormatterCallback: (v) => '${(v * 100).round()} percent',
          onChanged: changed,
        ),
      ],
    ),
  );
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _slider(
        'Sewing irregularity',
        'soft-irregularity',
        irregularity,
        (v) => setState(() => irregularity = v),
      ),
      _slider(
        'Cloth gathering',
        'soft-pucker',
        pucker,
        (v) => setState(() => pucker = v),
      ),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Satin paper sheen'),
        value: satin,
        onChanged: (v) => setState(() => satin = v),
      ),
      SoftCraftSamples(
        irregularity: irregularity,
        pucker: pucker,
        satin: satin,
      ),
      const SizedBox(height: 16),
      const Text(
        'Shading suggests indentation and folded light. No cloth displacement, optical coating or wind simulation is claimed. Text and controls stay native.',
      ),
      const SizedBox(height: 28),
      const NapPlayground(),
    ],
  );
}
