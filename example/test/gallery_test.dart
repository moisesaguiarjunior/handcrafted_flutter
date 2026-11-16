import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:handcrafted_example/main_gallery.dart';
import 'package:handcrafted_example/motion_studies.dart';
import 'package:handcrafted_example/stitch_studies.dart';
import 'package:handcrafted_example/trim_studies.dart';

import 'support/fonts.dart';

void main() {
  testWidgets(
    'every hosted study lays out at narrow enlarged text, including full-page ink',
    (tester) async {
      await tester.runAsync(loadShowcaseFonts);
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 1100);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      for (final study in GalleryStudy.values) {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(
              size: Size(320, 1100),
              textScaler: TextScaler.linear(2.5),
            ),
            child: HandcraftedGalleryApp(
              key: ValueKey(study),
              initialStudy: study,
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: study.name);
      }
      await tester.pumpWidget(const SizedBox());
      expect(tester.binding.transientCallbackCount, 0);
    },
  );
  testWidgets(
    'gallery switches studies and disposes offscreen motion rather than retaining clocks',
    (tester) async {
      await tester.runAsync(loadShowcaseFonts);
      await tester.pumpWidget(
        const HandcraftedGalleryApp(initialStudy: GalleryStudy.motion),
      );
      await tester.pumpAndSettle();
      expect(find.byType(MotionPlayground), findsOneWidget);
      await tester.ensureVisible(find.text('Play motion'));
      await tester.tap(find.text('Play motion'));
      await tester.pump(const Duration(milliseconds: 50));
      expect(tester.binding.transientCallbackCount, greaterThan(0));
      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.scrollUntilVisible(
        find.widgetWithText(ListTile, 'Stitch families'),
        350,
        scrollable: find.descendant(
          of: find.byType(Drawer),
          matching: find.byType(Scrollable),
        ),
      );
      await tester.tap(find.widgetWithText(ListTile, 'Stitch families'));
      await tester.pumpAndSettle();
      expect(find.byType(StitchPlayground), findsOneWidget);
      expect(find.byType(MotionPlayground, skipOffstage: false), findsNothing);
      expect(tester.binding.transientCallbackCount, 0);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('narrow enlarged drawer and controls remain reachable', (
    tester,
  ) async {
    await tester.runAsync(loadShowcaseFonts);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 1100);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      const HandcraftedGalleryApp(initialStudy: GalleryStudy.stitches),
    );
    final context = tester.element(find.byType(StitchPlayground));
    final media = MediaQuery.of(context)
        .copyWith(textScaler: const TextScaler.linear(2.5));
    await tester.pumpWidget(
      MediaQuery(
        data: media,
        child: const HandcraftedGalleryApp(initialStudy: GalleryStudy.stitches),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      MediaQuery.textScalerOf(tester.element(find.byType(StitchPlayground)))
          .scale(10),
      25,
    );
    await tester.tap(find.byTooltip('Open navigation menu'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.widgetWithText(ListTile, 'Cord & ribbon'),
      350,
      scrollable: find.descendant(
        of: find.byType(Drawer),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Cord & ribbon'));
    await tester.pumpAndSettle();
    expect(find.byType(TrimPlayground), findsOneWidget);
    await tester.ensureVisible(find.byType(Slider).first);
    await tester.drag(find.byType(Slider).first, const Offset(40, 0));
    await tester.pumpAndSettle();
    expect(
      tester.widget<TrimStudies>(find.byType(TrimStudies)).width,
      greaterThan(10),
    );
    expect(tester.takeException(), isNull);
  });
}
