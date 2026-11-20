import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcrafted_example/fluffy_study.dart';
import '../test/support/fonts.dart';
import '../../tool/capture_support.dart';

void main() {
  testWidgets('capture actual all-material and padded fluffy finishes', (
    tester,
  ) async {
    await tester.runAsync(loadShowcaseFonts);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await captureExample(
      tester,
      'build/fluffy/comparison.png',
      const Size(850, 1240),
      const Padding(padding: EdgeInsets.all(32), child: FluffyComparison()),
    );
    for (final width in [320.0, 390.0, 428.0]) {
      await captureExample(
        tester,
        'build/fluffy/at-${width.round()}.png',
        Size(width, 1500),
        const SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: FluffyMaterialsStudy(),
          ),
        ),
        mediaQuery: const MediaQueryData(textScaler: TextScaler.linear(2)),
      );
    }
  });
}
