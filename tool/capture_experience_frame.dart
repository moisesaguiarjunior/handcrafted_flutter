import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../example/lib/experience_study.dart';
import '../example/lib/imported_layers.dart';
import '../example/test/support/fonts.dart';
import 'capture_support.dart';

void main() {
  testWidgets(
    'capture actual responsive artboard and unscaled native content',
    (tester) async {
      await tester.runAsync(
        () => loadShowcaseFonts(directory: 'assets/fonts', materialIcons: true),
      );
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      await tester.runAsync(
        () => precacheImage(
          const AssetImage(layerAsset),
          tester.element(find.byType(SizedBox).first),
        ),
      );
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      for (final view in [
        ('wide', const Size(1280, 720), 1.0),
        ('narrow', const Size(360, 800), 1.0),
        ('short-large-text', const Size(720, 360), 2.5),
      ]) {
        await captureExample(
          tester,
          'build/experience/${view.$1}.png',
          view.$2,
          const ExperienceFrameStudy(initialProgress: .65),
          themeAnimationStyle: AnimationStyle.noAnimation,
          mediaQuery: MediaQueryData(
            size: view.$2,
            textScaler: TextScaler.linear(view.$3),
          ),
        );
      }
    },
  );
}
