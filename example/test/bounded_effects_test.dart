import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcrafted_example/bounded_effects.dart';
import 'package:handcrafted_example/main_effects.dart';

import '../../test/support/raster.dart';
import 'support/fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadShowcaseFonts);
  const source = Offset(10, 10), target = Offset(90, 90);

  test(
    'seeded particles stay bounded, repeat and paint nothing at rest',
    () async {
      final a = PourRecipe(), b = PourRecipe(), changed = PourRecipe(seed: 24);
      List<Offset> at(PourRecipe r, double p) =>
          r.droplets(emitter: source, destination: target, progress: p);
      expect(at(a, .4), at(b, .4));
      expect(at(a, .4), isNot(at(changed, .4)));
      for (var frame = 0; frame < 1000; frame++) {
        expect(at(a, (frame % 101) / 100).length, lessThanOrEqualTo(12));
      }
      for (final p in [0.0, 1.0]) {
        final image = await pixels(
          (canvas) => a.paint(
            canvas,
            const Size(100, 100),
            emitter: source,
            destination: target,
            progress: p,
          ),
        );
        expect(image.every((v) => v == 0), isTrue);
      }
      final moving = await pixels(
        (canvas) => a.paint(
          canvas,
          const Size(100, 100),
          emitter: source,
          destination: target,
          progress: .4,
        ),
      );
      expect(moving.any((v) => v != 0), isTrue);
      expect(() => at(a, double.nan), throwsArgumentError);
    },
  );

  BoundedEffectsPainter painter(WidgetTester tester) =>
      tester
              .widget<CustomPaint>(
                find.byWidgetPredicate(
                  (w) => w is CustomPaint && w.painter is BoundedEffectsPainter,
                ),
              )
              .painter!
          as BoundedEffectsPainter;

  testWidgets(
    'emitter follows the vessel and poses retain only one seeded recipe',
    (tester) async {
      Future<void> show(double p, int seed) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                child: BoundedEffectsSample(progress: p, seed: seed),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
      }

      await show(0, 23);
      final firstRecipe = painter(tester).recipe;
      expect(painter(tester).emitter, const Offset(139, 66));
      await show(.5, 23);
      expect(painter(tester).recipe, same(firstRecipe));
      final expected =
          const Offset(95, 90) +
          Offset(
            44 * math.cos(.4) + 24 * math.sin(.4),
            44 * math.sin(.4) - 24 * math.cos(.4),
          );
      expect(painter(tester).emitter, offsetMoreOrLessEquals(expected));
      await show(.5, 24);
      expect(painter(tester).recipe, isNot(same(firstRecipe)));
      expect(tester.binding.hasScheduledFrame, isFalse);
    },
  );

  testWidgets('playback is finite and reduced motion rests immediately', (
    tester,
  ) async {
    for (final reduced in [false, true]) {
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: reduced),
            child: child!,
          ),
          home: const Scaffold(body: BoundedEffectsPlayground()),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Play pour'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(painter(tester).progress, reduced ? 1 : lessThan(1));
      await tester.pumpAndSettle();
      expect(painter(tester).progress, 1);
      expect(tester.binding.hasScheduledFrame, isFalse);
      await tester.pumpWidget(const SizedBox());
    }
  });

  for (final scale in [1.0, 1.5, 2.0, 2.5]) {
    testWidgets('effect controls flow at 320px and scale $scale', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(320, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(const BoundedEffectsApp());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Play pour'));
      await tester.tap(find.text('Play pour'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(tester.binding.hasScheduledFrame, isFalse);
    });
  }
}
