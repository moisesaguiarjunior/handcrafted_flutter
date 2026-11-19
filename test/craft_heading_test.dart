import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

import 'support/widget_raster.dart';

const words = 'Small wonders';
const lettering = TextStyle(
  fontSize: 28,
  color: Color(0xFF304A52),
  letterSpacing: .4,
);
CraftTheme material(CraftReliefStyle? heading) => CraftTheme(
  surface: CraftPanelStyle(material: CraftMaterial.paper, color: Colors.white),
  heading: heading,
);

void main() {
  testWidgets(
    'theme and explicit heading lighting use the existing glyph painter',
    (tester) async {
      final boundary = GlobalKey();
      Future<List<int>> pixels(Widget text, CraftTheme? materials) async {
        // Keep the measured canvas fixed across native/reference widgets.
        await tester.pumpWidget(
          MaterialApp(
            themeAnimationStyle: AnimationStyle.noAnimation,
            theme: ThemeData(
              textTheme: const TextTheme(headlineMedium: lettering),
              extensions: [?materials],
            ),
            home: Scaffold(
              body: Align(
                alignment: Alignment.topLeft,
                child: RepaintBoundary(
                  key: boundary,
                  child: ColoredBox(
                    color: Colors.white,
                    child: SizedBox(width: 240, height: 120, child: text),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        return widgetPixels(tester, boundary);
      }

      final plain = await pixels(
        Builder(
          builder: (context) =>
              Text(words, style: Theme.of(context).textTheme.headlineMedium),
        ),
        null,
      );
      expect(await pixels(const CraftHeading(words), null), plain);
      for (final kind in CraftReliefKind.values) {
        final effect = CraftReliefStyle(
          kind: kind,
          depth: 2.3,
          light: const Offset(1, -2),
        );
        final theme = material(effect);
        final expected = await pixels(
          Builder(
            builder: (context) => CraftReliefText(
              words,
              style: Theme.of(context).textTheme.headlineMedium,
              kind: kind,
              depth: 2.3,
              light: const Offset(1, -2),
            ),
          ),
          null,
        );
        expect(expected, isNot(plain));
        expect(await pixels(const CraftHeading(words), theme), expected);
        expect(
          await pixels(CraftHeading(words, relief: effect), null),
          expected,
        );
        expect(
          await pixels(const CraftHeading(words), theme.copyWith()),
          expected,
        );
        expect(
          await pixels(
            CraftHeading(words, relief: CraftReliefStyle(depth: 0)),
            theme,
          ),
          plain,
        );
      }
    },
  );

  testWidgets(
    'heading keeps native wrapping scaling direction and one accessible label',
    (tester) async {
      final semantics = tester.ensureSemantics();
      try {
        for (final direction in TextDirection.values) {
          for (final scale in [1.0, 2.5]) {
            const text = 'Small wonders kept close';
            Widget view(Widget child) => MaterialApp(
              theme: ThemeData(
                textTheme: const TextTheme(headlineMedium: lettering),
              ),
              home: MediaQuery(
                data: MediaQueryData(
                  textScaler: TextScaler.linear(scale),
                  boldText: true,
                ),
                child: Directionality(
                  textDirection: direction,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: SizedBox(width: 184, child: child),
                  ),
                ),
              ),
            );
            await tester.pumpWidget(
              view(
                Builder(
                  builder: (context) => Text(
                    text,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
              ),
            );
            final native = tester.getSize(find.text(text));
            await tester.pumpWidget(
              view(CraftHeading(text, relief: CraftReliefStyle())),
            );
            await tester.pumpAndSettle();
            expect(tester.getSize(find.text(text)), native);
            expect(find.bySemanticsLabel(text), findsOneWidget);
            expect(
              tester
                  .getSemantics(find.bySemanticsLabel(text))
                  .getSemanticsData()
                  .flagsCollection
                  .isHeader,
              isTrue,
            );
            expect(find.byType(FittedBox), findsNothing);
            expect(tester.binding.transientCallbackCount, 0);
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
    'optional theme lighting transitions survive opposite directions and plain endpoints',
    (tester) async {
      final a = material(
        CraftReliefStyle(depth: 3, light: const Offset(-1, -1)),
      );
      final b = material(
        CraftReliefStyle(
          kind: CraftReliefKind.raised,
          depth: 1,
          light: const Offset(1, 1),
        ),
      );
      final plain = material(null);
      for (final pair in [(a, b), (plain, a), (b, plain), (plain, plain)]) {
        for (final t in [0.0, .25, .49, .5, .75, 1.0]) {
          await tester.pumpWidget(
            MaterialApp(
              themeAnimationStyle: AnimationStyle.noAnimation,
              theme: ThemeData(extensions: [pair.$1.lerp(pair.$2, t)]),
              home: const Scaffold(body: CraftHeading(words)),
            ),
          );
          await tester.pumpAndSettle();
          expect(find.text(words), findsOneWidget);
          expect(tester.takeException(), isNull);
        }
      }
    },
  );

  test('invalid lighting fails before a heading can paint', () {
    for (final depth in [-.1, 8.1, double.nan, double.infinity]) {
      expect(() => CraftReliefStyle(depth: depth), throwsArgumentError);
    }
    for (final light in [
      Offset.zero,
      const Offset(double.nan, 1),
      const Offset(1, double.infinity),
    ]) {
      expect(() => CraftReliefStyle(light: light), throwsArgumentError);
    }
  });
}
