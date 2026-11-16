import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

import 'showcase_theme.dart';

/// Fixed-work authored particles; not fluid dynamics or a particle engine.
class PourRecipe {
  /// Prepares twelve stable variations and eighteen dust locations once.
  PourRecipe({int seed = 23}) {
    final random = math.Random(seed);
    _drift = List<double>.unmodifiable(
      List.generate(12, (_) => random.nextDouble() * 16 - 8),
    );
    _dust = List<Offset>.unmodifiable(
      List.generate(
        18,
        (_) => Offset(random.nextDouble(), random.nextDouble()),
      ),
    );
  }
  late final List<double> _drift;
  late final List<Offset> _dust;

  /// Positions in the caller's coordinate system; endpoints return no particles.
  List<Offset> droplets({
    required Offset emitter,
    required Offset destination,
    required double progress,
  }) {
    _validate(progress);
    if (![
      emitter.dx,
      emitter.dy,
      destination.dx,
      destination.dy,
    ].every((n) => n.isFinite)) {
      throw ArgumentError('Expected finite anchors');
    }
    if (progress == 0 || progress == 1) return const [];
    return [
      for (var i = 0; i < _drift.length; i++)
        if ((progress - i * .035) / .55 case final t when t >= 0 && t <= 1)
          Offset.lerp(emitter, destination, t)! +
              Offset(
                _drift[i] * math.sin(math.pi * t),
                -24 * math.sin(math.pi * t),
              ),
    ];
  }

  /// Draws a bounded light/dust wash and droplets; nothing is drawn at rest.
  void paint(
    Canvas canvas,
    Size size, {
    required Offset emitter,
    required Offset destination,
    required double progress,
  }) {
    final drops = droplets(
      emitter: emitter,
      destination: destination,
      progress: progress,
    );
    if (progress == 0 || progress == 1) return;
    final strength = math.sin(math.pi * progress);
    final beam = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * .35, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width * .7, size.height)
      ..close();
    canvas.drawPath(
      beam,
      Paint()
        ..color = const Color(0xFFFFE4A1).withValues(alpha: .18 * strength),
    );
    final dustPaint = Paint()
      ..color = DemoPalette.wood.withValues(alpha: .5 * strength);
    for (final point in _dust) {
      canvas.drawCircle(
        Offset(point.dx * size.width, point.dy * size.height),
        1.5,
        dustPaint,
      );
    }
    final water = Paint()..color = const Color(0xFF528DAD);
    for (final drop in drops) {
      canvas.drawOval(
        Rect.fromCenter(center: drop, width: 4, height: 7),
        water,
      );
    }
    if (progress < .55) canvas.drawCircle(emitter, 2, water);
  }

  void _validate(double progress) {
    if (!progress.isFinite || progress < 0 || progress > 1) {
      throw ArgumentError.value(progress, 'progress', 'Expected 0..1');
    }
  }
}

Path _vessel(Size size) {
  final path = Path()
    ..moveTo(18, 26)
    ..lineTo(70, 26)
    ..lineTo(82, 44)
    ..lineTo(99, 22)
    ..lineTo(108, 30)
    ..lineTo(84, 67)
    ..quadraticBezierTo(78, 88, 45, 88)
    ..quadraticBezierTo(12, 88, 18, 26)
    ..close();
  return path.transform(
    Matrix4.diagonal3Values(size.width / 120, size.height / 100, 1).storage,
  );
}

/// Original paper vessel and mapped emitter, driven by external progress only.
class BoundedEffectsSample extends StatefulWidget {
  /// Creates a deterministic static pose.
  const BoundedEffectsSample({
    super.key,
    required this.progress,
    this.seed = 23,
  });

  /// Explicit finite effect progress in 0..1.
  final double progress;

  /// Seed changes replace the fixed recipe; poses do not grow its storage.
  final int seed;
  @override
  State<BoundedEffectsSample> createState() => _BoundedEffectsSampleState();
}

