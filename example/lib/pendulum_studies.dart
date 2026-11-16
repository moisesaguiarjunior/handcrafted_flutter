import 'package:flutter/material.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

import 'showcase_theme.dart';

/// Compares direct/exaggerated physics using externally supplied elapsed time.
class PendulumStudies extends StatelessWidget {
  /// Creates two independent native-widget pendulums without an internal clock.
  const PendulumStudies({
    super.key,
    required this.elapsed,
    this.gravity = 980,
    this.wind = 180,
    this.onTap,
  });

  /// Supplied time; callers resolve reduced motion before passing it.
  final Duration elapsed;

  /// Downward acceleration in logical pixels/s².
  final double gravity;

  /// Horizontal acceleration in logical pixels/s².
  final double wind;

  /// Real native action; no persistence or content behavior implied.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => Wrap(
      spacing: 24,
      runSpacing: 20,
      children: [
        for (final style in CraftPhysicsStyle.values)
          SizedBox(
            width: constraints.maxWidth.clamp(0, 320).toDouble(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(style.name, style: Theme.of(context).textTheme.titleLarge),
                SizedBox(
                  height: 320,
                  child: LayoutBuilder(
                    builder: (context, box) {
                      final sample = CraftPendulum(
                        length: 80,
                        gravity: gravity,
                        wind: Offset(wind, 0),
                        style: style,
                        initialAngle: .4,
                      ).sample(elapsed);
                      return Stack(
                        children: [
                          Positioned(
                            left: box.maxWidth / 2 - 4,
                            top: 156,
                            child: const DecoratedBox(
                              decoration: BoxDecoration(
                                color: DemoPalette.ink,
                                shape: BoxShape.circle,
                              ),
                              child: SizedBox(width: 8, height: 8),
                            ),
                          ),
                          Positioned(
                            left: box.maxWidth / 2 - 50,
                            top: 160,
                            child: CraftPart(
                              key: ValueKey('physics-${style.name}'),
                              size: const Size(100, 120),
                              pose: sample.pose,
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: CustomPaint(painter: _Cord()),
                                  ),
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    top: 40,
                                    height: 80,
                                    child: CraftSurface(
                                      material: CraftMaterial.felt,
                                      color:
                                          style == CraftPhysicsStyle.realistic
                                          ? DemoPalette.sage
                                          : DemoPalette.rose,
                                      shape: const CraftOutline.pigment(
                                        seed: 9,
                                        broad: true,
                                        padding: 2,
                                      ),
                                      child: TextButton(
                                        onPressed: onTap,
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.all(4),
                                        ),
                                        child: const Text('Tap'),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Text('Angle ${_sampleAngle(style).toStringAsFixed(2)} rad'),
              ],
            ),
          ),
      ],
    ),
  );
  double _sampleAngle(CraftPhysicsStyle style) => CraftPendulum(
    length: 80,
    gravity: gravity,
    wind: Offset(wind, 0),
    initialAngle: .4,
    style: style,
  ).sample(elapsed).angle;
}

class _Cord extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) => paintCraftTrim(
    canvas,
    Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width / 2, 80),
    color: DemoPalette.wood,
    width: 4,
    pitch: 3,
  );
  @override
  bool shouldRepaint(_Cord old) => false;
}

/// Native parameter controls, scrubbing supplied time without scheduling frames.
class PendulumPlayground extends StatefulWidget {
  /// Creates a manual time/force playground.
  const PendulumPlayground({super.key});
  @override
  State<PendulumPlayground> createState() => _PendulumPlaygroundState();
}

class _PendulumPlaygroundState extends State<PendulumPlayground> {
  double seconds = 1, gravity = 980, wind = 180;
  int taps = 0;
  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.disableAnimationsOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'A little gravity, a passing breeze',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const Text(
          'Compare direct and exaggerated force response. Scrub time; no clock runs here.',
        ),
        Text('Supplied time: ${seconds.toStringAsFixed(1)} s'),
        Slider(
          value: seconds,
          max: 12,
          onChanged: (v) => setState(() => seconds = v),
        ),
        Text('Gravity: ${gravity.round()} logical px/s²'),
        Slider(
          value: gravity,
          max: 1600,
          onChanged: (v) => setState(() => gravity = v),
        ),
        Text('Horizontal wind: ${wind.round()} logical px/s²'),
        Slider(
          value: wind,
          min: -300,
          max: 300,
          onChanged: (v) => setState(() => wind = v),
        ),
        if (reduced)
          const Text('Reduced motion: showing a fixed 12-second pose.'),
        Text('Native actions: $taps'),
        PendulumStudies(
          elapsed: Duration(
            microseconds: ((reduced ? 12 : seconds) * 1000000).round(),
          ),
          gravity: gravity,
          wind: wind,
          onTap: () => setState(() => taps++),
        ),
      ],
    );
  }
}
