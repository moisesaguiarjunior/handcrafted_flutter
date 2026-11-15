import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcrafted_example/main_strokes.dart';

void main() {
  testWidgets(
    'native controls change marks, scrub and complete without idle ticks',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1100, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final semantics = tester.ensureSemantics();
      // Dispose before Flutter's end-of-test semantics verification.
      await tester.pumpWidget(const StrokePlaygroundApp());
      await tester.pumpAndSettle();
      expect(find.text('Drawn 62%'), findsOneWidget);
      expect(tester.binding.transientCallbackCount, 0);
      final swatches = find.descendant(
        of: find.byType(StrokeComparison),
        matching: find.byType(CustomPaint),
      );
      expect(swatches, findsNWidgets(9));
      for (final swatch in swatches.evaluate()) {
        expect(
          tester.getSize(find.byWidget(swatch.widget)).width,
          greaterThan(36),
        );
      }
      await tester.tap(find.text('Pen').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Brush').last);
      await tester.pumpAndSettle();
      expect(find.text('Brush on paper'), findsOneWidget);
      expect(find.text('Width 12.0'), findsOneWidget);
      final progress = tester.widget<Slider>(
        find.byKey(const ValueKey('stroke-progress')),
      );
      progress.onChanged!(.25);
      await tester.pumpAndSettle();
      expect(find.text('Drawn 25%'), findsOneWidget);
      expect(
        find.bySemanticsLabel(
          RegExp('Curved dashed brush line, 25 percent drawn'),
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('Complete line'));
      await tester.pumpAndSettle();
      expect(find.text('Drawn 100%'), findsOneWidget);
      await tester.tap(find.text('Draw again'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Drawn 100%'), findsNothing);
      await tester.pumpAndSettle();
      expect(find.text('Drawn 100%'), findsOneWidget);
      expect(tester.binding.transientCallbackCount, 0);
      expect(tester.takeException(), isNull);
      semantics.dispose();
    },
  );

  testWidgets('automatic drawing respects reduced motion', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await tester.pumpWidget(const StrokePlaygroundApp());
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Draw again'));
    await tester.tap(find.text('Draw again'));
    await tester.pump();
    expect(find.text('Drawn 100%'), findsOneWidget);
    expect(tester.binding.transientCallbackCount, 0);
  });

  for (final scale in [1.0, 1.5, 2.5]) {
    testWidgets('narrow drawing controls flow at text scale $scale', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(320, 844));
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      addTearDown(() => tester.binding.setSurfaceSize(null));
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(const StrokePlaygroundApp());
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Complete line'));
      await tester.tap(find.text('Complete line'));
      await tester.pumpAndSettle();
      expect(find.text('Drawn 100%'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
