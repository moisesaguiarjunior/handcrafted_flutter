import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../example/lib/nap_studies.dart';
import '../example/test/support/fonts.dart';
import 'capture_support.dart';

void main() {
  testWidgets('capture real-size nap and layered foam specimens', (
    tester,
  ) async {
    await tester.runAsync(
      () => loadShowcaseFonts(directory: 'example/assets/fonts'),
    );
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await captureExample(
      tester,
      'build/nap/comparison.png',
      const Size(1240, 650),
      const Padding(padding: EdgeInsets.all(24), child: NapSampleSheet()),
    );
    for (final width in [320.0, 390.0, 428.0]) {
      await captureExample(
        tester,
        'build/nap/at-${width.round()}.png',
        Size(width, 1500),
        const Padding(padding: EdgeInsets.all(16), child: NapSampleSheet()),
      );
    }
  });
}
