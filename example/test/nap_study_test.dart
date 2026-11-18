import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';
import 'package:handcrafted_example/nap_studies.dart';

import 'support/fonts.dart';

void main() {
  testWidgets(
    'contrast reuses fibers while direction changes prepared deposits',
    (tester) async {
      Widget app({double contrast = .8, double direction = -.4}) => MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: NapMaterialSamples(contrast: contrast, direction: direction),
          ),
        ),
      );
      CraftNap nap() =>
          (tester
                          .widget<CustomPaint>(
                            find.byKey(const ValueKey('nap-specimen-1-2')),
                          )
                          .painter
                      as dynamic)
                  .nap
              as CraftNap;
      await tester.pumpWidget(app());
      final before = nap();
      await tester.pumpWidget(app(contrast: .1));
      expect(identical(nap(), before), isTrue);
      await tester.pumpWidget(app(direction: 1.2));
      expect(identical(nap(), before), isFalse);
      await tester.pumpWidget(const SizedBox());
      expect(tester.binding.transientCallbackCount, 0);
    },
  );
  for (final width in [320.0, 390.0, 428.0]) {
    testWidgets('native nap controls at $width with enlarged text', (
      tester,
    ) async {
      await tester.runAsync(loadShowcaseFonts);
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 900);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      final handle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(2.5)),
              child: child!,
            ),
            home: const Scaffold(
              body: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: NapPlayground(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        for (final key in [
          'nap-scale',
          'nap-density',
          'nap-direction',
          'nap-contrast',
        ]) {
          final finder = find.byKey(ValueKey(key));
          await tester.ensureVisible(finder);
          final old = tester.widget<Slider>(finder).value;
          await tester.tapAt(
            tester.getRect(finder).centerRight - const Offset(25, 0),
          );
          await tester.pumpAndSettle();
          expect(tester.widget<Slider>(finder).value, greaterThan(old));
          final data = tester.getSemantics(finder).getSemanticsData();
          expect(data.label, isNotEmpty);
          expect(data.hasAction(SemanticsAction.increase), isTrue);
        }
        await tester.ensureVisible(find.byType(LayeredFoamSample));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        expect(tester.binding.transientCallbackCount, 0);
      } finally {
        handle.dispose();
      }
    });
  }
}
