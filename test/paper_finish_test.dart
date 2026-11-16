import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

import 'support/raster.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final outline = Path()
    ..fillType = PathFillType.evenOdd
    ..addRect(const Rect.fromLTWH(6, 6, 88, 68))
    ..addRect(const Rect.fromLTWH(40, 30, 20, 20));

  test(
    'finishes remain distinct, seeded, clipped and empty at zero strength',
    () async {
      final images = <Uint8List>[];
      for (final finish in PaperFinish.values) {
        Future<Uint8List> render({int seed = 23, double strength = .8}) =>
            pixels(
              (canvas) => paintPaperFinish(
                canvas,
                outline,
                finish: finish,
                ink: const Color(0xFF654321),
                seed: seed,
                strength: strength,
              ),
            );
        final image = await render();
        expect(image, orderedEquals(await render()));
        if (finish == PaperFinish.recycled || finish == PaperFinish.coldPress) {
          expect(image, isNot(orderedEquals(await render(seed: 24))));
        }
        expect(image.any((v) => v > 0), isTrue);
        for (var y = 0; y < 80; y++) {
          for (var x = 0; x < 100; x++) {
            if (x < 6 ||
                x >= 94 ||
                y < 6 ||
                y >= 74 ||
                (x >= 40 && x < 60 && y >= 30 && y < 50)) {
              expect(image[(y * 100 + x) * 4 + 3], 0);
            }
          }
        }
        expect((await render(strength: 0)).every((v) => v == 0), isTrue);
        for (final previous in images) {
          expect(image, isNot(orderedEquals(previous)));
        }
        images.add(image);
      }
    },
  );

  test(
    'edge recipes fit bounds, preserve notches and respond to their controls',
    () async {
      const bounds = Rect.fromLTWH(6, 6, 88, 68);
      final images = <Uint8List>[];
      for (final edge in PaperEdge.values) {
        final shape = paperOutline(bounds, edge: edge, seed: 23);
        expect(shape.computeMetrics().single.isClosed, isTrue);
        expect(shape.getBounds().left, greaterThanOrEqualTo(bounds.left - .01));
        expect(shape.getBounds().right, lessThanOrEqualTo(bounds.right + .01));
        final image = await pixels(
          (canvas) => canvas.drawPath(shape, Paint()..color = Colors.white),
        );
        for (final previous in images) {
          expect(image, isNot(orderedEquals(previous)));
        }
        images.add(image);
        if (edge == PaperEdge.torn || edge == PaperEdge.deckle) {
          final changed = await pixels(
            (canvas) => canvas.drawPath(
              paperOutline(bounds, edge: edge, seed: 24),
              Paint()..color = Colors.white,
            ),
          );
          expect(image, isNot(orderedEquals(changed)));
        }
        final flat = paperOutline(bounds, edge: edge, depth: 0);
        expect(flat.contains(const Offset(7, 7)), isTrue);
      }
      final notch = paperOutline(bounds, edge: PaperEdge.postage, depth: 3);
      expect(
        paperOutline(
          const Rect.fromLTWH(0, 0, 5, 5),
          edge: PaperEdge.postage,
          depth: 2,
        ).computeMetrics(),
        isEmpty,
      );
      // First top notch midpoint lies six pixels into the first 12.57px period.
      expect(
        notch.contains(Offset(bounds.left + bounds.width / 14, bounds.top + 1)),
        isFalse,
      );
      expect(
        notch.contains(Offset(bounds.left + bounds.width / 14, bounds.top + 5)),
        isTrue,
      );
    },
  );

  test(
    'fibers clip to the material and invalid finish requests paint nothing',
    () async {
      final fibers = await pixels(
        (canvas) => paintPaperEdgeFibers(
          canvas,
          outline,
          fiber: Colors.white,
          strength: 1,
        ),
      );
      expect(fibers.any((v) => v != 0), isTrue);
      for (var y = 0; y < 80; y++) {
        for (var x = 0; x < 100; x++) {
          if (x < 6 ||
              x >= 94 ||
              y < 6 ||
              y >= 74 ||
              (x >= 40 && x < 60 && y >= 30 && y < 50)) {
            expect(fibers[(y * 100 + x) * 4 + 3], 0);
          }
        }
      }
      final empty = await pixels((canvas) {
        expect(
          () => paintPaperFinish(
            canvas,
            outline,
            finish: PaperFinish.recycled,
            ink: Colors.white,
            scale: double.nan,
          ),
          throwsArgumentError,
        );
        expect(
          () => paintPaperEdgeFibers(
            canvas,
            outline,
            fiber: Colors.white,
            length: 5,
          ),
          throwsArgumentError,
        );
      });
      expect(empty.every((v) => v == 0), isTrue);
      expect(
        () => paperOutline(const Rect.fromLTWH(0, 0, 80, 60), depth: 5),
        throwsArgumentError,
      );
      expect(
        () => const CraftOutline.paper(edgeDepth: 5).pathFor(Size.zero),
        throwsArgumentError,
      );
    },
  );

  testWidgets(
    'value paper recipes retain native surface geometry and invalidate edge changes',
    (tester) async {
      Future<Path> show(CraftOutline shape) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Center(
              child: SizedBox(
                width: 100,
                height: 80,
                child: CraftSurface(
                  material: CraftMaterial.paper,
                  color: Colors.white,
                  shape: shape,
                  child: const Text('Native'),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        return tester
            .widget<ClipPath>(find.byType(ClipPath).first)
            .clipper!
            .getClip(const Size(100, 80));
      }

      final first = await show(const CraftOutline.paper(seed: 23));
      expect(await show(const CraftOutline.paper(seed: 23)), same(first));
      for (final changed in [
        const CraftOutline.paper(seed: 23, edge: PaperEdge.postage),
        const CraftOutline.paper(seed: 23, edgeDepth: 2),
        const CraftOutline.paper(seed: 23, edgePitch: 16),
        const CraftOutline.paper(seed: 24),
      ]) {
        final baseline = await show(const CraftOutline.paper(seed: 23));
        expect(await show(changed), isNot(same(baseline)));
      }
      expect(find.text('Native'), findsOneWidget);
    },
  );
}
