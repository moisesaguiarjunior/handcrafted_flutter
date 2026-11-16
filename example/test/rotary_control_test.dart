import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';
import 'package:handcrafted_example/main_dial.dart';
import 'package:handcrafted_example/rotary_control.dart';

import 'support/fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadShowcaseFonts);

  double angle(WidgetTester tester) => tester
      .widget<CraftPart>(find.byKey(const ValueKey('rotary-disc')))
      .pose
      .rotation;

  testWidgets(
    'retargeting starts at current pose and retains native control identity',
    (tester) async {
      await tester.pumpWidget(const RotaryExampleApp());
      await tester.pumpAndSettle();
      final sliderElement = tester.element(
        find.byKey(const ValueKey('rotary-position')),
      );
      await tester.tap(find.byTooltip('Next position'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      final moving = angle(tester);
      await tester.tap(find.byTooltip('Next position'));
      await tester.pump();
      expect(angle(tester), closeTo(moving, 1e-9));
      expect(
        tester.element(find.byKey(const ValueKey('rotary-position'))),
        same(sliderElement),
      );
      await tester.pumpAndSettle();
      expect(angle(tester), greaterThan(moving));
      expect(find.text('No position applied.'), findsOneWidget);
      await tester.tap(find.text('Apply position'));
      await tester.pumpAndSettle();
      expect(find.text('Applied position 2.'), findsOneWidget);
      expect(tester.binding.hasScheduledFrame, isFalse);
    },
  );

  testWidgets('native slider keyboard steps without wrapping', (tester) async {
    await tester.pumpWidget(const RotaryExampleApp());
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(find.text('Position 1 of 12'), findsOneWidget);
    for (var i = 0; i < 20; i++) {
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pump();
    }
    await tester.pumpAndSettle();
    expect(find.text('Position 12 of 12'), findsOneWidget);
    final end = angle(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();
    expect(angle(tester), end);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pumpAndSettle();
    expect(find.text('Position 11 of 12'), findsOneWidget);
  });

  testWidgets('reduced motion settles and inactive host pauses the pose', (
    tester,
  ) async {
    var active = true;
    var reduced = false;
    late StateSetter update;
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
              child: Scaffold(body: RotaryControlPlayground(active: active)),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Next position'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 70));
    update(() => active = false);
    await tester.pumpAndSettle();
    final paused = angle(tester);
    await tester.pump(const Duration(seconds: 2));
    expect(angle(tester), paused);
    update(() => reduced = true);
    await tester.pumpAndSettle();
    expect(angle(tester), greaterThan(paused));
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  for (final scale in [1.0, 1.5, 2.0, 2.5]) {
    testWidgets('native dial controls flow at 320px and scale $scale', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(320, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(const RotaryExampleApp());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Apply position'));
      await tester.tap(find.text('Apply position'));
      await tester.pumpAndSettle();
      expect(find.text('Applied position 0.'), findsOneWidget);
    });
  }
}
