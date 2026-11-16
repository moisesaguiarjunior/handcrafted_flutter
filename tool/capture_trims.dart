import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../example/lib/trim_studies.dart';
import '../example/test/support/fonts.dart';
import 'capture_support.dart';

void main() {
  testWidgets('capture original cord ribbon and embroidery compositions', (
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
      'build/trims/trim-studies.png',
      const Size(1020, 490),
      const Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cord, ribbon & embroidered lines',
              style: TextStyle(fontFamily: 'Caveat', fontSize: 44),
            ),
            SizedBox(height: 20),
            TrimStudies(),
          ],
        ),
      ),
    );
  });
}
