import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

import 'kite_art.dart';
import 'showcase_theme.dart';
import 'seam_studies.dart';

export 'showcase_theme.dart';

/// Three runnable compositions built from the package's implemented APIs.
enum CraftUseCase {
  /// A textured paper card with a felt label and a native action.
  keepsake,

  /// Independently pivoting native widgets under a wooden support.
  hanging,

  /// The extracted, authored kite-tail deformation.
  kite,
}

/// Human-readable example names, independent of scene identity.
String useCaseTitle(CraftUseCase value) => switch (value) {
  CraftUseCase.keepsake => 'Paper, felt & a real button',
  CraftUseCase.hanging => 'Parts that move together',
  CraftUseCase.kite => 'A tail with its own motion',
};

/// A fixed logical artwork stage. Captures and the live gallery share this code.
///
/// [progress] is authored 0..1 entrance progress, never a wind/physics input.
/// Text and actions remain native widgets. The host supplies [onAction].
class UseCaseArt extends StatelessWidget {
  /// Creates a sample at an explicit pose, with no internal ticker.
  const UseCaseArt({
    super.key,
    required this.kind,
    this.progress = 1,
    this.onAction,
  });

  /// Stable example identity.
  final CraftUseCase kind;

  /// Authored pose input.
  final double progress;

  /// Optional native action used by the paper/felt samples.
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    if (kind == CraftUseCase.keepsake &&
        MediaQuery.textScalerOf(context).scale(14) >= 21) {
      return SizedBox(
        width: 440,
        child: CraftSurface(
          material: CraftMaterial.paper,
          color: DemoPalette.paper,
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Keepsakes'),
                const Text(
                  'Little things, kept close.',
                  style: TextStyle(fontFamily: 'Caveat', fontSize: 42),
                ),
                TextButton(
                  onPressed: onAction,
                  child: const Text('Open collection'),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return SizedBox(
      width: 440,
      height: kind == CraftUseCase.keepsake ? null : 340,
      child: switch (kind) {
        CraftUseCase.keepsake => _KeepsakeCard(onAction: onAction),
        CraftUseCase.hanging => _HangingParts(
          progress: progress,
          onAction: onAction,
        ),
        CraftUseCase.kite => KiteArt(progress: progress),
      },
    );
  }
}

class _KeepsakeCard extends StatelessWidget {
  const _KeepsakeCard({this.onAction});
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Stack(
    clipBehavior: Clip.none,
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(46, 52, 54, 38),
        child: Transform.rotate(
          key: const ValueKey('paper-card'),
          angle: -.035,
          child: RepaintBoundary(
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 340, minHeight: 250),
              child: SeamedSurface(
                material: CraftMaterial.paper,
                color: DemoPalette.paper,
                shape: const CraftOutline.pigment(
                  seed: 23,
                  broad: true,
                  padding: 5,
                ),
                inset: 16,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(32, 38, 32, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Little things,\nkept close.',
                        style: TextStyle(
                          fontFamily: 'Caveat',
                          fontSize: 42,
                          height: 1.05,
                          color: DemoPalette.ink,
                        ),
                      ),
                      TextButton(
                        onPressed: onAction,
                        child: const Text('Open collection'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      Positioned(
        left: 36,
        top: 24,
        child: CraftPart(
          key: const ValueKey('felt-label'),
          size: const Size(160, 62),
          pose: PartPose(rotation: -.085),
          pivot: Alignment.center,
          child: const RepaintBoundary(
            child: CraftSurface(
              material: CraftMaterial.felt,
              color: DemoPalette.sage,
              shape: CraftOutline.pigment(seed: 41, broad: true, padding: 2),
              child: Center(
                child: Text(
                  'Keepsakes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: DemoPalette.ink,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

class _HangingParts extends StatelessWidget {
  const _HangingParts({required this.progress, this.onAction});
  final double progress;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final swing = math.sin(progress * math.pi * 5) * (1 - progress);
    return Padding(
      padding: const EdgeInsets.fromLTRB(44, 24, 44, 0),
      child: CraftPart(
        key: const ValueKey('support'),
        size: const Size(352, 300),
        pose: PartPose(rotation: swing * .07),
        child: Stack(
          children: [
            const Positioned(
              left: 30,
              right: 30,
              top: 30,
              height: 18,
              child: RepaintBoundary(
                child: CraftSurface(
                  material: CraftMaterial.wood,
                  color: DemoPalette.wood,
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(child: CustomPaint(painter: _Strings())),
            ),
            for (final (id, left, material, color, direction) in [
              ('Paper', 34.0, CraftMaterial.paper, DemoPalette.paper, 1.0),
              ('Felt', 206.0, CraftMaterial.felt, DemoPalette.rose, -1.0),
            ])
              Positioned(
                left: left,
                top: 120,
                child: CraftPart(
                  key: ValueKey(id),
                  size: const Size(112, 110),
                  pose: PartPose(rotation: swing * direction * .3),
                  child: RepaintBoundary(
                    child: CraftSurface(
                      material: material,
                      color: color,
                      child: TextButton(
                        onPressed: onAction,
                        style: TextButton.styleFrom(
                          foregroundColor: DemoPalette.ink,
                        ),
                        child: Text(
                          id,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Strings extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final thread = Paint()
      ..color = DemoPalette.ink
      ..strokeWidth = 1.2;
    canvas.drawLine(const Offset(176, 0), const Offset(176, 30), thread);
    for (final x in [90.0, 262.0]) {
      canvas.drawLine(Offset(x, 48), Offset(x, 120), thread);
    }
  }

  @override
  bool shouldRepaint(_Strings oldDelegate) => false;
}
