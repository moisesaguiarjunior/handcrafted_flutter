import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcrafted_example/experience_frame.dart';
import 'package:handcrafted_example/experience_study.dart';
import 'package:handcrafted_example/imported_layers.dart';
import 'package:handcrafted_example/showcase_theme.dart';

Widget host() => MaterialApp(
  theme: showcaseTheme(),
  home: const Scaffold(body: ExperienceFrameStudy()),
);

void main() {
  testWidgets(
    'safe areas and reduced motion preserve native labels from the first pose',
    (tester) async {
      tester.view.physicalSize = const Size(720, 600);
      tester.view.devicePixelRatio = 1;
      tester.view.padding = const FakeViewPadding(
        top: 24,
        bottom: 20,
        left: 12,
        right: 12,
      );
      tester.view.viewPadding = const FakeViewPadding(
        top: 24,
        bottom: 20,
        left: 12,
        right: 12,
      );
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPadding);
      addTearDown(tester.view.resetViewPadding);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      final semantics = tester.ensureSemantics();
      try {
        await tester.pumpWidget(host());
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<ExperienceIllustration>(
                find.byType(ExperienceIllustration),
              )
              .progress,
          1,
        );
        final action = tester
            .getSemantics(find.byKey(const ValueKey('experience-lid-action')))
            .getSemanticsData();
        expect('${action.label} ${action.tooltip}', contains('Close the lid'));
        expect(find.text('A cabinet for tiny wonders'), findsOneWidget);
        final footer = tester.getRect(
          find.byKey(const ValueKey('experience-footer-scroll')),
        );
        expect(footer.bottom, closeTo(580, .01));
        expect(footer.left, greaterThanOrEqualTo(12));
        expect(tester.binding.transientCallbackCount, 0);
      } finally {
        semantics.dispose();
      }
    },
  );
  testWidgets(
    'native form and fixed footer survive width height and text reflow',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1280, 800);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await tester.pumpWidget(host());
      await tester.pumpAndSettle();
      final field = find.byKey(const ValueKey('experience-note'));
      await tester.ensureVisible(field);
      await tester.enterText(field, 'A little wonder, in our own words');
      final element = tester.element(field);
      final focus = tester
          .widget<EditableText>(find.byType(EditableText))
          .focusNode;
      for (final size in [
        const Size(320, 800),
        const Size(720, 360),
        const Size(1280, 720),
      ]) {
        tester.view.physicalSize = size;
        tester.platformDispatcher.textScaleFactorTestValue = 2.5;
        await tester.pumpAndSettle();
        expect(tester.element(field), same(element));
        expect(focus.hasFocus, isTrue);
        expect(find.text('A little wonder, in our own words'), findsOneWidget);
        expect(
          find.ancestor(of: field, matching: find.byType(FittedBox)),
          findsNothing,
        );
        final footer = find.byKey(const ValueKey('experience-continue'));
        final before = tester.getRect(footer);
        expect(before.bottom, lessThanOrEqualTo(size.height));
        final body = tester.state<ScrollableState>(
          find
              .descendant(
                of: find.byKey(const ValueKey('experience-body-scroll')),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        body.position.jumpTo(body.position.maxScrollExtent);
        await tester.pumpAndSettle();
        expect(tester.getRect(footer), before);
        await tester.tap(footer);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        focus.requestFocus();
        await tester.pumpAndSettle();
      }
      expect(find.text('Preview actions 3'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets(
    'keyboard is consumed once and keeps footer and focused caret reachable',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(360, 800);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpWidget(host());
      await tester.pumpAndSettle();
      final field = find.byKey(const ValueKey('experience-note'));
      await tester.ensureVisible(field);
      await tester.enterText(field, 'A blue feather');
      final element = tester.element(field);
      tester.view.viewInsets = const FakeViewPadding(bottom: 320);
      await tester.pumpAndSettle();
      await tester.ensureVisible(field);
      await tester.pumpAndSettle();
      final footer = tester.getRect(
        find.byKey(const ValueKey('experience-footer-scroll')),
      );
      expect(footer.bottom, closeTo(480, .01));
      final editable = tester.state<EditableTextState>(
        find.byType(EditableText),
      );
      final caret = editable.renderEditable.getLocalRectForCaret(
        editable.widget.controller.selection.extent,
      );
      expect(
        editable.renderEditable.localToGlobal(caret.bottomCenter).dy,
        lessThanOrEqualTo(footer.top),
      );
      expect(editable.widget.focusNode.hasFocus, isTrue);
      tester.view.viewInsets = const FakeViewPadding();
      await tester.pumpAndSettle();
      expect(tester.element(field), same(element));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets(
    'mapped lid target uses authored pose and stays 48px at every fit',
    (tester) async {
      var taps = 0;
      for (final size in [const Size(208, 208), const Size(560, 420)]) {
        for (final progress in [0.0, .45, 1.0]) {
          final artKey = GlobalKey();
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: Align(
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    key: artKey,
                    width: size.width,
                    height: size.height,
                    child: ExperienceIllustration(
                      progress: progress,
                      onToggle: () => taps++,
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          final destination = experienceArtworkRect(size);
          final point = importedLidPart(
            progress: progress,
          ).mapSourcePoint(lidSourceRect.center);
          final expected =
              tester.getTopLeft(find.byKey(artKey)) +
              destination.topLeft +
              Offset(
                point.dx * destination.width / 400,
                point.dy * destination.height / 400,
              );
          final action = find.byKey(const ValueKey('experience-lid-action'));
          expect(tester.getSize(action).width, closeTo(48, 1e-8));
          expect(tester.getSize(action).height, closeTo(48, 1e-8));
          expect(tester.getCenter(action), offsetMoreOrLessEquals(expected));
          final before = taps;
          await tester.tapAt(expected);
          await tester.pumpAndSettle();
          expect(taps, before + 1);
          expect(tester.takeException(), isNull);
        }
      }
    },
  );
  testWidgets(
    'critical footer overflow scrolls without clipping native text or losing the body',
    (tester) async {
      int? activated;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 120,
              child: ExperienceFrame(
                heading: const Text('A native heading'),
                illustration: const SizedBox(),
                content: const Text('Native content'),
                footer: Column(
                  children: [
                    for (var i = 0; i < 5; i++)
                      SizedBox(
                        height: 48,
                        child: TextButton(
                          onPressed: () => activated = i,
                          child: Text('Action $i'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final footer = find.byKey(const ValueKey('experience-footer-scroll'));
      final scroll = tester.state<ScrollableState>(
        find.descendant(of: footer, matching: find.byType(Scrollable)).first,
      );
      expect(scroll.position.maxScrollExtent, greaterThan(0));
      expect(
        tester
            .getSize(find.byKey(const ValueKey('experience-body-scroll')))
            .height,
        greaterThanOrEqualTo(60),
      );
      await tester.ensureVisible(find.text('Action 4'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Action 4'));
      expect(activated, 4);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
