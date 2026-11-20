import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcrafted_example/pillow_study.dart';

import '../test/support/fonts.dart';
import '../../tool/capture_support.dart';

void main() {
  testWidgets(
    'capture actual stuffed shapes and controlled fabric/fill comparisons',
    (tester) async {
      await tester.runAsync(loadShowcaseFonts);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      await captureExample(
        tester,
        'build/pillows/comparison.png',
        const Size(900, 1190),
        const Padding(padding: EdgeInsets.all(32), child: PillowComparison()),
        themeAnimationStyle: AnimationStyle.noAnimation,
      );
      for (final width in [320.0, 390.0, 428.0]) {
        await captureExample(
          tester,
          'build/pillows/at-${width.round()}.png',
          Size(width, 1000),
          const SingleChildScrollView(
            child: Padding(padding: EdgeInsets.all(16), child: PillowStudy()),
          ),
          mediaQuery: const MediaQueryData(textScaler: TextScaler.linear(2)),
          themeAnimationStyle: AnimationStyle.noAnimation,
        );
      }
    },
  );
}
