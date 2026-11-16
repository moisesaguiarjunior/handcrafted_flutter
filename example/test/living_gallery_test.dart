import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:handcrafted_example/gallery_routes.dart';
import 'package:handcrafted_example/living_materials.dart';
import 'package:handcrafted_example/main_gallery.dart';
import 'package:handcrafted_example/motion_studies.dart';

import 'support/fonts.dart';

void main() {
  testWidgets('mobile study label fits at 250 percent text without shrinking', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2.5;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(
      const HandcraftedGalleryApp(initialStudy: GalleryStudy.spreading),
    );
    await tester.pumpAndSettle();
    final label = find.byKey(const ValueKey('mobile-study-label'));
    final paragraph = tester.renderObject<RenderParagraph>(label);
    final boxes = paragraph.getBoxesForSelection(
      const TextSelection(baseOffset: 0, extentOffset: 15),
    );
    expect(boxes.length, greaterThan(1));
    for (final box in boxes) {
      expect(box.bottom, lessThanOrEqualTo(paragraph.size.height));
      expect(box.right, lessThanOrEqualTo(paragraph.size.width));
    }
    final picker = find.byKey(const ValueKey('mobile-study-picker'));
    expect(
      tester.getRect(picker).contains(tester.getRect(label).bottomRight),
      isTrue,
    );
    await tester.tap(picker);
    await tester.pumpAndSettle();
    await tester.tap(
      find.widgetWithText(PopupMenuItem<GalleryStudy>, 'Paint spreading'),
    );
    await tester.pumpAndSettle();
    expect(find.byType(LivingMaterialStudy), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'material replay pauses resumes scrubs and settles without idle clocks',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: LivingMaterialStudy(technique: LivingTechnique.watercolor),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      double pose() => tester
          .widget<LivingMaterialArtwork>(find.byType(LivingMaterialArtwork))
          .progress;
      expect(pose(), .48);
      expect(tester.binding.transientCallbackCount, 0);
      await tester.ensureVisible(find.text('Play'));
      await tester.tap(find.text('Play'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(pose(), greaterThan(.48));
      await tester.tap(find.text('Pause'));
      await tester.pump();
      final paused = pose();
      await tester.pump(const Duration(seconds: 2));
      expect(pose(), paused);
      expect(tester.binding.transientCallbackCount, 0);
      await tester.tap(find.text('Play'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(pose(), greaterThan(paused));
      tester
          .widget<Slider>(find.byKey(const ValueKey('living-progress')))
          .onChanged!(.2);
      await tester.pump();
      expect(pose(), .2);
      await tester.tap(find.text('Show finished'));
      await tester.pumpAndSettle();
      expect(pose(), 1);
      expect(tester.binding.transientCallbackCount, 0);
    },
  );
  testWidgets(
    'reduced motion settles playback and leaving the page disposes it',
    (tester) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      await tester.pumpWidget(
        const HandcraftedGalleryApp(initialStudy: GalleryStudy.embroidery),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Replay'));
      await tester.tap(find.text('Replay'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<LivingMaterialArtwork>(find.byType(LivingMaterialArtwork))
            .progress,
        1,
      );
      expect(tester.binding.transientCallbackCount, 0);
      tester
          .widget<Slider>(find.byKey(const ValueKey('living-progress')))
          .onChanged!(.25);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<LivingMaterialArtwork>(find.byType(LivingMaterialArtwork))
            .progress,
        .25,
      );

      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/navigation',
        const JSONMethodCodec().encodeMethodCall(
          const MethodCall('pushRouteInformation', {
            'location': '/?study=spreading',
            'state': null,
          }),
        ),
        (_) {},
      );
      await tester.pumpAndSettle();
      expect(find.byType(LivingMaterialStudy), findsOneWidget);
      expect(
        tester
            .widget<LivingMaterialStudy>(find.byType(LivingMaterialStudy))
            .technique,
        LivingTechnique.watercolor,
      );
    },
  );
  testWidgets(
    'desktop sections are visible and sharing tracks the selected route',
    (tester) async {
      tester.view.physicalSize = const Size(1440, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.runAsync(loadShowcaseFonts);
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            final arguments = call.arguments;
            if (arguments is Map<Object?, Object?>)
              copied = arguments['text'] as String?;
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await tester.pumpWidget(const HandcraftedGalleryApp());
      await tester.pumpAndSettle();
      expect(find.byTooltip('Open navigation menu'), findsNothing);
      await tester.tap(find.widgetWithText(ListTile, 'Paint spreading'));
      await tester.pumpAndSettle();
      expect(find.text('Let the color find its way'), findsOneWidget);
      await tester.tap(find.byTooltip('Copy study link'));
      await tester.pumpAndSettle();
      expect(Uri.parse(copied!).queryParameters['study'], 'spreading');
      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/navigation',
        const JSONMethodCodec().encodeMethodCall(
          const MethodCall('pushRouteInformation', {
            'location': '/?study=motion',
            'state': null,
          }),
        ),
        (_) {},
      );
      await tester.pumpAndSettle();
      expect(find.byType(MotionPlayground), findsOneWidget);
      expect(find.byType(LivingMaterialStudy), findsNothing);
    },
  );
  testWidgets(
    'host inactivity pauses a playing study while native text stays available from zero',
    (tester) async {
      final semantics = tester.ensureSemantics();
      Widget view(bool active) => MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: LivingMaterialStudy(
              key: const ValueKey('visibility'),
              technique: LivingTechnique.watercolor,
              active: active,
            ),
          ),
        ),
      );
      await tester.pumpWidget(view(true));
      await tester.pumpAndSettle();
      tester
          .widget<Slider>(find.byKey(const ValueKey('living-progress')))
          .onChanged!(0);
      await tester.pumpAndSettle();
      expect(find.text('Let the color find its way'), findsOneWidget);
      expect(
        find.bySemanticsLabel('Let the color find its way'),
        findsOneWidget,
      );
      expect(find.byType(ExcludeSemantics), findsWidgets);
      await tester.tap(find.widgetWithText(ChoiceChip, 'Pink + blue'));
      await tester.pumpAndSettle();
      expect(
        tester.getSemantics(find.widgetWithText(ChoiceChip, 'Pink + blue')),
        matchesSemantics(
          isSelected: !kIsWeb,
          isChecked: kIsWeb,
          hasCheckedState: kIsWeb,
          isEnabled: true,
          hasEnabledState: true,
          isFocusable: true,
          hasSelectedState: !kIsWeb,
          isButton: true,
          label: 'Pink + blue',
          hasTapAction: true,
          hasFocusAction: true,
        ),
      );
      await tester.ensureVisible(find.text('Play'));
      await tester.tap(find.text('Play'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      final before = tester
          .widget<LivingMaterialArtwork>(find.byType(LivingMaterialArtwork))
          .progress;
      await tester.pumpWidget(view(false));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));
      expect(
        tester
            .widget<LivingMaterialArtwork>(find.byType(LivingMaterialArtwork))
            .progress,
        before,
      );
      await tester.pumpWidget(const SizedBox());
      expect(tester.binding.transientCallbackCount, 0);
      semantics.dispose();
    },
  );
  test('study routes restore named studies while unknown links return to the start', () async {
    const parser = GalleryRouteParser(GalleryStudy.cover);
    for (final study in GalleryStudy.values) {
      expect(
        await parser.parseRouteInformation(
          parser.restoreRouteInformation(study),
        ),
        study,
      );
    }
    expect(
      await parser.parseRouteInformation(
        RouteInformation(uri: Uri.parse('/?study=unknown')),
      ),
      GalleryStudy.cover,
    );
  });
}
