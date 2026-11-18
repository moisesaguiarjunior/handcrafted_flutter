import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

import 'material_studies.dart';

Path _softCut(double s) => Path()
  ..moveTo(0, s * .46)
  ..cubicTo(0, s * .12, s * .28, 0, s * .52, s * .13)
  ..cubicTo(s * .8, 0, s, s * .27, s, s * .49)
  ..cubicTo(s, s * .81, s * .72, s * .92, s * .49, s * .81)
  ..cubicTo(s * .23, s * .97, 0, s * .76, 0, s * .46)
  ..close();

/// Real-size original cuts, comparing three substrates under the same light.
class NapMaterialSamples extends StatefulWidget {
  /// Inputs that affect fibers are separate from their paint contrast.
  const NapMaterialSamples({
    super.key,
    this.scale = 1,
    this.density = .7,
    this.direction = -.4,
    this.contrast = .8,
  });

  /// Fiber dimensions; the existing woven/foam grains use the same tile scale.
  final double scale;

  /// Short-fiber admission rate, 0..1.
  final double density;

  /// Mean short-fiber orientation in radians.
  final double direction;

  /// Paint-only fiber contrast, 0..1.
  final double contrast;

  @override
  State<NapMaterialSamples> createState() => _NapMaterialSamplesState();
}

class _NapMaterialSamplesState extends State<NapMaterialSamples> {
  final textures = MaterialTextures(seed: 71);
  final light = CraftLight();
  late final cuts = [
    for (final s in [40.0, 70.0, 100.0]) _softCut(s),
  ];
  late final volumes = [
    for (final cut in cuts)
      CraftVolume(cut, CraftVolumeProfile.sheet, height: 1.5, bevel: 2),
  ];
  late List<CraftNap> naps = _prepare();
  List<CraftNap> _prepare() => [
    for (final cut in cuts)
      CraftNap(
        cut,
        scale: widget.scale,
        density: widget.density,
        direction: widget.direction,
      ),
  ];
  @override
  void didUpdateWidget(NapMaterialSamples old) {
    super.didUpdateWidget(old);
    if (old.scale != widget.scale ||
        old.density != widget.density ||
        old.direction != widget.direction) {
      naps = _prepare();
    }
  }

