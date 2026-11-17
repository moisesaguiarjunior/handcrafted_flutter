import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../example/lib/foam_studies.dart';
import '../example/lib/trim_studies.dart';
import '../example/test/support/fonts.dart';
import 'capture_support.dart';

void main() {
  testWidgets('capture original foam finishes and multicolor cord', (
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
      'build/foam/foam-finishes.png',
      const Size(900, 850),
      const Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cut foam, its own texture',
              style: TextStyle(fontFamily: 'Caveat', fontSize: 42),
            ),
            SizedBox(height: 20),
            FoamStudies(),
          ],
        ),
      ),
    );
    await captureExample(
      tester,
      'build/foam/colored-cord.png',
      const Size(1020, 490),
      const Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Strands, colors, contours',
              style: TextStyle(fontFamily: 'Caveat', fontSize: 42),
            ),
            SizedBox(height: 20),
            TrimStudies(
              width: 16,
              gap: 8,
              multicolor: true,
              followContour: true,
            ),
          ],
        ),
      ),
    );
  });
}
