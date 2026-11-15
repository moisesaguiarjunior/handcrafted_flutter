import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

/// Three runnable compositions built from the package's implemented APIs.
enum CraftUseCase {
  /// A textured paper card with a felt label and a native action.
  keepsake,

  /// Independently pivoting native widgets under a wooden support.
  hanging,

  /// The extracted, authored kite-tail deformation.
  kite,
}

/// Colors shared by runnable examples and deterministic README captures.
abstract final class DemoPalette {
  /// Pale blue presentation workspace.
  static const board = Color(0xFFEDF3F8);

  /// Dark blue reading ink.
  static const ink = Color(0xFF1E3044);

  /// Light paper fill.
  static const paper = Color(0xFFFFFDF8);

  /// Sage cloth fill.
  static const sage = Color(0xFF80A99A);

  /// Rose felt fill.
  static const rose = Color(0xFFD4A0AE);

  /// Dark rose thread, kept distinct from the felt substrate.
  static const thread = Color(0xFFB77584);

  /// Wooden support fill.
  static const wood = Color(0xFFBF9D70);
}

/// Theme for the gallery and capture harness; fonts live only in the example.
ThemeData showcaseTheme() => ThemeData(
  fontFamily: 'Inter',
  scaffoldBackgroundColor: DemoPalette.board,
  colorScheme: ColorScheme.fromSeed(seedColor: DemoPalette.ink),
  textTheme: const TextTheme(bodyMedium: TextStyle(color: DemoPalette.ink)),
);

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
        MediaQuery.textScalerOf(context).scale(14) > 21) {
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
      height: 340,
      child: switch (kind) {
        CraftUseCase.keepsake => _KeepsakeCard(onAction: onAction),
        CraftUseCase.hanging => _HangingParts(
          progress: progress,
          onAction: onAction,
        ),
        CraftUseCase.kite => _KiteStudy(progress: progress),
      },
    );
  }
}

Path _paperCut(Size size) =>
    pigmentOutline((Offset.zero & size).deflate(5), seed: 23, broad: true);

class _KeepsakeCard extends StatelessWidget {
  const _KeepsakeCard({this.onAction});
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Stack(
    clipBehavior: Clip.none,
    children: [
      Positioned(
        left: 46,
        top: 52,
        child: CraftPart(
          key: const ValueKey('paper-card'),
          size: const Size(340, 250),
          pose: PartPose(rotation: -.035),
          pivot: Alignment.center,
          child: RepaintBoundary(
            child: CraftSurface(
              material: CraftMaterial.paper,
              color: DemoPalette.paper,
              outline: _paperCut,
              child: CustomPaint(
                foregroundPainter: const _CardSeam(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(32, 38, 32, 24),
                  child: Column(
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
                      const Spacer(),
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

class _CardSeam extends CustomPainter {
  const _CardSeam();
  @override
  void paint(Canvas canvas, Size size) {
    final seam = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          (Offset.zero & size).deflate(21),
          const Radius.circular(26),
        ),
      );
    paintRunningStitch(
      canvas,
      seam,
      thread: DemoPalette.thread,
      dash: 5,
      gap: 4,
      width: 1.2,
      compression: .4,
    );
  }

  @override
  bool shouldRepaint(_CardSeam oldDelegate) => false;
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

class _KiteStudy extends StatefulWidget {
  const _KiteStudy({required this.progress});
  final double progress;
  @override
  State<_KiteStudy> createState() => _KiteStudyState();
}

class _KiteStudyState extends State<_KiteStudy> {
  final textures = MaterialTextures();
  @override
  void dispose() {
    textures.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _KitePainter(widget.progress, textures));
}

class _KitePainter extends CustomPainter {
  _KitePainter(this.progress, this.textures);
  final double progress;
  final MaterialTextures textures;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width * .63, 88);
    canvas.scale(1.1);
    final sail = Path()
      ..moveTo(0, -31)
      ..lineTo(24, 2)
      ..lineTo(-2, 31)
      ..lineTo(-21, 0)
      ..close();
    textures.paint(
      canvas,
      sail,
      material: CraftMaterial.paper,
      color: DemoPalette.rose,
    );
    final thread = Paint()
      ..color = DemoPalette.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawPath(
      Path()
        ..moveTo(0, -31)
        ..lineTo(-2, 31)
        ..moveTo(-21, 0)
        ..lineTo(24, 2),
      thread,
    );
    final tail = authoredKiteTail(progress);
    canvas.drawPath(tail, thread);
    final metric = tail.computeMetrics().single;
    for (final fraction in [.18, .36, .66]) {
      final tangent = metric.getTangentForOffset(metric.length * fraction);
      if (tangent == null) continue;
      canvas.save();
      canvas.translate(tangent.position.dx, tangent.position.dy);
      canvas.rotate(tangent.angle);
      final bow = Path()
        ..moveTo(0, 0)
        ..lineTo(-5, -8)
        ..lineTo(6, -7)
        ..close()
        ..moveTo(0, 0)
        ..lineTo(-5, 8)
        ..lineTo(6, 7)
        ..close();
      textures.paint(
        canvas,
        bow,
        material: CraftMaterial.twill,
        color: DemoPalette.sage,
      );
      canvas.restore();
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_KitePainter old) =>
      old.progress != progress || old.textures != textures;
}
