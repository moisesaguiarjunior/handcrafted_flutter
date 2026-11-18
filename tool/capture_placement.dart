import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../example/lib/placement_studies.dart';
import '../example/test/support/fonts.dart';
import 'capture_support.dart';

// Run from example so native asset/font resolution is the same as the gallery.
void main() {
  testWidgets('capture the actual contour-fit and dry-clearance comparison', (
    tester,
  ) async {
    await tester.runAsync(loadShowcaseFonts);
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    await tester.runAsync(
      () => precacheImage(
        const AssetImage(placementAsset),
        tester.element(find.byType(SizedBox).first),
      ),
    );
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await captureExample(
      tester,
      'build/placement/comparison.png',
      const Size(1100, 700),
      const Padding(padding: EdgeInsets.all(24), child: VisibleFitSheet()),
      themeAnimationStyle: AnimationStyle.noAnimation,
    );
    for (final width in [320.0, 390.0, 428.0]) {
      await captureExample(
        tester,
        'build/placement/at-${width.round()}.png',
        Size(width, 1100),
        const Padding(padding: EdgeInsets.all(16), child: VisibleFitSheet()),
        themeAnimationStyle: AnimationStyle.noAnimation,
      );
    }
  });
}
