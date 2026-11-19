import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';
import 'package:handcrafted_example/main_budget.dart';
import 'package:handcrafted_example/rendering_budget.dart';

import 'support/fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadShowcaseFonts);

  test('timing window excludes old batches/warmup and bounds storage', () {
    ui.FrameTiming frame(int i) => ui.FrameTiming(
      vsyncStart: i * 20000,
      buildStart: i * 20000 + 1,
      buildFinish: i * 20000 + 5001,
      rasterStart: i * 20000 + 5001,
      rasterFinish: i * 20000 + 7001,
      rasterFinishWallTime: i * 20000 + 7001,
    );
    final window = BudgetTimingWindow();
    window.record([frame(1)]);
    expect(window.count, 0);
    window.start(afterVsync: 200000);
    window.record(List.generate(11, frame));
    expect(window.count, 0);
    window.record(List.generate(12, (i) => frame(i + 11)));
    expect(window.count, 0);
    window.record(List.generate(400, (i) => frame(i + 23)));
    expect(window.count, 120);
    expect(window.active, isFalse);
    expect(window.report(), contains('5.00 / 5.00 ms'));
    expect(window.report(), contains('2.00 / 2.00 ms'));
    window.start();
    window.stop();
    window.record([frame(500)]);
    expect(window.count, 0);
    expect(window.report(), contains('No post-warmup engine timings'));
  });

  test(
    'a delayed prior frame cannot consume warmup and expired frames stay out',
    () {
      ui.FrameTiming frame(int vsync, {int uiTime = 1000}) => ui.FrameTiming(
        vsyncStart: vsync,
        buildStart: vsync + 1,
        buildFinish: vsync + 1 + uiTime,
        rasterStart: vsync + 1 + uiTime,
        rasterFinish: vsync + 2001 + uiTime,
        rasterFinishWallTime: vsync + 2001 + uiTime,
      );
      final window = BudgetTimingWindow()..start(afterVsync: 1000000);
      window.record([frame(1000000, uiTime: 900000)]);
      window.record(List.generate(12, (i) => frame(1100000 + i * 20000)));
      expect(window.count, 0);
      window.record([frame(1400000)]);
      expect(window.count, 1);
      window.record([frame(12000000, uiTime: 900000)]);
      expect(window.count, 1);
      expect(window.active, isFalse);
      expect(window.report(), contains('UI p50/p95: 1.00 / 1.00 ms'));
    },
  );

  void paintOwner(BudgetResources resources, int index) {
    final recorder = ui.PictureRecorder();
    resources.paint(
      index,
      Canvas(recorder),
      Path()..addRect(const Rect.fromLTWH(0, 0, 20, 20)),
      CraftMaterial.paper,
    );
    recorder.endRecording().dispose();
  }

  test(
    'equivalent recipes retain owners and invalidation disposes only their scope',
    () {
      final a = BudgetResources(count: 6), b = BudgetResources(count: 1);
      for (var i = 0; i < 6; i++) {
        paintOwner(a, i);
      }
      expect(a.requestedKinds, 6);
      a.configure(count: 6, seed: 23);
      expect((a.created, a.disposed, a.live), (6, 0, 6));
      a.configure(count: 3, seed: 23);
      expect((a.created, a.disposed, a.live), (6, 3, 3));
      expect(() => a.configure(count: 25, seed: 99), throwsArgumentError);
      expect((a.created, a.disposed, a.live), (6, 3, 3));
      a.configure(count: 3, seed: 24);
      expect((a.created, a.disposed, a.live), (9, 6, 3));
      expect(a.requestedKinds, 0);
      a.dispose();
      a.dispose();
      expect((a.created, a.disposed, a.live), (9, 9, 0));
      expect(() => paintOwner(a, 0), throwsStateError);
      paintOwner(b, 0);
      expect((b.created, b.disposed, b.live), (1, 0, 1));
      b.dispose();
    },
  );

  testWidgets('in-place seed changes invalidate the actual material painter', (
    tester,
  ) async {
    final resources = BudgetResources(count: 1);
    Future<CustomPainter> show() async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RenderingBudgetScene(resources: resources, progress: .3),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return tester
          .widget<CustomPaint>(find.byKey(const ValueKey('budget-material-0')))
          .painter!;
    }

    final before = await show();
    resources.configure(count: 1, seed: 23);
    expect((await show()).shouldRepaint(before), isFalse);
    resources.configure(count: 1, seed: 24);
    expect((await show()).shouldRepaint(before), isTrue);
    await tester.pumpWidget(const SizedBox());
    resources.dispose();
  });

  testWidgets(
    'unmounting one consumer preserves the other mounted resource scope',
    (tester) async {
      final a = BudgetResources(count: 1), b = BudgetResources(count: 1);
      Future<void> show(bool first) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    if (first)
                      RenderingBudgetScene(
                        key: const ValueKey('scope-a'),
                        resources: a,
                        progress: .3,
                      ),
                    RenderingBudgetScene(
                      key: const ValueKey('scope-b'),
                      resources: b,
                      progress: .6,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
      }

      await show(true);
      final element = tester.element(find.byKey(const ValueKey('scope-b')));
      await show(false);
      a.dispose();
      expect(
        tester.element(find.byKey(const ValueKey('scope-b'))),
        same(element),
      );
      await show(false);
      expect((b.created, b.disposed, b.live), (1, 0, 1));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      b.dispose();
    },
  );

  testWidgets(
    'measurement run is finite and produces no fabricated test timings',
    (tester) async {
      await tester.pumpWidget(const RenderingBudgetApp());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Run 8 seconds'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 10));
      await tester.pumpAndSettle();
      expect(tester.binding.hasScheduledFrame, isFalse);
      await tester.tap(find.text('Stop and report'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('No post-warmup engine timings'),
        findsOneWidget,
      );
      expect(
        find.textContaining('debug (not performance evidence)'),
        findsOneWidget,
      );
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
      expect(tester.binding.hasScheduledFrame, isFalse);
    },
  );

  for (final scale in [1.0, 1.5, 2.0, 2.5]) {
    testWidgets('budget controls flow at 320px and scale $scale', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(320, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(const RenderingBudgetApp());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Stop and report'));
      await tester.tap(find.text('Stop and report'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
