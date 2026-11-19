import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:handcrafted_example/showcase_theme.dart';
import 'package:handcrafted_example/surface_proofs.dart';
import '../test/support/fonts.dart';
import '../test/support/surface_raster.dart';
import '../../tool/capture_support.dart';

// Run from example: flutter test tool/capture_surfaces.dart
void main() {
  testWidgets('capture synthetic surface recipes and clipping/cost evidence', (
    tester,
  ) async {
    await tester.runAsync(loadShowcaseFonts);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final scenes = [
      SurfaceProof(recipe: SurfaceRecipe.watercolor),
      SurfaceProof(
        recipe: SurfaceRecipe.featheredWash,
        domain: const Rect.fromLTWH(0, 0, 480, 360),
      ),
      SurfaceProof(
        recipe: SurfaceRecipe.fibers,
        domain: const Rect.fromLTWH(0, 0, 480, 240),
      ),
      SurfaceProof(recipe: SurfaceRecipe.checker),
      SurfaceProof(recipe: SurfaceRecipe.diamonds),
    ];
    try {
      final labels = [
        'Layered pigment',
        'A quieter, soft-edged wash',
        'Fine vertical fibers',
        'Printed checks on cotton',
        'Printed diamonds on cotton',
      ];
      await captureExample(
        tester,
        'build/surface-proofs/recipes.png',
        const Size(1060, 1120),
        Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Paper beyond one screen',
                style: TextStyle(fontFamily: 'Caveat', fontSize: 48),
              ),
              const Text(
                'Retained grain, soft pigment and printed cloth. Synthetic recipes, with no app artwork.',
              ),
              const SizedBox(height: 28),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _Specimen(
                        scene: scenes[0],
                        label: labels[0],
                        viewport: const Rect.fromLTWH(70, 170, 460, 860),
                      ),
                    ),
                    const SizedBox(width: 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (var i = 1; i < scenes.length; i++)
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _Specimen(
                                  scene: scenes[i],
                                  label: labels[i],
                                  viewport: i == 1
                                      ? scenes[i].domain
                                      : const Rect.fromLTWH(0, 0, 480, 200),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        themeAnimationStyle: AnimationStyle.noAnimation,
      );
      await tester.runAsync(() async {
        final report = <String, Object>{
          'environment':
              'Flutter test engine, local desktop; not a physical phone',
          'domain': [960, 1728],
          'viewport': [73.25, 417.5, 320, 256],
          'stripHeight': 64,
          'comparison': <Object>[],
          'cost': <Object>[],
        };
        final comparison = report['comparison']! as List<Object>;
        final costs = report['cost']! as List<Object>;
        const viewport = Rect.fromLTWH(73.25, 417.5, 320, 256);
        for (final recipe in SurfaceRecipe.values) {
          final clock = Stopwatch()..start();
          final scene = SurfaceProof(recipe: recipe);
          final recordUs = clock.elapsedMicroseconds;
          try {
            for (final ratio in [1.0, 3.0]) {
              clock.reset();
              final whole = await rasterSurface(scene, viewport, ratio: ratio);
              final firstRasterUs = clock.elapsedMicroseconds;
              clock.reset();
              final again = await rasterSurface(scene, viewport, ratio: ratio);
              final warmRasterUs = clock.elapsedMicroseconds;
              expect(again, whole);
              final strips = await rasterSurface(
                scene,
                viewport,
                ratio: ratio,
                stripHeight: 64,
              );
              final wrong = await rasterRestartedStrips(
                recipe,
                viewport,
                ratio: ratio,
              );
              final delta = SurfaceRasterDelta(whole, strips);
              final wrongDelta = SurfaceRasterDelta(whole, wrong);
              expect(delta.withinFor(recipe), isTrue);
              expect(wrongDelta.withinFor(recipe), isFalse);
              comparison.add({
                'recipe': recipe.name,
                'ratio': ratio,
                'maxChannelDelta': delta.maximum,
                'changedChannels': delta.changed,
                'meanChannelDelta': delta.mean,
                'meanLimit': surfaceMeanLimit(recipe),
                'restartedMaxChannelDelta': wrongDelta.maximum,
                'restartedChangedChannels': wrongDelta.changed,
                'restartedMeanChannelDelta': wrongDelta.mean,
                'retainedWithinBounds': delta.withinFor(recipe),
                'perStripRestartWithinBounds': wrongDelta.withinFor(recipe),
              });
              costs.add({
                'recipe': recipe.name,
                'ratio': ratio,
                'coldRecordUs': recordUs,
                'firstRasterReadbackUs': firstRasterUs,
                'warmRasterReadbackUs': warmRasterUs,
              });
              final data = await rasterSurface(
                scene,
                viewport,
                ratio: ratio,
                png: true,
              );
              await File(
                'build/surface-proofs/${recipe.name}-${ratio.round()}x.png',
              ).writeAsBytes(data);
            }
          } finally {
            scene.dispose();
          }
        }
        final output = File('build/surface-proofs/report.json');
        await output.writeAsString(
          const JsonEncoder.withIndent('  ').convert(report),
        );
      });
    } finally {
      for (final scene in scenes) {
        scene.dispose();
      }
    }
  });
}

class _Specimen extends StatelessWidget {
  const _Specimen({
    required this.scene,
    required this.label,
    required this.viewport,
  });
  final SurfaceProof scene;
  final String label;
  final Rect viewport;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(label, style: const TextStyle(fontSize: 17, color: DemoPalette.ink)),
      const SizedBox(height: 8),
      Expanded(
        child: ClipRect(child: CustomPaint(painter: _Crop(scene, viewport))),
      ),
    ],
  );
}

class _Crop extends CustomPainter {
  _Crop(this.scene, this.viewport);
  final SurfaceProof scene;
  final Rect viewport;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / viewport.width, size.height / viewport.height);
    scene.paintViewport(canvas, viewport);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_Crop oldDelegate) =>
      scene != oldDelegate.scene || viewport != oldDelegate.viewport;
}
