import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';
import 'package:handcrafted_example/main_papers.dart';
import 'package:handcrafted_example/seam_studies.dart';

import 'support/fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadShowcaseFonts);

  testWidgets(
    'paper controls change independent edges, finish strength and native actions',
    (tester) async {
      await tester.pumpWidget(const PaperRecipesApp());
      await tester.pumpAndSettle();
      for (final edge in ['Clean cut', 'Handmade deckle', 'Postage', 'Torn']) {
        await tester.ensureVisible(find.text(edge));
        await tester.tap(find.text(edge));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
      tester
          .widget<Slider>(find.byKey(const ValueKey('paper-strength')))
          .onChanged!(.2);
      tester
          .widget<Slider>(find.byKey(const ValueKey('paper-depth')))
          .onChanged!(4);
      await tester.pumpAndSettle();
      expect(find.text('Finish strength 20%'), findsOneWidget);
      await tester.ensureVisible(find.text('Compare four edges'));
      await tester.tap(find.text('Compare four edges'));
      await tester.pumpAndSettle();
      for (final surface in find.byType(CraftSurface).evaluate()) {
        expect(
          tester.getSize(find.byWidget(surface.widget)).width,
          greaterThan(100),
        );
      }
      await tester.ensureVisible(find.text('Use this paper'));
      await tester.tap(find.text('Use this paper'));
      await tester.pumpAndSettle();
      expect(find.text('Selections 1'), findsOneWidget);
      expect(tester.binding.hasScheduledFrame, isFalse);
    },
  );

  testWidgets(
    'enlarged text omits the seam while retaining the native action',
    (tester) async {
      await tester.pumpWidget(const PaperRecipesApp());
      await tester.pumpAndSettle();
      final action = tester.element(find.text('Use this paper'));
      expect(
        tester.widget<SeamedSurface>(find.byType(SeamedSurface)).showSeam,
        isTrue,
      );
      tester.platformDispatcher.textScaleFactorTestValue = 2.5;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpAndSettle();
      expect(
        tester.widget<SeamedSurface>(find.byType(SeamedSurface)).showSeam,
        isFalse,
      );
      expect(tester.element(find.text('Use this paper')), same(action));
      await tester.ensureVisible(find.text('Use this paper'));
      await tester.tap(find.text('Use this paper'));
      await tester.pumpAndSettle();
      expect(find.text('Selections 1'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  for (final scale in [1.0, 1.5, 2.0, 2.5]) {
    testWidgets(
      'paper specimens and letterhead flow at 320px and scale $scale',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(320, 900));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await tester.pumpWidget(const PaperRecipesApp());
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        await tester.ensureVisible(find.text('Use this paper'));
        await tester.tap(find.text('Use this paper'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('Selections 1'), findsOneWidget);
      },
    );
  }
}
