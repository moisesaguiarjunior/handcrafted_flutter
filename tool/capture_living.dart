import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../example/lib/living_materials.dart';
import '../example/lib/motion_studies.dart';
import '../example/test/support/fonts.dart';
import 'capture_support.dart';

void main() {
  testWidgets('capture actual spreading pigment embroidery and varied motion', (
    tester,
  ) async {
    await tester.runAsync(
      () => loadShowcaseFonts(directory: 'example/assets/fonts'),
    );
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    Widget sheet(
      LivingTechnique technique,
      double progress, {
      ThreadExperiment thread = ThreadExperiment.passing,
    }) => Padding(
      padding: const EdgeInsets.all(24),
      child: LivingMaterialArtwork(
        technique: technique,
        progress: progress,
        threadExperiment: thread,
      ),
    );
    await captureExample(
      tester,
      'build/living/watercolor-hero.png',
      const Size(1200, 780),
      sheet(LivingTechnique.watercolor, 1),
    );
    await captureExample(
      tester,
      'build/living/embroidery.png',
      const Size(1000, 650),
      sheet(LivingTechnique.embroidery, .72),
    );
    for (var i = 0; i <= 48; i++) {
      final progress = i / 48;
      await captureExample(
        tester,
        'build/living/wash/frame_${i.toString().padLeft(3, '0')}.png',
        const Size(900, 580),
        sheet(LivingTechnique.watercolor, progress),
      );
      await captureExample(
        tester,
        'build/living/stitch/frame_${i.toString().padLeft(3, '0')}.png',
        const Size(900, 580),
        sheet(LivingTechnique.embroidery, progress),
      );
      await captureExample(
        tester,
        'build/living/reveal/frame_${i.toString().padLeft(3, '0')}.png',
        const Size(900, 580),
        sheet(
          LivingTechnique.embroidery,
          progress,
          thread: ThreadExperiment.embroidery,
        ),
      );
      await captureExample(
        tester,
        'build/living/reaction/frame_${i.toString().padLeft(3, '0')}.png',
        const Size(1100, 460),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final wetness in [0.0, 1.0])
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          wetness == 0
                              ? 'Blue over dry pink'
                              : 'Blue into wet pink',
                          style: const TextStyle(
                            fontFamily: 'Caveat',
                            fontSize: 32,
                          ),
                        ),
                        const SizedBox(height: 12),
                        LivingMaterialArtwork(
                          technique: LivingTechnique.watercolor,
                          progress: progress,
                          experiment: WatercolorExperiment.layers,
                          wetness: wetness,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
      await captureExample(
        tester,
        'build/living/motion/frame_${i.toString().padLeft(3, '0')}.png',
        const Size(1000, 470),
        MotionStage(progress: progress),
      );
    }
    await tester.pumpWidget(const SizedBox());
  });
}
