import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';
import 'package:handcrafted_example/main_atlas.dart';
import 'package:handcrafted_example/motion_studies.dart';
import 'package:handcrafted_example/showcase_theme.dart';

void main() {
  testWidgets(
    'centered relief shading stays with native glyphs instead of ghosting at the left',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 200));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      const key = ValueKey('lettering-probe');
      await tester.pumpWidget(
        MaterialApp(
          theme: showcaseTheme(),
          home: Scaffold(
            body: Center(
              child: RepaintBoundary(
                key: key,
                child: const SizedBox(
                  width: 300,
                  height: 70,
                  child: CraftReliefText(
                    'Bloom',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 38,
                      color: Color(0xFF36566A),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(key),
      );
      final image = await tester.runAsync(() async {
        final bitmap = await boundary.toImage(pixelRatio: 1);
        try {
          return List<int>.of(
            (await bitmap.toByteData(
              format: ui.ImageByteFormat.rawRgba,
            ))!.buffer.asUint8List(),
          );
        } finally {
          bitmap.dispose();
        }
      });
      var centerInk = 0;
      for (var y = 0; y < 70; y++) {
        for (var x = 0; x < 70; x++) {
          expect(image![(y * 300 + x) * 4 + 3], 0);
        }
        for (var x = 90; x < 210; x++) {
          centerInk += image![(y * 300 + x) * 4 + 3];
        }
      }
      expect(centerInk, greaterThan(0));
      // The inset mask must contribute beyond the same native directional shadows.
      final nativeStyle = tester.widget<Text>(find.text('Bloom')).style;
      await tester.pumpWidget(
        MaterialApp(
          theme: showcaseTheme(),
          home: Scaffold(
            body: Center(
              child: RepaintBoundary(
                key: key,
                child: SizedBox(
                  width: 300,
                  height: 70,
                  child: Text(
                    'Bloom',
                    textAlign: TextAlign.center,
                    style: nativeStyle,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      final plainBoundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(key),
      );
      final native = await tester.runAsync(() async {
        final bitmap = await plainBoundary.toImage(pixelRatio: 1);
        try {
          return List<int>.of(
            (await bitmap.toByteData(
              format: ui.ImageByteFormat.rawRgba,
            ))!.buffer.asUint8List(),
          );
        } finally {
          bitmap.dispose();
        }
      });
      expect(image, isNot(native));
    },
  );

  testWidgets(
    'atlas exposes materials, impressions, pigment and independent motion controls',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1100, 950));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(const MaterialAtlasApp());
      await tester.pumpAndSettle();
      expect(find.text('Indigo twill'), findsOneWidget);
      expect(find.text('Honey wood'), findsOneWidget);
      await tester.tap(find.text('Impressions'));
      await tester.pumpAndSettle();
      expect(find.text('Sea'), findsOneWidget);
      await tester.tap(find.text('Raised impression'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reverse impression light'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Watercolor'));
      await tester.pumpAndSettle();
      expect(find.text('Paper left untouched'), findsOneWidget);
      tester
          .widget<Slider>(find.byKey(const ValueKey('wash-opacity')))
          .onChanged!(.3);
      await tester.pumpAndSettle();
      expect(find.text('Pigment 30%'), findsOneWidget);
      await tester.tap(find.text('Motion'));
      await tester.pumpAndSettle();
      tester
          .widget<Slider>(find.byKey(const ValueKey('motion-body')))
          .onChanged!(.2);
      tester
          .widget<Slider>(find.byKey(const ValueKey('motion-detail')))
          .onChanged!(.7);
      await tester.pumpAndSettle();
      expect(find.text('Body 20%'), findsOneWidget);
      expect(find.text('Tail 70%'), findsOneWidget);
      await tester.ensureVisible(find.text('Balloon'));
      await tester.tap(find.text('Balloon'));
      await tester.pumpAndSettle();
      expect(find.text('Tether 70%'), findsOneWidget);
      await tester.ensureVisible(find.text('Play motion'));
      await tester.tap(find.text('Play motion'));
      await tester.pumpAndSettle();
      expect(find.text('Body 100%'), findsOneWidget);
      expect(tester.binding.transientCallbackCount, 0);
      await tester.ensureVisible(find.text('Materials'));
      await tester.tap(find.text('Materials'));
      await tester.pumpAndSettle();
      expect(tester.binding.transientCallbackCount, 0);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('kite body and tail produce independent visible changes', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(440, 340));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    Future<List<int>> render(double body, double detail) async {
      const key = ValueKey('motion-probe');
      await tester.pumpWidget(
        MaterialApp(
          theme: showcaseTheme(),
          home: RepaintBoundary(
            key: key,
            child: MotionSample(
              subject: MotionSubject.kite,
              bodyProgress: body,
              detailProgress: detail,
            ),
          ),
        ),
      );
      await tester.pump();
      final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(key),
      );
      final result = await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 1);
        try {
          return List<int>.of(
            (await image.toByteData(
              format: ui.ImageByteFormat.rawRgba,
            ))!.buffer.asUint8List(),
          );
        } finally {
          image.dispose();
        }
      });
      return result!;
    }

    final still = await render(1, 1);
    final bodyOnly = await render(.37, 1);
    final tailOnly = await render(1, .37);
    expect(bodyOnly, isNot(still));
    expect(tailOnly, isNot(still));
    expect(bodyOnly, isNot(tailOnly));
    expect(tailOnly, await render(1, .37));
    // The sail is unchanged when only the tail deforms.
    for (var y = 45; y < 120; y++) {
      final start = (y * 440 + 250) * 4;
      expect(
        tailOnly.sublist(start, start + 60 * 4),
        still.sublist(start, start + 60 * 4),
      );
    }
    expect(studySway(0).rotation, 0);
    expect(studySway(1).translation, Offset.zero);
  });

  testWidgets('motion settles immediately under reduced motion', (
    tester,
  ) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: const MotionPlayground()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Play motion'));
    await tester.tap(find.text('Play motion'));
    await tester.pump();
    expect(find.text('Body 100%'), findsOneWidget);
    expect(find.text('Tail 100%'), findsOneWidget);
    expect(tester.binding.transientCallbackCount, 0);
  });

  for (final scale in [1.0, 1.5, 2.5]) {
    testWidgets('all atlas sections flow at 320px with text scale $scale', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(320, 844));
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      addTearDown(() => tester.binding.setSurfaceSize(null));
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(const MaterialAtlasApp());
      await tester.pumpAndSettle();
      for (final section in [
        'Impressions',
        'Watercolor',
        'Motion',
        'Materials',
      ]) {
        await tester.ensureVisible(find.text(section));
        await tester.tap(find.text(section));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    });
  }
}
