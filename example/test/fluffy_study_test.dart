import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcrafted_example/fluffy_study.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

void main() {
  testWidgets(
    'each adjustable node names its control and speaks actual units',
    (tester) async {
      final semantics = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(child: FluffyMaterialsStudy()),
            ),
          ),
        );
        await tester.pumpAndSettle();
        for (final pair in [
          ('Fiber length', '3.50 times'),
          ('Curl', '65 percent'),
          ('Edge fuzz', '80 percent'),
          ('Density', '100 percent'),
        ]) {
          final slider = find.byKey(ValueKey(pair.$1));
          await tester.ensureVisible(slider);
          await tester.pumpAndSettle();
          final data = tester.getSemantics(slider).getSemanticsData();
          expect(data.label, contains(pair.$1));
          expect(data.value, pair.$2);
        }
        await tester.pumpWidget(const SizedBox());
      } finally {
        semantics.dispose();
      }
    },
  );

  testWidgets('native finish controls repaint both shapes at enlarged text', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    for (final size in [
      const Size(320, 700),
      const Size(390, 844),
      const Size(428, 320),
    ]) {
      tester.view.physicalSize = size;
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(2)),
            child: child!,
          ),
          home: const Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: FluffyMaterialsStudy(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      Future<Uint8List> actual() async {
        final boundary = tester.renderObject<RenderRepaintBoundary>(
          find.descendant(
            of: find.byType(FluffySwatch).last,
            matching: find.byType(RepaintBoundary),
          ),
        );
        final image = await boundary.toImage(pixelRatio: 1);
        try {
          final bytes = await image.toByteData();
          return Uint8List.fromList(bytes!.buffer.asUint8List());
        } finally {
          image.dispose();
        }
      }

      final before = await tester.runAsync(actual);
      final length = find.byKey(const ValueKey('Fiber length'));
      await tester.ensureVisible(length);
      await tester.tapAt(
        tester.getRect(length).centerLeft + const Offset(25, 0),
      );
      await tester.pumpAndSettle();
      tester.widget<Slider>(length).focusNode!.requestFocus();
      await tester.pump();
      final previous = tester.widget<Slider>(length).value;
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
      await tester.pumpAndSettle();
      final next = tester.widget<Slider>(length).value;
      expect(next, greaterThan(previous));
      expect(
        tester
            .widgetList<FluffySwatch>(find.byType(FluffySwatch))
            .every((w) => w.fiberLength == next),
        isTrue,
      );
      final after = await tester.runAsync(actual);
      expect(before, isNotNull);
      expect(after, isNotNull);
      expect(after, isNot(before));
      final dropdown = find.byType(DropdownButtonFormField<CraftMaterial>);
      await tester.ensureVisible(dropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownButton<CraftMaterial>));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('leather'),
        100,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('leather').last);
      await tester.pumpAndSettle();
      expect(
        tester
            .widgetList<FluffySwatch>(find.byType(FluffySwatch))
            .every((w) => w.material == CraftMaterial.leather),
        isTrue,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    }
  });
}
