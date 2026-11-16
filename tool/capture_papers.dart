import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../example/lib/paper_studies.dart';
import '../example/test/support/fonts.dart';
import 'capture_support.dart';

void main() {
  testWidgets('capture paper-stock recipes with torn edges', (tester) async {
    await tester.runAsync(
      () => loadShowcaseFonts(directory: 'example/assets/fonts'),
    );
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await captureExample(
      tester,
      'build/papers/paper-recipes.png',
      const Size(1100, 800),
      const Padding(
        padding: EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A drawer full of paper',
              style: TextStyle(fontFamily: 'Caveat', fontSize: 46),
            ),
            SizedBox(height: 20),
            PaperStudiesSheet(),
          ],
        ),
      ),
    );
    await captureExample(
      tester,
      'build/papers/paper-edges.png',
      const Size(800, 490),
      const Padding(
        padding: EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'One paper, four edges',
              style: TextStyle(fontFamily: 'Caveat', fontSize: 44),
            ),
            SizedBox(height: 16),
            PaperEdgeStudiesSheet(),
          ],
        ),
      ),
    );
  });
}
