import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';
import 'package:handcrafted_example/imported_layers.dart';
import 'package:handcrafted_example/main_scenes.dart';

import 'support/fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadShowcaseFonts);
  test('source hinge is converted once at two effective sizes', () {
    for (final scale in [1.0, .5]) {
      final size = Size(240 * scale, 120 * scale);
      final pose = PartPose(rotation: math.pi / 2);
      final part = CraftImagePart(
        key: const ValueKey('mapping-probe'),
        image: const AssetImage(layerAsset),
        sourceSize: layerSourceSize,
        sourceRect: lidSourceRect,
        sourceHinge: lidSourceHinge,
        rect: Offset.zero & size,
        pose: pose,
      );
      expect(
        part.mapSourcePoint(const Offset(316, 32)),
        offsetMoreOrLessEquals(Offset(16, 12) * scale),
      );
      expect(
        part.mapSourcePoint(const Offset(336, 32)),
        offsetMoreOrLessEquals(Offset(16, 32) * scale),
      );
    }
    expect(
      () => const CraftImagePart(
        key: ValueKey('invalid-crop'),
        image: AssetImage(layerAsset),
        sourceSize: Size(10, 10),
        sourceRect: Rect.fromLTWH(8, 0, 4, 4),
        rect: Rect.fromLTWH(0, 0, 4, 4),
      ).mapSourcePoint(Offset.zero),
      throwsArgumentError,
    );
  });

  testWidgets('imported pixels and hit shape share the transformed crop', (
    tester,
  ) async {
    var taps = 0;
    for (final width in [400.0, 250.0]) {
      for (final p in [0.0, .5, 1.0, .3, 0.0]) {
        final sceneKey = GlobalKey();
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Align(
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: width,
                  child: ImportedComposition(
                    key: sceneKey,
                    progress: p,
                    onLidPressed: () => taps++,
                    onInspect: () {},
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final scale = width / 400;
        final origin =
            tester.getTopLeft(find.byKey(sceneKey)) +
            const Offset(54, 218) * scale;
        Offset mapped(Offset local) {
          final d = (local - const Offset(16, 12)) * scale;
          final angle = -1.15 * p;
          return origin +
              const Offset(16, 12) * scale +
              Offset(
                d.dx * math.cos(angle) - d.dy * math.sin(angle),
                d.dx * math.sin(angle) + d.dy * math.cos(angle),
              );
        }

        final before = taps;
        await tester.tapAt(mapped(const Offset(120, 65)));
        await tester.pumpAndSettle();
        expect(taps, before + 1);
        await tester.tapAt(mapped(const Offset(1, 1)));
        await tester.pumpAndSettle();
        expect(
          taps,
          before + 1,
          reason: 'Transparent corner is outside the supplied hit shape',
        );
        final anchor = tester.getCenter(
          find.byKey(const ValueKey('lid-anchor')),
        );
        expect(anchor, offsetMoreOrLessEquals(mapped(const Offset(220, 55))));
        expect(tester.binding.hasScheduledFrame, isFalse);
      }
    }
  });

  testWidgets('covered native action leaves hit testing and semantics', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    var inspected = 0;
    Future<void> show(double p) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              child: ImportedComposition(
                progress: p,
                onLidPressed: () {},
                onInspect: () => inspected++,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    await show(1);
    expect(find.byTooltip('Inspect the specimen'), findsOneWidget);
    final rect = tester.getRect(find.byKey(const ValueKey('inspect-specimen')));
    expect(rect.width, greaterThanOrEqualTo(48));
    final inspectFocus = Focus.of(
      tester.element(find.byIcon(Icons.local_florist_outlined)),
    );
    inspectFocus.requestFocus();
    await tester.pump();
    expect(inspectFocus.hasFocus, isTrue);
    await tester.tap(find.byKey(const ValueKey('inspect-specimen')));
    await tester.pumpAndSettle();
    expect(inspected, 1);
    await show(0);
    expect(inspectFocus.hasFocus, isFalse);
    expect(find.byTooltip('Inspect the specimen'), findsNothing);
    expect(find.bySemanticsLabel('Inspect the specimen'), findsNothing);
    await tester.tapAt(rect.center);
    await tester.pumpAndSettle();
    expect(inspected, 1);
    semantics.dispose();
  });

  for (final scale in [1.0, 1.5, 2.0, 2.5]) {
    testWidgets('imported scene controls flow at 320px and scale $scale', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(320, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(const SceneRecipesApp());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Open lid'));
      await tester.tap(find.text('Open lid'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byTooltip('Inspect the specimen'), findsOneWidget);
    });
  }
}
