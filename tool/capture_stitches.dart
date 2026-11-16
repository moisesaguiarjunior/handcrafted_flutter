import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../example/lib/stitch_studies.dart';
import '../example/test/support/fonts.dart';
import 'capture_support.dart';

void main() {
  testWidgets('capture real stitch families and shared cut', (tester) async {
    await tester.runAsync(
      () => loadShowcaseFonts(directory: 'example/assets/fonts'),
    );
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await captureExample(
      tester,
      'build/stitches/stitch-families.png',
      const Size(1100, 730),
      const Padding(
        padding: EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thread, six ways',
              style: TextStyle(fontFamily: 'Caveat', fontSize: 48),
            ),
            SizedBox(height: 20),
            StitchStudies(),
          ],
        ),
      ),
    );
  });
}
