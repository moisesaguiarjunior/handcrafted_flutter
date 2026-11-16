import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcrafted_example/material_vocabulary.dart';
import 'package:handcrafted_example/showcase_theme.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

void main() {
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
        await tester.enterText(input, 'A new little wonder');
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
        expect(find.text('A new little wonder'), findsOneWidget);
        expect(focus.hasFocus, isTrue);
        expect(
          tester.widget<CraftChoice>(find.byType(CraftChoice)).selected,
          isTrue,
        );
        await tester.ensureVisible(find.text('Keep this note'));
        await tester.tap(find.text('Keep this note'));
        await tester.pumpAndSettle();
        expect(
          tester.widget<CraftChoice>(find.byType(CraftChoice)).selected,
          isFalse,
        );
        await tester.ensureVisible(find.text('Try the action'));
        await tester.tap(find.text('Try the action'));
        await tester.pumpAndSettle();
        expect(find.text('Activations 1'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      },
    );
  }
}
