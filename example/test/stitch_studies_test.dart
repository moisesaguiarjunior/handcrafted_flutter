import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/main_stitches.dart' as app;
import '../lib/stitch_studies.dart';
import 'support/fonts.dart';

void main() {
  testWidgets(
    'thread controls change geometry at narrow enlarged native layout',
    (tester) async {
      await tester.runAsync(loadShowcaseFonts);
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 1000);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      app.main();
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byType(Slider).first);
      await tester.drag(find.byType(Slider).first, const Offset(40, 0));
      await tester.pumpAndSettle();
      expect(
        tester.widget<StitchStudies>(find.byType(StitchStudies)).pitch,
        greaterThan(16),
      );
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(2.5)),
            child: child!,
          ),
          home: const Scaffold(
            body: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: StitchPlayground(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byType(Slider).last);
      await tester.drag(find.byType(Slider).last, const Offset(-40, 0));
      await tester.pumpAndSettle();
      expect(
        tester.widget<StitchStudies>(find.byType(StitchStudies)).compression,
        lessThan(.7),
      );
      expect(tester.takeException(), isNull);
      expect(tester.binding.transientCallbackCount, 0);
    },
  );
}
