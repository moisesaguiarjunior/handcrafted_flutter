import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../example/lib/volume_studies.dart';
import '../example/lib/mixed_volume_study.dart';
import '../example/test/support/fonts.dart';
import 'capture_support.dart';

void main() {
  testWidgets('capture controlled local volume comparison', (tester) async {
    await tester.runAsync(
      () => loadShowcaseFonts(directory: 'example/assets/fonts'),
    );
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await captureExample(
      tester,
      'build/local-volume/comparison.png',
      const Size(1100, 830),
      const Padding(
        padding: EdgeInsets.all(32),
        child: VolumeComparisonSheet(),
      ),
    );
    await captureExample(
      tester,
      'build/local-volume/mixed.png',
      const Size(1000, 650),
      const Padding(padding: EdgeInsets.all(32), child: MixedVolumeStudy()),
    );
    for (final width in [320.0, 390.0]) {
      await captureExample(
        tester,
        'build/local-volume/at-${width.round()}.png',
        Size(width, 260),
        const VolumeStudies(compact: true),
      );
    }
  });
}
