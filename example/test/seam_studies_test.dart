import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcrafted_example/main_seams.dart';
import 'package:handcrafted_example/seam_studies.dart';

import 'support/fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadShowcaseFonts);

  test(
    'geometry shares one outline and offset until effective size changes',
    () {
      var builds = 0;
      final geometry = PreparedSeamGeometry((size) {
        builds++;
        return Path()..addRect(Offset.zero & size);
      }, 8);
      final first = geometry.outlineFor(const Size(100, 80));
      final seam = geometry.seamFor(const Size(100, 80));
      expect(geometry.outlineFor(const Size(100, 80)), same(first));
      expect(geometry.seamFor(const Size(100, 80)), same(seam));
      expect(builds, 1);
      expect(geometry.seamFor(const Size(80, 60)), isNot(same(seam)));
      expect(builds, 2);
      expect(
        geometry.seamFor(const Size(80, 60)).getBounds().right,
        closeTo(72, .3),
      );
    },
  );

  testWidgets('native slider and seed produce quiet updated specimens', (
    tester,
  ) async {
    await tester.pumpWidget(const ContourSeamApp());
    await tester.pumpAndSettle();
    final slider = tester.widget<Slider>(
      find.byKey(const ValueKey('seam-inset')),
    );
    slider.onChanged!(16);
    await tester.pumpAndSettle();
    expect(find.text('Seam inset 16.0 logical pixels'), findsOneWidget);
    await tester.tap(find.text('Change cut seed'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  for (final scale in [1.0, 1.5, 2.0, 2.5]) {
    testWidgets('seam controls and captions flow at 320px and scale $scale', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(320, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(const ContourSeamApp());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Change cut seed'));
      await tester.tap(find.text('Change cut seed'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('column breakpoints stay within the geometry work budget', (
    tester,
  ) async {
    for (final width in [619.0, 620.0, 939.0, 940.0, 1300.0]) {
      await tester.binding.setSurfaceSize(Size(width, 900));
      await tester.pumpWidget(const ContourSeamApp());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
    await tester.binding.setSurfaceSize(null);
  });
}
