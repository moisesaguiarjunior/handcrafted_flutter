import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcrafted_example/volume_studies.dart';

import 'support/fonts.dart';

void main() {
  for (final width in [320.0, 390.0, 428.0]) {
    testWidgets('native volume controls at $width and enlarged text', (
      tester,
    ) async {
      await tester.runAsync(loadShowcaseFonts);
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 900);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(2.5)),
            child: child!,
          ),
          home: const Scaffold(
            body: SingleChildScrollView(child: LocalVolumePlayground()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final slider = find.byKey(const ValueKey('volume-direction'));
      final before = tester.widget<Slider>(slider).value;
      await tester.ensureVisible(slider);
      await tester.drag(slider, const Offset(80, 0));
      await tester.pumpAndSettle();
      expect(tester.widget<Slider>(slider).value, greaterThan(before));
      final elevation = tester.widget<Slider>(
        find.byKey(const ValueKey('volume-elevation')),
      );
      expect(elevation.semanticFormatterCallback!(1), '1.00 relative units');
      await tester.ensureVisible(
        find.text('At screen size: the same three cuts together'),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Paper in three forms'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final insertion = find.byKey(const ValueKey('fabric-insertion'));
      await tester.ensureVisible(insertion);
      final oldInsertion = tester.widget<Slider>(insertion).value;
      await tester.drag(insertion, const Offset(70, 0));
      await tester.pumpAndSettle();
      expect(tester.widget<Slider>(insertion).value, greaterThan(oldInsertion));
      for (final key in [
        'pocket-opening',
        'pocket-fold',
        'pocket-height',
        'pocket-seam',
      ]) {
        final finder = find.byKey(ValueKey(key));
        await tester.ensureVisible(finder);
        final before = tester.widget<Slider>(finder).value;
        final rect = tester.getRect(finder);
        final destination = key == 'pocket-opening'
            ? rect.centerLeft + const Offset(32, 0)
            : rect.centerRight - const Offset(32, 0);
        await tester.tapAt(destination);
        await tester.pumpAndSettle();
        expect(tester.widget<Slider>(finder).value, isNot(before));
        expect(tester.takeException(), isNull);
      }
      final compact = find.byWidgetPredicate(
        (w) => w is VolumeStudies && w.compact,
      );
      final paintSize = tester.getSize(
        find.descendant(of: compact, matching: find.byType(CustomPaint)).first,
      );
      expect(paintSize.aspectRatio, closeTo(300 / 160, .00001));
      await tester.pumpWidget(const SizedBox());
      expect(tester.binding.transientCallbackCount, 0);
    });
  }
}
