import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

import 'package:handcrafted_example/main_trims.dart' as app;
import 'package:handcrafted_example/trim_studies.dart';
import 'support/fonts.dart';

void main() {
  testWidgets(
    'trim controls and real-font narrow enlarged layout remain usable',
    (tester) async {
      await tester.runAsync(loadShowcaseFonts);
      tester.view.physicalSize = const Size(320, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      app.main();
      await tester.pumpAndSettle();
      expect(
        tester.getSize(find.byType(CraftSurface).first).width,
        greaterThan(200),
      );
      await tester.drag(find.byType(Slider).first, const Offset(40, 0));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TrimStudies>(find.byType(TrimStudies)).width,
        greaterThan(10),
      );
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(2.5)),
            child: child!,
          ),
          home: const Scaffold(
            body: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: TrimPlayground(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
