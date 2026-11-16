import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../example/lib/living_materials.dart';
import '../example/test/support/fonts.dart';
import 'capture_support.dart';

void main() {
  testWidgets('capture actual finishing stitches with a moving thread tip', (
    tester,
  ) async {
    await tester.runAsync(
      () => loadShowcaseFonts(directory: 'example/assets/fonts'),
    );
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    for (var i = 0; i <= 48; i++) {
      await captureExample(
        tester,
        'build/thread-finishing/frame_${i.toString().padLeft(3, '0')}.png',
        const Size(900, 580),
        Padding(
          padding: const EdgeInsets.all(24),
          child: LivingMaterialArtwork(
            technique: LivingTechnique.embroidery,
            progress: i / 48,
            threadExperiment: ThreadExperiment.finishing,
          ),
        ),
      );
    }
  });
}
