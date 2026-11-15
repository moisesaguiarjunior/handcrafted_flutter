import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcrafted_example/main_showcase.dart';

void main() {
  testWidgets(
    'use-case actions, replay and still pose work without idle ticks',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1100, 850));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(const ShowcaseApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Open collection'));
      await tester.pumpAndSettle();
      expect(find.text('Demo actions: 1'), findsOneWidget);
      await tester.tap(find.text('Hanging pieces'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Felt'));
      await tester.pumpAndSettle();
      expect(find.text('Demo actions: 2'), findsOneWidget);
      await tester.tap(find.text('Kite tail'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Still pose'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Replay entrance'));
      await tester.pumpAndSettle();
      expect(tester.binding.transientCallbackCount, 0);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('narrow gallery flows and retains a scrollable artwork stage', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 850));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const ShowcaseApp());
    await tester.pumpAndSettle();
    expect(find.text('Keepsake card'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  for (final scale in [1.0, 1.2, 1.3, 1.4, 1.5, 1.51, 2.5]) {
    testWidgets('card fits with real fonts at text scale $scale', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      addTearDown(() => tester.binding.setSurfaceSize(null));
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(const ShowcaseApp());
      await tester.pumpAndSettle();
      expect(find.text('Open collection'), findsOneWidget);
      expect(tester.takeException(), isNull);
      if (scale == 1) {
        expect(
          tester.getSize(find.byKey(const ValueKey('paper-card'))),
          const Size(340, 250),
        );
      }
    });
  }
}
