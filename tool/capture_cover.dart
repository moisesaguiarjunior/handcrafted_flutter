import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../example/lib/cover_studies.dart';
import '../example/test/support/fonts.dart';
import 'capture_support.dart';

void main() {
  testWidgets('capture actual material cover and distinct relief objects', (
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
      'build/cover/material-cover.png',
      const Size(1200, 750),
      MaterialCover(onPressed: () {}),
    );
    await captureExample(
      tester,
      'build/cover/relief-objects.png',
      const Size(1100, 560),
      const Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Relief, with a different character',
              style: TextStyle(fontFamily: 'Caveat', fontSize: 44),
            ),
            SizedBox(height: 20),
            ReliefObjectsSheet(),
          ],
        ),
      ),
    );
  });
}
