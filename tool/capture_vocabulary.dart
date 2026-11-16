import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../example/lib/material_vocabulary.dart';
import '../example/test/support/fonts.dart';
import 'capture_support.dart';

void main() {
  testWidgets(
    'capture actual host-owned material themes over native controls',
    (tester) async {
      await tester.runAsync(
        () => loadShowcaseFonts(directory: 'example/assets/fonts'),
      );
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      await captureExample(
        tester,
        'doc/screenshots/material-vocabulary.png',
        const Size(1440, 800),
        const Padding(
          padding: EdgeInsets.all(32),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: MaterialVocabularyStudy()),
              SizedBox(width: 32),
              Expanded(child: MaterialVocabularyStudy(initialCloth: true)),
            ],
          ),
        ),
      );
    },
  );
}
