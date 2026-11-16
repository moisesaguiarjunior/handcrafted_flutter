import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

import '../lib/pendulum_studies.dart';
import 'support/fonts.dart';

void main() {
  testWidgets('manual physics keeps native input and has no idle frames', (
    tester,
  ) async {
    await tester.runAsync(loadShowcaseFonts);
    var actions = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PendulumStudies(
            elapsed: const Duration(seconds: 1),
            onTap: () => actions++,
          ),
        ),
      ),
    );
    final part = find.byKey(const ValueKey('physics-realistic'));
    final button = find.descendant(of: part, matching: find.byType(TextButton));
    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(actions, 1);
    final semantics = tester.ensureSemantics();
    expect(
      tester.getSemantics(button),
      matchesSemantics(
        label: 'Tap',
        isButton: true,
        hasTapAction: true,
        hasFocusAction: true,
        isEnabled: true,
        hasEnabledState: true,
        isFocusable: true,
      ),
    );
    semantics.dispose();
    expect(tester.binding.transientCallbackCount, 0);
  });
  testWidgets(
    'real-font narrow enlarged controls respect supplied reduced motion',
    (tester) async {
      await tester.runAsync(loadShowcaseFonts);
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 1400);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              disableAnimations: true,
              textScaler: const TextScaler.linear(2.5),
            ),
            child: child!,
          ),
          home: const Scaffold(
            body: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: PendulumPlayground(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final before = tester
          .widget<CraftPart>(find.byKey(const ValueKey('physics-realistic')))
          .pose
          .rotation;
      await tester.ensureVisible(find.byType(Slider).first);
      await tester.drag(find.byType(Slider).first, const Offset(50, 0));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<CraftPart>(find.byKey(const ValueKey('physics-realistic')))
            .pose
            .rotation,
        before,
      );
      expect(tester.takeException(), isNull);
      expect(tester.binding.transientCallbackCount, 0);
    },
  );
}
