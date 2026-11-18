import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../example/lib/spatial_light_study.dart';
import '../example/test/support/fonts.dart';
import 'capture_support.dart';

void main() {
  testWidgets('capture live light studio', (t) async {
    await t.runAsync(loadShowcaseFonts);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetDevicePixelRatio);
    addTearDown(t.view.resetPhysicalSize);
    await captureExample(
      t,
      'build/light-studio/scene.png',
      const Size(1000, 680),
      const Padding(
        padding: EdgeInsets.all(24),
        child: SpatialLightStudy(previewOnly: true),
      ),
      themeAnimationStyle: AnimationStyle.noAnimation,
    );
    await captureExample(
      t,
      'build/light-studio/at-390.png',
      const Size(390, 1400),
      const SingleChildScrollView(
        child: Padding(padding: EdgeInsets.all(16), child: SpatialLightStudy()),
      ),
      themeAnimationStyle: AnimationStyle.noAnimation,
    );
  });
}
