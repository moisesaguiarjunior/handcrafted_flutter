import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../example/lib/seam_studies.dart';
import '../example/test/support/fonts.dart';
import 'capture_support.dart';

void main() {
  testWidgets('capture contour-following seams at explicit parameters', (
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
      'build/seams/contour-seams.png',
      const Size(1100, 430),
      const Padding(
        padding: EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Seams that follow the cut',
              style: TextStyle(fontFamily: 'Caveat', fontSize: 46),
            ),
            SizedBox(height: 20),
            SeamStudiesSheet(),
          ],
        ),
      ),
    );
  });
}
