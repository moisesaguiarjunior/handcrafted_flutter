import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';
import 'package:handcrafted_example/main_gallery.dart';
import 'package:handcrafted_example/painted_note.dart';
import 'package:handcrafted_example/showcase_theme.dart';

import 'support/fonts.dart';

void main() {
  testWidgets(
    'postcard editors keep focus and composing text across both layouts',
    (tester) async {
      await tester.runAsync(loadShowcaseFonts);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      for (final fieldKey in ['painted-note-text', 'postcard-to']) {
        for (final scale in [1.0, 2.5]) {
          tester.view.physicalSize = const Size(760, 1100);
          await tester.pumpWidget(
            MaterialApp(
              theme: showcaseTheme(),
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.linear(scale)),
                child: child!,
              ),
              home: const Scaffold(
                body: SingleChildScrollView(child: PaintedNote()),
              ),
            ),
          );
          final field = find.byKey(ValueKey(fieldKey));
          await tester.enterText(field, 'A postcard in progress');
          tester.testTextInput.updateEditingValue(
            const TextEditingValue(
              text: 'A postcard in progress',
              selection: TextSelection.collapsed(offset: 10),
              composing: TextRange(start: 2, end: 10),
            ),
          );
          await tester.pump();
          final editor = find.descendant(
            of: field,
            matching: find.byType(EditableText),
          );
          final state = tester.state(editor);
          final focus = tester.widget<EditableText>(editor).focusNode;
          final before = tester.widget<TextField>(field).controller!.value;
          for (final width in [480.0, 760.0]) {
            tester.view.physicalSize = Size(width, 1100);
            await tester.pumpAndSettle();
            expect(tester.state(editor), same(state));
            expect(tester.widget<EditableText>(editor).focusNode, same(focus));
            expect(focus.hasFocus, isTrue);
            expect(tester.testTextInput.hasAnyClients, isTrue);
            expect(tester.widget<TextField>(field).controller!.value, before);
            expect(tester.takeException(), isNull);
          }
          await tester.pumpWidget(const SizedBox());
        }
      }
    },
  );

  testWidgets('welcome exposes study actions before artwork on desktop', (
    tester,
  ) async {
    await tester.runAsync(loadShowcaseFonts);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1440, 900);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const HandcraftedGalleryApp());
    await tester.pumpAndSettle();
    final action = find.widgetWithText(FilledButton, 'Watch the paint spread');
    final actionBottom = tester.getBottomLeft(action).dy;
    expect(
      actionBottom,
      lessThan(tester.getTopLeft(find.byType(PaintedNote)).dy),
    );
    expect(
      actionBottom,
      lessThan(tester.view.physicalSize.height / tester.view.devicePixelRatio),
    );
    await tester.tap(action);
    await tester.pumpAndSettle();
    expect(find.text('Let the color find its way'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('native note keeps edits while material edge and action change', (
    tester,
  ) async {
    await tester.runAsync(loadShowcaseFonts);
    for (final scale in [1.0, 2.5]) {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 1000);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(scale)),
            child: const Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: PaintedNote(),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final field = find.byKey(const ValueKey('painted-note-text'));
      await tester.enterText(field, 'A blue feather');
      final choice = find.byType(CraftChoice);
      await tester.ensureVisible(choice);
      await tester.tap(choice);
      await tester.pumpAndSettle();
      final card = tester.widget<CraftPanel>(
        find.ancestor(of: field, matching: find.byType(CraftPanel)).first,
      );
      expect(card.style!.seam, isNull);
      expect(
        tester.widget<TextField>(field).controller!.text,
        'A blue feather',
      );
      await tester.ensureVisible(find.text('Send postcard'));
      await tester.tap(find.text('Send postcard'));
      await tester.pumpAndSettle();
      expect(find.text('Sent! It stays in this demo.'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      expect(tester.binding.transientCallbackCount, 0);
    }
  });
}