  @override
  void dispose() {
    textures.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SpecimenRow(
    children: [
      for (var material = 0; material < 3; material++)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ['Woven cotton', 'Short matte nap', 'Thin EVA'][material],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (var i = 0; i < 3; i++)
                  Column(
                    children: [
                      SizedBox(
                        width: 116,
                        height: 116,
                        child: Center(
                          child: SizedBox(
                            width: [56.0, 86.0, 116.0][i],
                            height: [56.0, 86.0, 116.0][i],
                            child: ExcludeSemantics(
                              child: IgnorePointer(
                                child: CustomPaint(
                                  key: ValueKey('nap-specimen-$material-$i'),
                                  painter: _NapPainter(
                                    textures,
                                    volumes[i],
                                    naps[i],
                                    light,
                                    material,
                                    widget.scale,
                                    widget.contrast,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Text('${[40, 70, 100][i]} px'),
                    ],
                  ),
              ],
            ),
          ],
        ),
    ],
  );
}

class _NapPainter extends CustomPainter {
  const _NapPainter(
    this.textures,
    this.volume,
    this.nap,
    this.light,
    this.material,
    this.scale,
    this.contrast,
  );
  final MaterialTextures textures;
  final CraftVolume volume;
  final CraftNap nap;
  final CraftLight light;
  final int material;
  final double scale, contrast;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    try {
      canvas.translate(8, 8);
      final cut = volume.outline;
      volume.shadow(canvas, light);
      if (material == 1) {
        canvas.drawPath(cut, Paint()..color = const Color(0xFF9CBFD0));
        nap.paint(canvas, contrast: contrast, ink: const Color(0xFF344F62));
      } else {
        textures.paint(
          canvas,
          cut,
          material: material == 0 ? CraftMaterial.cotton : CraftMaterial.eva,
          color: const Color(0xFF9CBFD0),
          strength: .65,
          scale: scale,
        );
      }
      volume.shade(canvas, light);
    } finally {
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_NapPainter old) =>
      old.textures != textures ||
      old.volume != volume ||
      old.nap != nap ||
      old.light != light ||
      old.material != material ||
      old.scale != scale ||
      old.contrast != contrast;
}

/// Independent foam cuts share light and a receiver-clipped overlap shadow.
class LayeredFoamSample extends StatefulWidget {
  /// Creates one synthetic layered leaf badge, without imported artwork.
  const LayeredFoamSample({super.key});
  @override
  State<LayeredFoamSample> createState() => _LayeredFoamSampleState();
}

class _LayeredFoamSampleState extends State<LayeredFoamSample> {
  final textures = MaterialTextures(seed: 71);
  late final base = CraftVolume(
    _softCut(148),
    CraftVolumeProfile.sheet,
    height: 3,
    bevel: 4,
  );
  late final face = CraftVolume(
    Path()
      ..moveTo(45, 92)
      ..cubicTo(35, 44, 90, 25, 124, 37)
      ..cubicTo(128, 77, 102, 104, 45, 92)
      ..close(),
    CraftVolumeProfile.sheet,
    height: 2,
    bevel: 3,
  );
  late final seam = CraftStitchFrame.sample(
    runningStitchPath(
      Path()
        ..moveTo(61, 86)
        ..quadraticBezierTo(87, 69, 110, 49),
      dash: 4,
      gap: 3,
      irregularity: .2,
      seed: 63,
    ),
    progress: 1,
  );
  @override
  void dispose() {
    textures.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = base,
        b = face,
        thread = seam; // Prepare all static geometry before paint.
    return SizedBox(
      width: 200,
      height: 180,
      child: ExcludeSemantics(
        child: IgnorePointer(
          child: CustomPaint(
            painter: _LayeredFoamPainter(textures, a, b, thread),
          ),
        ),
      ),
    );
  }
}

class _LayeredFoamPainter extends CustomPainter {
  const _LayeredFoamPainter(this.textures, this.base, this.face, this.seam);
  final MaterialTextures textures;
  final CraftVolume base, face;
  final CraftStitchFrame seam;
  @override
  void paint(Canvas canvas, Size size) {
    final light = CraftLight(x: -.8, y: -.65);
    canvas.save();
    try {
      canvas.translate(22, 18);
      base.shadow(canvas, light);
      textures.paint(
        canvas,
        base.outline,
        material: CraftMaterial.eva,
        color: const Color(0xFFE6B678),
        strength: .3,
      );
      paintFoamFinish(
        canvas,
        base.outline,
        finish: FoamFinish.mottled,
        ink: const Color(0xFFC58355),
        strength: .4,
        scale: .7,
      );
      base.shade(canvas, light);
      face.shadow(canvas, light, receiver: base.outline);
      textures.paint(
        canvas,
        face.outline,
        material: CraftMaterial.eva,
        color: const Color(0xFF87AD95),
        strength: .4,
      );
      paintFoamFinish(
        canvas,
        face.outline,
        finish: FoamFinish.mottled,
        ink: const Color(0xFF658C7D),
        strength: .4,
        scale: .6,
      );
      face.shade(canvas, light);
      canvas.save();
      try {
        canvas.clipPath(face.outline);
        seam.paint(
          canvas,
          thread: const Color(0xFFDBE2BD),
          width: .9,
          compression: .25,
          relief: CraftReliefKind.inset,
          light: light.planar,
        );
      } finally {
        canvas.restore();
      }
    } finally {
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_LayeredFoamPainter old) =>
      old.textures != textures ||
      old.base != base ||
      old.face != face ||
      old.seam != seam;
}

/// Native independent controls, reused by the live gallery and capture.
class NapPlayground extends StatefulWidget {
  /// Creates the small-scale comparison and layered foam recipe.
  const NapPlayground({super.key});
  @override
  State<NapPlayground> createState() => _NapPlaygroundState();
}

class _NapPlaygroundState extends State<NapPlayground> {
  double scale = 1, density = .7, direction = -.4, contrast = .8;
  Widget slider(
    String label,
    String key,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) => MergeSemantics(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Slider(
          key: ValueKey(key),
          label: label,
          min: min,
          max: max,
          value: value,
          semanticFormatterCallback: (v) => key == 'nap-direction'
              ? '${(v * 180 / math.pi).round()} degrees'
              : '${v.toStringAsFixed(2)} ${key == 'nap-scale' ? 'scale' : 'fraction'}',
          onChanged: onChanged,
        ),
      ],
    ),
  );
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Short fibers at screen size',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      const Text(
        'Same cut, color and light; actual 40, 70 and 100px artboards. '
        'Geometry controls affect nap; tile scale also changes the woven/EVA comparison. Contrast affects nap only.',
      ),
      slider(
        'Grain scale',
        'nap-scale',
        scale,
        .5,
        4,
        (v) => setState(() => scale = v),
      ),
      slider(
        'Fiber density',
        'nap-density',
        density,
        0,
        1,
        (v) => setState(() => density = v),
      ),
      slider(
        'Fiber direction',
        'nap-direction',
        direction,
        -math.pi,
        math.pi,
        (v) => setState(() => direction = v),
      ),
      slider(
        'Fiber contrast',
        'nap-contrast',
        contrast,
        0,
        1,
        (v) => setState(() => contrast = v),
      ),
      NapMaterialSamples(
        scale: scale,
        density: density,
        direction: direction,
        contrast: contrast,
      ),
      const SizedBox(height: 24),
      const Text(
        'Fine pores, diffuse pigment and a local pressed seam',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      const LayeredFoamSample(),
      const Text(
        'Two independently cut foam layers, separate bevels/heights, one light. '
        'The upper shadow clips to its receiver. This suggests texture and relief; it does not simulate fibers or foam.',
      ),
    ],
  );
}

/// Fixed specimen sheet shared by documentation capture and visual checks.
class NapSampleSheet extends StatelessWidget {
  /// Compares substrates at their real logical sizes, plus independent foam layers.
  const NapSampleSheet({super.key});
  @override
  Widget build(BuildContext context) => const Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Softness, without a grid',
        style: TextStyle(fontFamily: 'Caveat', fontSize: 42),
      ),
      Text(
        'One cut, one blue, one light. Woven cotton, irregular short fibers and fine-pore EVA.',
      ),
      SizedBox(height: 20),
      NapMaterialSamples(),
      SizedBox(height: 24),
      Text(
        'Layered EVA: diffuse pigment, independent cut edges and a localized pressed seam',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      LayeredFoamSample(),
    ],
  );
}
