import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcrafted_example/pillow_study.dart';
import 'package:handcrafted_example/stuffed_shapes.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

Future<Uint8List> render(
  PlushPillowGeometry geometry,
  PlushFabric fabric, {
  CraftLight? light,
  bool sewing = true,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder)..translate(10, 10);
  geometry.paint(
    canvas,
    light ?? plushPillowLight(),
    fabric: fabric,
    color: const Color(0xFF9FC5DC),
    sewing: sewing,
  );
  final picture = recorder.endRecording();
  try {
    final image = await picture.toImage(132, 132);
    try {
      final bytes = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      return Uint8List.fromList(bytes!.buffer.asUint8List());
    } finally {
      image.dispose();
    }
  } finally {
    picture.dispose();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'two retained fabrics relight and fill independently and repeat by seed',
    () async {
      final cut = pillowCut(PillowShape.star);
      final full = PlushPillowGeometry(cut, filling: 1);
      final thin = PlushPillowGeometry(cut, filling: 0);
      final short = await render(full, PlushFabric.shortPile);
      final sherpa = await render(full, PlushFabric.sherpa);
      expect(sherpa, isNot(short));
      for (final fabric in PlushFabric.values) {
        final initial = await render(full, fabric);
        expect(await render(thin, fabric), isNot(initial));
        expect(
          await render(full, fabric, light: plushPillowLight(fromRight: true)),
          isNot(initial),
        );
        expect(await render(full, fabric, sewing: false), isNot(initial));
        expect(
          await render(PlushPillowGeometry(cut, filling: 1), fabric),
          initial,
        );
      }
      cut.reset();
      expect(await render(full, PlushFabric.sherpa), sherpa);
      expect(
        await render(
          PlushPillowGeometry(
            pillowCut(PillowShape.star),
            filling: 1,
            seed: 72,
          ),
          PlushFabric.sherpa,
        ),
        isNot(sherpa),
      );
    },
  );

  testWidgets(
    'the mounted specimen paints the selected prepared fabric and filling',
    (tester) async {
      var fabric = PlushFabric.shortPile;
      var filling = 1.0;
      late StateSetter update;
      await tester.pumpWidget(
        MaterialApp(
          home: Center(
            child: StatefulBuilder(
              builder: (context, set) {
                update = set;
                return PlushPillow(
                  fabric: fabric,
                  filling: filling,
                  size: 132,
                  sewing: true,
                );
              },
            ),
          ),
        ),
      );
      Future<Uint8List> actual() async {
        final boundary = tester.renderObject<RenderRepaintBoundary>(
          find.descendant(
            of: find.byType(PlushPillow),
            matching: find.byType(RepaintBoundary),
          ),
        );
        final image = await boundary.toImage(pixelRatio: 1);
        try {
          final bytes = await image.toByteData(
            format: ui.ImageByteFormat.rawRgba,
          );
          return Uint8List.fromList(bytes!.buffer.asUint8List());
        } finally {
          image.dispose();
        }
      }

      for (final recipe in [
        (PlushFabric.shortPile, 1.0),
        (PlushFabric.sherpa, 1.0),
        (PlushFabric.sherpa, .25),
      ]) {
        update(() {
          fabric = recipe.$1;
          filling = recipe.$2;
        });
        await tester.pump();
        final expected = await tester.runAsync(
          () => render(
            PlushPillowGeometry(pillowCut(PillowShape.star), filling: filling),
            fabric,
          ),
        );
        final painted = await tester.runAsync(actual);
        expect(painted, isNotNull);
        expect(painted, expected);
      }
      await tester.pumpWidget(const SizedBox());
    },
  );

  test(
    'padding supports concave cuts, copies them and rejects unbounded input',
    () async {
      for (final shape in PillowShape.values) {
        final geometry = PlushPillowGeometry(pillowCut(shape));
        expect(await render(geometry, PlushFabric.sherpa), isNotEmpty);
      }
      for (final value in [-1.0, double.nan, double.infinity, 1.1]) {
        expect(
          () =>
              PlushPillowGeometry(pillowCut(PillowShape.star), filling: value),
          throwsArgumentError,
        );
      }
      expect(
        () => PlushPillowGeometry(
          Path()..addRect(const Rect.fromLTWH(0, 0, 321, 10)),
        ),
        throwsArgumentError,
      );
      final geometry = PlushPillowGeometry(pillowCut(PillowShape.star));
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder)..translate(3, 5);
      final count = canvas.getSaveCount();
      final matrix = canvas.getTransform();
      try {
        expect(
          () => geometry.paint(
            canvas,
            plushPillowLight(),
            fabric: PlushFabric.sherpa,
            color: const Color(0x80FFFFFF),
          ),
          throwsArgumentError,
        );
        expect(canvas.getSaveCount(), count);
        expect(canvas.getTransform(), matrix);
      } finally {
        recorder.endRecording().dispose();
      }
    },
  );

  testWidgets(
    'native padding and shared light update both fabrics at large text',
    (tester) async {
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
                  child: PlushPillowStudy(),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final slider = find.byType(Slider);
        await tester.ensureVisible(slider);
        await tester.tap(slider);
        await tester.pumpAndSettle();
        final value = tester.widget<Slider>(slider).value;
        expect(value, closeTo(.5, .1));
        expect(
          tester
              .widgetList<PlushPillow>(find.byType(PlushPillow))
              .every((w) => w.filling == value),
          isTrue,
        );
        tester.widget<Slider>(slider).focusNode!.requestFocus();
        await tester.pump();
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
        await tester.pumpAndSettle();
        final next = tester.widget<Slider>(slider).value;
        expect(next, greaterThan(value));
        expect(
          tester
              .widgetList<PlushPillow>(find.byType(PlushPillow))
              .every((w) => w.filling == next),
          isTrue,
        );
        final toggle = find.byType(SwitchListTile);
        await tester.ensureVisible(toggle);
        await tester.tap(toggle);
        await tester.pumpAndSettle();
        expect(
          tester
              .widgetList<PlushPillow>(find.byType(PlushPillow))
              .every((w) => w.light!.x > 0),
          isTrue,
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      }
    },
  );
}
