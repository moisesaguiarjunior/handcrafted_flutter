import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

import 'support/raster.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final wash = pigmentOutline(
    const Rect.fromLTWH(10, 10, 80, 60),
    seed: 13,
    broad: true,
  );
  const pigment = Color(0xFF6F93AA), paper = Color(0xFFFFFCF5);

  test(
    'watercolor responds to explicit palette, seed and granulation',
    () async {
      Future<Uint8List> render({
        int seed = 3,
        double granulation = .8,
        Color companion = const Color(0xFF6E9A74),
        Color substrate = paper,
      }) => pixels(
        (canvas) => paintWatercolor(
          canvas,
          wash,
          pigment: pigment,
          paper: substrate,
          companion: companion,
          seed: seed,
          granulation: granulation,
        ),
      );
      final first = await render();
      await render(seed: 99);
      expect(first, await render());
      expect(first, isNot(await render(seed: 4)));
      expect(first, isNot(await render(granulation: 0)));
      expect(first, isNot(await render(companion: const Color(0xFFBB798C))));
      expect(first, isNot(await render(substrate: const Color(0xFFDDD0B4))));
      expect(first[(40 * 100 + 45) * 4 + 3], greaterThan(0));
      expect(first[3], 0);
    },
  );

  test(
    'watercolor respects holes and zero opacity, without mutating the shape',
    () async {
      final ring = Path()
        ..fillType = PathFillType.evenOdd
        ..addRect(const Rect.fromLTWH(10, 10, 80, 60))
        ..addOval(const Rect.fromLTWH(35, 25, 30, 30));
      final original = ring.computeMetrics().map((m) => m.length).toList();
      Future<Uint8List> render(double opacity, {Color color = pigment}) =>
          pixels(
            (canvas) => paintWatercolor(
              canvas,
              ring,
              pigment: color,
              paper: paper,
              opacity: opacity,
            ),
          );
      final image = await render(.8);
      expect(image[(40 * 100 + 50) * 4 + 3], 0);
      expect(image[(18 * 100 + 20) * 4 + 3], greaterThan(0));
      expect((await render(0)).every((byte) => byte == 0), isTrue);
      expect(
        (await render(
          1,
          color: const Color(0x00000000),
        )).every((byte) => byte == 0),
        isTrue,
      );
      expect(ring.computeMetrics().map((m) => m.length), original);
    },
  );

  test(
    'relief changes edge lighting and retains the underlying fabric center',
    () async {
      final shape = Path()..addRect(const Rect.fromLTWH(20, 15, 60, 50));
      Future<Uint8List> render(CraftReliefKind kind, Offset light) =>
          pixels((canvas) {
            canvas.drawColor(const Color(0xFF36566A), BlendMode.src);
            paintCraftRelief(canvas, shape, kind: kind, depth: 3, light: light);
          });
      final inset = await render(CraftReliefKind.inset, const Offset(-1, -1));
      final raised = await render(CraftReliefKind.raised, const Offset(-1, -1));
      expect(inset, isNot(raised));
      expect(
        inset,
        isNot(await render(CraftReliefKind.inset, const Offset(1, 1))),
      );
      final center = (40 * 100 + 50) * 4;
      expect(inset.sublist(center, center + 4), [54, 86, 106, 255]);
      expect(raised.sublist(center, center + 4), [54, 86, 106, 255]);
      final empty = await pixels(
        (canvas) => paintCraftRelief(canvas, shape, depth: 0),
      );
      expect(empty.every((byte) => byte == 0), isTrue);
    },
  );

  test(
    'relief honors cutouts and keeps inset rims inside the supplied shape',
    () async {
      final ring = Path()
        ..fillType = PathFillType.evenOdd
        ..addRect(const Rect.fromLTWH(10, 10, 80, 60))
        ..addRect(const Rect.fromLTWH(30, 25, 40, 25));
      final result = await pixels(
        (canvas) => paintCraftRelief(canvas, ring, depth: 3),
      );
      expect(result[(40 * 100 + 50) * 4 + 3], 0);
      expect(result[3], 0);
      expect(result[(10 * 100 + 15) * 4 + 3], greaterThan(0));
      final flat = await pixels(
        (canvas) => paintCraftRelief(
          canvas,
          ring,
          depth: 0,
          fill: const Color(0xFFAA6688),
        ),
      );
      expect(flat[(40 * 100 + 50) * 4 + 3], 0);
      expect(flat[(18 * 100 + 20) * 4 + 3], 255);
    },
  );

  test(
    'invalid wash and relief inputs fail before leaving any paint',
    () async {
      final output = await pixels((canvas) {
        for (final value in [-1.0, 1.1, double.nan, double.infinity]) {
          expect(
            () => paintWatercolor(
              canvas,
              wash,
              pigment: pigment,
              paper: paper,
              opacity: value,
            ),
            throwsArgumentError,
          );
          expect(
            () => paintWatercolor(
              canvas,
              wash,
              pigment: pigment,
              paper: paper,
              granulation: value,
            ),
            throwsArgumentError,
          );
          expect(
            () => paintCraftRelief(canvas, wash, strength: value),
            throwsArgumentError,
          );
        }
        for (final value in [-1.0, 9.0, double.nan, double.infinity]) {
          expect(
            () => paintCraftRelief(canvas, wash, depth: value),
            throwsArgumentError,
          );
        }
        for (final light in [Offset.zero, const Offset(double.infinity, 1)]) {
          expect(
            () => paintCraftRelief(canvas, wash, light: light),
            throwsArgumentError,
          );
        }
        final open = Path()
          ..moveTo(10, 10)
          ..lineTo(80, 60);
        expect(
          () => paintWatercolor(canvas, open, pigment: pigment, paper: paper),
          throwsArgumentError,
        );
        expect(
          () => paintCraftRelief(canvas, open, fill: pigment),
          throwsArgumentError,
        );
        final big = Path()..addRect(const Rect.fromLTWH(0, 0, 2050, 10));
        expect(
          () => paintWatercolor(canvas, big, pigment: pigment, paper: paper),
          throwsArgumentError,
        );
      });
      expect(output.every((byte) => byte == 0), isTrue);
    },
  );

  testWidgets(
    'relief lettering keeps native layout, wrapping and one semantics label',
    (tester) async {
      final semantics = tester.ensureSemantics();
      try {
        for (final direction in TextDirection.values) {
          for (final scale in [1.0, 1.5, 2.5]) {
            const text = 'Small seeds grow into a garden';
            const style = TextStyle(fontSize: 20, color: Color(0xFF36566A));
            Widget host(Widget child) => MaterialApp(
              home: MediaQuery(
                data: MediaQueryData(textScaler: TextScaler.linear(scale)),
                child: Directionality(
                  textDirection: direction,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: SizedBox(width: 160, child: child),
                  ),
                ),
              ),
            );
            await tester.pumpWidget(host(const Text(text, style: style)));
            final native = tester.getSize(find.byType(Text).last);
            await tester.pumpWidget(
              host(const CraftReliefText(text, style: style)),
            );
            expect(tester.getSize(find.byType(Text).last), native);
            expect(find.bySemanticsLabel(text), findsOneWidget);
            expect(tester.takeException(), isNull);
          }
        }
        await tester.pumpWidget(const SizedBox());
      } finally {
        semantics.dispose();
      }
    },
  );

  testWidgets(
    'invalid text depth fails, and zero depth uses native text directly',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: CraftReliefText('Field notes', depth: -1)),
      );
      expect(tester.takeException(), isArgumentError);
      await tester.pumpWidget(
        const MaterialApp(
          home: CraftReliefText('Field notes', light: Offset.zero),
        ),
      );
      expect(tester.takeException(), isArgumentError);
      await tester.pumpWidget(
        const MaterialApp(home: CraftReliefText('Field notes', depth: 0)),
      );
      expect(find.text('Field notes'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
