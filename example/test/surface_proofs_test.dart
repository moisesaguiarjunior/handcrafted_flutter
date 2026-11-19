import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcrafted_example/main_surfaces.dart';
import 'package:handcrafted_example/surface_proofs.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

import 'support/surface_raster.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const viewport = Rect.fromLTWH(73.25, 417.5, 320, 256);
  for (final recipe in SurfaceRecipe.values) {
    for (final ratio in [1.0, 3.0]) {
      test(
        '$recipe retains world phase at ${ratio}x across clipped strips',
        () async {
          final scene = SurfaceProof(recipe: recipe);
          final restarted = SurfaceProof(recipe: recipe, domain: viewport);
          try {
            final whole = await rasterSurface(scene, viewport, ratio: ratio);
            final scrolled = await rasterSurface(
              scene,
              viewport.shift(const Offset(0, 64)),
              ratio: ratio,
            );
            expect(
              scrolled,
              isNot(whole),
              reason: 'Scrolling must reveal a different part of the source',
            );
            final strips = await rasterSurface(
              scene,
              viewport,
              ratio: ratio,
              stripHeight: 64,
            );
            var maximum = 0, changed = 0, total = 0;
            for (var i = 0; i < whole.length; i++) {
              final difference = (whole[i] - strips[i]).abs();
              if (difference > maximum) maximum = difference;
              if (difference > 0) changed++;
              total += difference;
            }
            debugPrint(
              '$recipe ratio=$ratio max=$maximum changed=$changed mean=${total / whole.length}',
            );
            // Measured raster clipping is not pixel-identical. Bound both isolated
            // edge rounding and scene-wide error; never call this equivalence.
            expect(maximum, lessThanOrEqualTo(10));
            expect(total / whole.length, lessThan(.2));
            final wrong = await rasterSurface(
              restarted,
              viewport,
              ratio: ratio,
            );
            expect(
              wrong,
              isNot(whole),
              reason:
                  'Changing the source bounds must expose phase/geometry changes',
            );
          } finally {
            scene.dispose();
            restarted.dispose();
          }
        },
      );
    }
  }

  test('seed and phase are independent stable print inputs', () async {
    final scenes = [
      SurfaceProof(recipe: SurfaceRecipe.diamonds),
      SurfaceProof(recipe: SurfaceRecipe.diamonds),
      SurfaceProof(recipe: SurfaceRecipe.diamonds, seed: 29),
      SurfaceProof(recipe: SurfaceRecipe.diamonds, phase: const Offset(17, 9)),
    ];
    try {
      final pixels = await Future.wait(
        scenes.map((s) => rasterSurface(s, viewport)),
      );
      expect(pixels[1], pixels[0]);
      expect(pixels[2], isNot(pixels[0]));
      expect(pixels[3], isNot(pixels[0]));
    } finally {
      for (final scene in scenes) {
        scene.dispose();
      }
    }
  });

  test(
    'one printed pattern composes on paper without recoloring its base',
    () async {
      const small = Rect.fromLTWH(0, 0, 256, 256);
      final paper = SurfaceProof(
        recipe: SurfaceRecipe.checker,
        domain: small,
        substrate: CraftMaterial.paper,
      );
      final cloth = SurfaceProof(recipe: SurfaceRecipe.checker, domain: small);
      final noPrint = SurfaceProof(
        recipe: SurfaceRecipe.checker,
        domain: small,
        printColor: Colors.transparent,
      );
      try {
        final paperPixels = await rasterSurface(paper, small);
        final clothPixels = await rasterSurface(cloth, small);
        final basePixels = await rasterSurface(noPrint, small);
        expect(paperPixels, isNot(clothPixels));
        var changed = 0, unchanged = 0;
        for (var i = 0; i < clothPixels.length; i += 4) {
          if (clothPixels[i] == basePixels[i] &&
              clothPixels[i + 1] == basePixels[i + 1] &&
              clothPixels[i + 2] == basePixels[i + 2]) {
            unchanged++;
          } else {
            changed++;
          }
        }
        expect(unchanged, greaterThan(25000));
        expect(changed, greaterThan(25000));
      } finally {
        paper.dispose();
        cloth.dispose();
        noPrint.dispose();
      }
    },
  );

  test(
    'direction, density and length affect fibers, zero strength removes them',
    () async {
      const small = Rect.fromLTWH(0, 0, 320, 180);
      final scenes = [
        SurfaceProof(recipe: SurfaceRecipe.fibers, domain: small),
        SurfaceProof(
          recipe: SurfaceRecipe.fibers,
          domain: small,
          fiberAngle: 0,
        ),
        SurfaceProof(
          recipe: SurfaceRecipe.fibers,
          domain: small,
          fiberLength: 4,
        ),
        SurfaceProof(
          recipe: SurfaceRecipe.fibers,
          domain: small,
          fiberDensity: 15,
        ),
        SurfaceProof(
          recipe: SurfaceRecipe.fibers,
          domain: small,
          fiberStrength: 0,
        ),
      ];
      try {
        final pixels = await Future.wait(
          scenes.map((s) => rasterSurface(s, small)),
        );
        for (final other in pixels.skip(1)) {
          expect(other, isNot(pixels[0]));
        }
        expect(
          pixels.last.toSet().length,
          lessThan(5),
          reason: 'No fibers and no paper creases remain',
        );
      } finally {
        for (final scene in scenes) {
          scene.dispose();
        }
      }
    },
  );

  test(
    'wash core, feather width, curve and irregularity change actual pixels',
    () async {
      const small = Rect.fromLTWH(0, 0, 320, 240);
      final scenes = [
        SurfaceProof(recipe: SurfaceRecipe.featheredWash, domain: small),
        SurfaceProof(
          recipe: SurfaceRecipe.featheredWash,
          domain: small,
          coreOpacity: .6,
        ),
        SurfaceProof(
          recipe: SurfaceRecipe.featheredWash,
          domain: small,
          feather: 0,
        ),
        SurfaceProof(
          recipe: SurfaceRecipe.featheredWash,
          domain: small,
          tightFeather: true,
        ),
        SurfaceProof(
          recipe: SurfaceRecipe.featheredWash,
          domain: small,
          irregular: false,
        ),
      ];
      try {
        final pixels = await Future.wait(
          scenes.map((s) => rasterSurface(s, small, ratio: 3)),
        );
        for (final other in pixels.skip(1)) {
          expect(other, isNot(pixels[0]));
        }
      } finally {
        for (final scene in scenes) {
          scene.dispose();
        }
      }
    },
  );

  test(
    'feathered field exports real soft alpha without an opaque paper matte',
    () async {
      const small = Rect.fromLTWH(0, 0, 320, 240);
      final scene = SurfaceProof(
        recipe: SurfaceRecipe.featheredWash,
        domain: small,
        feather: 8,
        paintSubstrate: false,
      );
      try {
        final pixels = await rasterSurface(scene, small, ratio: 3);
        int alpha(int x, int y) => pixels[(y * 960 + x) * 4 + 3];
        expect(alpha(0, 0), 0);
        expect(alpha(480, 360), inInclusiveRange(65, 80));
        final transition = [for (var x = 0; x < 200; x++) alpha(x, 360)];
        expect(transition.toSet().length, greaterThan(20));
        expect(transition.any((v) => v > 0 && v < 60), isTrue);
      } finally {
        scene.dispose();
      }
    },
  );

  test(
    'unbounded domains and invalid crops fail; disposed owners cannot paint',
    () {
      expect(
        () => SurfaceProof(
          recipe: SurfaceRecipe.fibers,
          domain: const Rect.fromLTWH(0, 0, 960, 2300),
        ),
        throwsArgumentError,
      );
      expect(
        () =>
            SurfaceProof(recipe: SurfaceRecipe.fibers, fiberLength: double.nan),
        throwsArgumentError,
      );
      expect(
        () => SurfaceProof(
          recipe: SurfaceRecipe.checker,
          phase: const Offset(1e300, 0),
        ),
        throwsArgumentError,
      );
      final scene = SurfaceProof(recipe: SurfaceRecipe.fibers);
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      expect(
        () => scene.paintViewport(canvas, const Rect.fromLTWH(-1, 0, 100, 100)),
        throwsArgumentError,
      );
      expect(
        () => scene.paintViewport(canvas, viewport, stripHeight: .01),
        throwsArgumentError,
      );
      scene.dispose();
      scene.dispose();
      expect(() => scene.paintViewport(canvas, viewport), throwsStateError);
      recorder.endRecording().dispose();
    },
  );

  testWidgets(
    'scroll retains one scene; native choices work at enlarged text',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2)),
            child: child!,
          ),
          home: const SurfaceLab(),
        ),
      );
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -300),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.byType(DropdownButtonFormField<SurfaceRecipe>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Fibers').last);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Fibers'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
