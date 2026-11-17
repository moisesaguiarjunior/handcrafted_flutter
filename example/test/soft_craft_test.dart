import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcrafted_example/soft_craft_studies.dart';

import 'support/fonts.dart';

void main() {
  testWidgets(
    'soft craft controls change the shared art and reflow with large text',
    (tester) async {
      await tester.runAsync(loadShowcaseFonts);
      tester.view.physicalSize = const Size(320, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
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
              child: SoftCraftPlayground(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      for (final key in ['soft-irregularity', 'soft-pucker']) {
        final finder = find.byKey(ValueKey(key));
        await tester.ensureVisible(finder);
        final before = tester.widget<SoftCraftSamples>(
          find.byType(SoftCraftSamples),
        );
        await tester.drag(finder, const Offset(-70, 0));
        await tester.pumpAndSettle();
        final after = tester.widget<SoftCraftSamples>(
          find.byType(SoftCraftSamples),
        );
        expect(
          key == 'soft-pucker' ? after.pucker : after.irregularity,
          lessThan(key == 'soft-pucker' ? before.pucker : before.irregularity),
        );
      }
      final toggle = find.byType(SwitchListTile);
      await tester.ensureVisible(toggle);
      await tester.tap(toggle);
      await tester.pumpAndSettle();
      expect(
        tester.widget<SoftCraftSamples>(find.byType(SoftCraftSamples)).satin,
        isFalse,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