class _BoundedEffectsSampleState extends State<BoundedEffectsSample> {
  late PourRecipe _recipe = PourRecipe(seed: widget.seed);
  @override
  void didUpdateWidget(BoundedEffectsSample oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.seed != widget.seed) _recipe = PourRecipe(seed: widget.seed);
  }

  @override
  Widget build(BuildContext context) {
    _recipe._validate(widget.progress);
    return LayoutBuilder(
      builder: (context, bounds) {
        final scale = math.min(bounds.maxWidth / 400, 1.0);
        final size = Size(120 * scale, 100 * scale);
        final origin = const Offset(35, 40) * scale;
        final envelope = widget.progress == 0 || widget.progress == 1
            ? 0.0
            : math.sin(math.pi * widget.progress);
        final pose = PartPose(rotation: .4 * envelope);
        final emitter =
            origin +
            pose.mapPoint(
              const Offset(104, 26) * scale,
              size: size,
              pivot: Alignment.center,
            );
        final destination = const Offset(315, 225) * scale;
        return ClipRect(
          child: SizedBox(
            width: 400 * scale,
            height: 270 * scale,
            child: Stack(
              children: [
                Positioned(
                  left: origin.dx,
                  top: origin.dy,
                  width: size.width,
                  height: size.height,
                  child: CraftPart(
                    key: const ValueKey('pour-vessel'),
                    size: size,
                    pose: pose,
                    pivot: Alignment.center,
                    child: CraftSurface(
                      material: CraftMaterial.paper,
                      color: DemoPalette.sage,
                      outline: _vessel,
                      child: const SizedBox.expand(),
                    ),
                  ),
                ),
                Positioned(
                  left: destination.dx - 25,
                  top: destination.dy,
                  child: const SizedBox(
                    width: 50,
                    height: 12,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: DemoPalette.rose,
                        borderRadius: BorderRadius.all(Radius.circular(6)),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: BoundedEffectsPainter(
                        recipe: _recipe,
                        emitter: emitter,
                        destination: destination,
                        progress: widget.progress,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// One recipe, explicit anchors and progress; no mutable per-frame storage.
class BoundedEffectsPainter extends CustomPainter {
  /// Creates the painter from caller-mapped anchors.
  const BoundedEffectsPainter({
    required this.recipe,
    required this.emitter,
    required this.destination,
    required this.progress,
  });

  /// Owner-scoped immutable particle recipe.
  final PourRecipe recipe;

  /// Transformed source attachment.
  final Offset emitter;

  /// Target attachment in the same coordinates.
  final Offset destination;

  /// Explicit effect progress.
  final double progress;
  @override
  void paint(Canvas canvas, Size size) => recipe.paint(
    canvas,
    size,
    emitter: emitter,
    destination: destination,
    progress: progress,
  );
  @override
  bool shouldRepaint(BoundedEffectsPainter old) =>
      recipe != old.recipe ||
      emitter != old.emitter ||
      destination != old.destination ||
      progress != old.progress;
}

/// Native finite-playback and scrubbing controls for the authored effect.
class BoundedEffectsPlayground extends StatefulWidget {
  /// Creates a quiet, initially settled demonstration.
  const BoundedEffectsPlayground({super.key});
  @override
  State<BoundedEffectsPlayground> createState() =>
      _BoundedEffectsPlaygroundState();
}

class _BoundedEffectsPlaygroundState extends State<BoundedEffectsPlayground> {
  double _manual = 0;
  bool _playing = false;
  int _run = 0, _seed = 23;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'A little pour, a passing light',
        style: TextStyle(fontFamily: 'Caveat', fontSize: 38),
      ),
      const Text(
        'A finite authored effect. Twelve droplets, eighteen dust points, one supplied time.',
      ),
      SceneEntrance(
        key: ValueKey(_run),
        active: _playing,
        startSettled: !_playing,
        duration: const Duration(milliseconds: 1800),
        builder: (context, p) =>
            BoundedEffectsSample(progress: _playing ? p : _manual, seed: _seed),
      ),
      Text('Manual pose ${(_manual * 100).round()}%'),
      Slider(
        key: const ValueKey('effect-progress'),
        value: _manual,
        onChanged: (v) => setState(() {
          _manual = v;
          _playing = false;
        }),
      ),
      Wrap(
        spacing: 12,
        runSpacing: 8,
        children: [
          TextButton(
            onPressed: () => setState(() {
              _playing = true;
              _run++;
            }),
            child: const Text('Play pour'),
          ),
          TextButton(
            onPressed: () => setState(() {
              _playing = false;
              _manual = 1;
            }),
            child: const Text('Rest'),
          ),
          TextButton(
            onPressed: () => setState(() => _seed++),
            child: const Text('Change seed'),
          ),
        ],
      ),
      const Text(
        'The vessel and emitter share a pose. Endpoints draw no effect. '
        'Automatic playback respects reduced motion; manual scrubbing is explicit.',
      ),
    ],
  );
}
