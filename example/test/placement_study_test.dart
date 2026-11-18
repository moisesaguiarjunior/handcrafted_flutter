import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcrafted_example/placement_studies.dart';

import 'support/fonts.dart';

void main() {
  testWidgets('collapsed decorative areas do not attempt invalid fits', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              SizedBox(width: 12, child: StrokeClearanceStudy()),
              SizedBox(width: 0, child: VisibleFitComparison()),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
  for (final width in [320.0, 390.0, 428.0]) {
    testWidgets(
      'native placed selection at $width with large text and pose seeking',
      (tester) async {
        await tester.runAsync(loadShowcaseFonts);
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = Size(width, 850);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.view.resetPhysicalSize);
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
                child: VisibleFitPlayground(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final checkbox = find.byType(Checkbox).first;
        await tester.ensureVisible(checkbox);
        expect(tester.getRect(checkbox).width, greaterThanOrEqualTo(48));
        await tester.tap(checkbox);
        await tester.pumpAndSettle();
        expect(tester.widget<Checkbox>(checkbox).value, isTrue);
        final slider = find.byKey(const ValueKey('placement-progress'));
        await tester.ensureVisible(slider);
        await tester.tapAt(
          tester.getRect(slider).centerRight - const Offset(32, 0),
        );
        await tester.pumpAndSettle();
        expect(tester.widget<Slider>(slider).value, greaterThan(.5));
        expect(tester.widget<Checkbox>(checkbox).value, isTrue);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
        expect(tester.binding.transientCallbackCount, 0);
      },
    );
  }
}
