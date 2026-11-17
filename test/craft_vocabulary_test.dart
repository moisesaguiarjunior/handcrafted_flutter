import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

import 'support/widget_raster.dart';

CraftPanelStyle surface(Color color, {bool cloth = false}) => CraftPanelStyle(
  material: cloth ? CraftMaterial.linen : CraftMaterial.paper,
  color: color,
  shape: const CraftOutline.paper(edge: PaperEdge.deckle, edgePitch: 24),
  seam: CraftSeam(color: const Color(0xFF4B6A62)),
);

void main() {
  testWidgets(
    'selection has a visible native check mark even without role overrides',
    (tester) async {
      final boundary = GlobalKey();
      final theme = ThemeData(
        extensions: [CraftTheme(surface: surface(Colors.amber))],
      );
      Widget view(bool selected) => MaterialApp(
        theme: theme,
        home: Scaffold(
          body: Center(
            child: RepaintBoundary(
              key: boundary,
              child: CraftChoice(
                selected: selected,
                onSelected: (_) {},
                child: const Text('Keep'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpWidget(view(false));
      await tester.pumpAndSettle();
      final unselected = await widgetPixels(tester, boundary);
      await tester.pumpWidget(view(true));
      await tester.pumpAndSettle();
      expect(await widgetPixels(tester, boundary), isNot(unselected));
      await tester.pumpWidget(view(false));
      await tester.pumpAndSettle();
      expect(await widgetPixels(tester, boundary), unselected);
    },
  );

  testWidgets(
    'material themes change actual pixels and restore the original seeded surface',
    (tester) async {
      final boundary = GlobalKey();
      Widget view(bool cloth) => MaterialApp(
        theme: ThemeData(
          extensions: [
            CraftTheme(
              surface: surface(Colors.white),
              roles: {
                CraftRole.card: surface(
                  cloth ? Colors.green : Colors.amber,
                  cloth: cloth,
                ),
              },
            ),
          ],
        ),
        home: Scaffold(
          body: Center(
            child: RepaintBoundary(
              key: boundary,
              child: const SizedBox(
                width: 240,
                height: 160,
                child: CraftPanel(
                  role: CraftRole.card,
                  child: Text('Still native'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpWidget(view(false));
      await tester.pumpAndSettle();
      final paper = await widgetPixels(tester, boundary);
      await tester.pumpWidget(view(true));
      await tester.pumpAndSettle();
      expect(await widgetPixels(tester, boundary), isNot(paper));
      await tester.pumpWidget(view(false));
      await tester.pumpAndSettle();
      expect(await widgetPixels(tester, boundary), paper);
    },
  );

  testWidgets(
    'theme changes preserve native input state focus selection and actions',
    (tester) async {
      final semantics = tester.ensureSemantics();
      try {
        final input = TextEditingController();
        final focus = FocusNode();
        addTearDown(input.dispose);
        addTearDown(focus.dispose);
        var cloth = false, selected = false;
        var presses = 0;
        late StateSetter update;
        await tester.pumpWidget(
          StatefulBuilder(
            builder: (context, setState) {
              update = setState;
              return MaterialApp(
                theme: ThemeData(
                  extensions: [
                    CraftTheme(
                      surface: surface(
                        cloth ? Colors.green.shade100 : Colors.amber.shade100,
                        cloth: cloth,
                      ),
                    ),
                  ],
                ),
                home: Scaffold(
                  body: SingleChildScrollView(
                    child: CraftPanel(
                      child: Column(
                        children: [
                          TextField(
                            key: const ValueKey('input'),
                            controller: input,
                            focusNode: focus,
                          ),
                          CraftChoice(
                            selected: selected,
                            onSelected: (v) => update(() => selected = v),
                            child: const Text('Keep this note'),
                          ),
                          CraftButton(
                            onPressed: () => presses++,
                            child: const Text('Save note'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Keep this note'));
        await tester.pumpAndSettle();
        final node = tester.getSemantics(
          find.widgetWithText(TextButton, 'Keep this note'),
        );
        expect(
          node.getSemanticsData().flagsCollection.isSelected,
          ui.Tristate.isTrue,
        );
        expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
        expect(node.getSemanticsData().flagsCollection.isButton, isTrue);
        await tester.enterText(
          find.byKey(const ValueKey('input')),
          'A tiny discovery',
        );
        focus.requestFocus();
        await tester.pumpAndSettle();
        final original = tester.element(find.byKey(const ValueKey('input')));
        update(() => cloth = true);
        await tester.pumpAndSettle();
        expect(
          tester.element(find.byKey(const ValueKey('input'))),
          same(original),
        );
        expect(input.text, 'A tiny discovery');
        expect(focus.hasFocus, isTrue);
        expect(
          tester
              .getSemantics(find.widgetWithText(TextButton, 'Keep this note'))
              .getSemanticsData()
              .flagsCollection
              .isSelected,
          ui.Tristate.isTrue,
        );
        await tester.tap(find.text('Save note'));
        expect(presses, 1);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      } finally {
        semantics.dispose();
      }
    },
  );

  testWidgets(
    'native targets and keyboard activation survive compact button themes',
    (tester) async {
      final focus = FocusNode();
      addTearDown(focus.dispose);
      var presses = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            visualDensity: VisualDensity.compact,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                fixedSize: const Size(12, 12),
                maximumSize: const Size(12, 12),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
          home: Scaffold(
            body: Center(
              child: CraftButton(
                style: CraftPanelStyle(
                  material: CraftMaterial.paper,
                  color: Colors.amber,
                  padding: EdgeInsets.zero,
                ),
                focusNode: focus,
                onPressed: () => presses++,
                child: const Text('Go'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final button = find.byType(TextButton);
      expect(tester.getSize(button).width, greaterThanOrEqualTo(48));
      expect(tester.getSize(button).height, greaterThanOrEqualTo(48));
      focus.requestFocus();
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(presses, 1);
      final rect = tester.getRect(button);
      await tester.tapAt(rect.topLeft + const Offset(2, 2));
      expect(
        presses,
        2,
        reason: 'Target stays native and rectangular beyond decorative cuts',
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'oversized decoration yields to native content without changing its element',
    (tester) async {
      var height = 100.0;
      late StateSetter update;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: StatefulBuilder(
                builder: (context, setState) {
                  update = setState;
                  return CraftPanel(
                    style: surface(Colors.amber),
                    padding: EdgeInsets.zero,
                    child: SizedBox(
                      height: height,
                      child: const Align(
                        alignment: Alignment.topLeft,
                        child: Text('Native label', key: ValueKey('label')),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final element = tester.element(find.byKey(const ValueKey('label')));
      expect(find.byType(CraftSurface), findsOneWidget);
      update(() => height = 1200);
      await tester.pumpAndSettle();
      expect(find.byType(CraftSurface), findsNothing);
      expect(
        tester.element(find.byKey(const ValueKey('label'))),
        same(element),
      );
      update(() => height = 100);
      await tester.pumpAndSettle();
      expect(find.byType(CraftSurface), findsOneWidget);
      expect(
        tester.element(find.byKey(const ValueKey('label'))),
        same(element),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('disabled choices announce selected state on a disabled action', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    try {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CraftChoice(
              style: surface(Colors.amber),
              selected: true,
              onSelected: null,
              child: const Text('Selected keepsake'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final node = tester.getSemantics(
        find.widgetWithText(TextButton, 'Selected keepsake'),
      );
      expect(
        node.getSemanticsData().flagsCollection.isSelected,
        ui.Tristate.isTrue,
      );
      expect(
        node.getSemanticsData().flagsCollection.isEnabled,
        ui.Tristate.isFalse,
      );
      expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isFalse);
    } finally {
      handle.dispose();
    }
  });

  test(
    'invalid recipes fail before widgets or decorative fallbacks can hide them',
    () {
      for (final value in [double.nan, double.infinity, -1.0]) {
        expect(
          () => CraftSeam(color: Colors.black, inset: value),
          throwsArgumentError,
        );
        expect(
          () => CraftPanelStyle(
            material: CraftMaterial.paper,
            color: Colors.white,
            strength: value,
          ),
          throwsArgumentError,
        );
      }
      expect(
        () => CraftPanelStyle(
          material: CraftMaterial.paper,
          color: Colors.white,
          padding: const EdgeInsets.all(double.infinity),
        ),
        throwsArgumentError,
      );
      expect(
        () => CraftPanelStyle(
          material: CraftMaterial.paper,
          color: Colors.white,
          shape: const CraftOutline.paper(edgeDepth: 9),
        ),
        throwsArgumentError,
      );
    },
  );
}
