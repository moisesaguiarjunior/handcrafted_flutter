import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcrafted_example/material_vocabulary.dart';
import 'package:handcrafted_example/main_gallery.dart';
import 'package:handcrafted_example/showcase_theme.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

void main() {
  testWidgets('actual wide gallery retains the main material in both themes', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1440, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      const HandcraftedGalleryApp(initialStudy: GalleryStudy.vocabulary),
    );
    await tester.pumpAndSettle();
    for (final width in [1440.0, 1920.0]) {
      tester.view.physicalSize = Size(width, 900);
      await tester.pumpAndSettle();
      for (final cloth in [false, true]) {
        tester
            .widget<SwitchListTile>(
              find.byKey(const ValueKey('material-theme')),
            )
            .onChanged!(cloth);
        await tester.pumpAndSettle();
        final surfaces = find
            .byType(CraftSurface)
            .evaluate()
            .where(
              (element) =>
                  element.findAncestorWidgetOfExactType<CraftPanel>()?.role ==
                  CraftRole.card,
            )
            .toList();
        expect(
          surfaces,
          hasLength(1),
          reason: 'The primary card must not silently enter the plain fallback at a common desktop width.',
        );
        expect(
          tester.getSize(find.byWidget(surfaces.single.widget)).width,
          lessThanOrEqualTo(1024),
        );
        expect(find.byType(TextField), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    }
    await tester.tap(find.text('Send reply'));
    await tester.pumpAndSettle();
    expect(find.text('Reply sent: see you Sunday.'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  for (final scale in [1.0, 2.5]) {
    testWidgets(
      'host themes retain actual note and choice at 320px scale $scale',
      (tester) async {
        tester.view.physicalSize = const Size(320, 1000);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await tester.pumpWidget(
          MaterialApp(
            theme: showcaseTheme(),
            home: const Scaffold(
              body: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: MaterialVocabularyStudy(),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final input = find.byKey(const ValueKey('material-note-title'));
        await tester.enterText(input, 'The whole Silva family');
        final element = tester.element(input);
        final focus = tester
            .widget<EditableText>(find.byType(EditableText))
            .focusNode;
        tester
            .widget<SwitchListTile>(
              find.byKey(const ValueKey('material-theme')),
            )
            .onChanged!(true);
        await tester.pumpAndSettle();
        expect(tester.element(input), same(element));
        expect(find.text('The whole Silva family'), findsOneWidget);
        expect(focus.hasFocus, isTrue);
        bool selected(String key) =>
            tester.widget<CraftChoice>(find.byKey(ValueKey(key))).selected;
        expect(selected('rsvp-yes'), isTrue);
        expect(selected('rsvp-no'), isFalse);
        await tester.ensureVisible(find.text('Can’t make it'));
        await tester.tap(find.text('Can’t make it'));
        await tester.pumpAndSettle();
        expect(selected('rsvp-yes'), isFalse);
        expect(selected('rsvp-no'), isTrue);
        await tester.ensureVisible(find.text('Send reply'));
        await tester.tap(find.text('Send reply'));
        await tester.pumpAndSettle();
        expect(find.text('Reply sent: we’ll miss you.'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }
}
