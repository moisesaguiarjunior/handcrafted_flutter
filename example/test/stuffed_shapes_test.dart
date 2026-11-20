import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcrafted_example/pillow_study.dart';
import 'package:handcrafted_example/stuffed_shapes.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

Future<Uint8List> _render(
  StuffedShapeGeometry shape,
  MaterialTextures textures, {
  PillowFabric fabric = PillowFabric.cotton,
  CraftLight? light,
  bool seamOnly = false,
  bool sewing = true,
  double compression = .14,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawColor(const Color(0xFFF4EFE6), BlendMode.src);
  canvas.translate(10, 10);
  if (seamOnly) {
    shape.seam.paint(canvas, thread: Colors.white, width: .65, compression: 0);
  } else {
    shape.paint(
      canvas,
      textures,
      light ?? CraftLight(),
      fabric: fabric,
      color: const Color(0xFFE0A84A),
      sewing: sewing,
      compression: compression,
    );
  }
  final picture = recorder.endRecording();
  try {
    final image = await picture.toImage(140, 140);
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (data == null) throw StateError('RGBA readback failed');
      return Uint8List.fromList(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      );
    } finally {
      image.dispose();
    }
  } finally {
    picture.dispose();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  for (final shape in PillowShape.values) {
    test(
      '$shape filling changes volume pixels but preserves sewn pattern',
      () async {
        final textures = MaterialTextures(seed: 71);
        final empty = StuffedShapeGeometry(pillowCut(shape), filling: 0);
        final full = StuffedShapeGeometry(pillowCut(shape), filling: 1);
        try {
          expect(
            await _render(full, textures),
            isNot(await _render(empty, textures)),
          );
          expect(
            await _render(full, textures, seamOnly: true),
            await _render(empty, textures, seamOnly: true),
          );
          expect(
            await _render(full, textures, sewing: false),
            isNot(await _render(full, textures)),
          );
        } finally {
          textures.dispose();
        }
      },
    );
  }

  test(
    'one prepared moon supports distinct fabrics, lighting and seam pressure',
    () async {
      final geometry = StuffedShapeGeometry(pillowCut(PillowShape.moon));
      final textures = MaterialTextures(seed: 71);
      try {
        final original = await _render(geometry, textures);
        for (final fabric in [PillowFabric.felt, PillowFabric.shortPile]) {
          expect(
            await _render(geometry, textures, fabric: fabric),
            isNot(original),
          );
        }
        expect(
          await _render(geometry, textures, light: CraftLight(x: 1.5, y: .5)),
          isNot(original),
        );
        expect(
          await _render(geometry, textures, compression: .7),
          isNot(original),
        );
        expect(await _render(geometry, textures), original);
      } finally {
        textures.dispose();
      }
    },
  );

  test(
    'caller cut mutation cannot change prepared body, fibers or stitches',
    () async {
      final source = pillowCut(PillowShape.sun);
      final geometry = StuffedShapeGeometry(source);
      final textures = MaterialTextures(seed: 71);
      try {
        final original = await _render(
          geometry,
          textures,
          fabric: PillowFabric.shortPile,
        );
        source.reset();
        source.addRect(const Rect.fromLTWH(0, 0, 10, 10));
        expect(
          await _render(geometry, textures, fabric: PillowFabric.shortPile),
          original,
        );
      } finally {
        textures.dispose();
      }
    },
  );

  test(
    'invalid filling fails before preparation and invalid alpha before paint',
    () {
      for (final value in [-.1, 1.1, double.nan, double.infinity]) {
        expect(
          () =>
              StuffedShapeGeometry(pillowCut(PillowShape.star), filling: value),
          throwsArgumentError,
        );
      }
      final geometry = StuffedShapeGeometry(pillowCut(PillowShape.star));
      final textures = MaterialTextures();
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      try {
        expect(
          () => geometry.paint(
            canvas,
            textures,
            CraftLight(),
            fabric: PillowFabric.cotton,
            color: const Color(0x80FFFFFF),
          ),
          throwsArgumentError,
        );
      } finally {
        recorder.endRecording().dispose();
        textures.dispose();
      }
    },
  );

  testWidgets('actual painter restores the canvas after a resource error', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(child: StuffedShape(shape: PillowShape.star)),
      ),
    );
    final painter = tester
        .widget<CustomPaint>(
          find.descendant(
            of: find.byType(StuffedShape),
            matching: find.byType(CustomPaint),
          ),
        )
        .painter!;
    await tester.pumpWidget(const SizedBox());
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder)..translate(3, 5);
    final count = canvas.getSaveCount(), transform = canvas.getTransform();
    try {
      expect(
        () => painter.paint(canvas, const Size(180, 180)),
        throwsStateError,
      );
      expect(canvas.getSaveCount(), count);
      expect(canvas.getTransform(), transform);
    } finally {
      recorder.endRecording().dispose();
    }
  });

  testWidgets(
    'invalid paint inputs fail in build before a painter is mounted',
    (tester) async {
      for (final invalid in [
        const StuffedShape(shape: PillowShape.star, compression: -1),
        const StuffedShape(shape: PillowShape.star, color: Color(0x80FFFFFF)),
        const StuffedShape(shape: PillowShape.star, size: double.infinity),
      ]) {
        await tester.pumpWidget(MaterialApp(home: invalid));
        expect(tester.takeException(), isArgumentError);
        expect(
          find.descendant(
            of: find.byType(StuffedShape),
            matching: find.byType(CustomPaint),
          ),
          findsNothing,
        );
        await tester.pumpWidget(const SizedBox());
      }
    },
  );

  testWidgets(
    'filling control changes the rendered cushion, not only its label',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SingleChildScrollView(child: PillowStudy())),
        ),
      );
      await tester.pumpAndSettle();
      final slider = find.byType(Slider);
      await tester.drag(slider, const Offset(-500, 0));
      await tester.pumpAndSettle();
      Future<Uint8List> pixels() async {
        final boundary = tester.renderObject<RenderRepaintBoundary>(
          find.byKey(const ValueKey('pillow-star')),
        );
        final image = await boundary.toImage();
        try {
          final data = await image.toByteData(
            format: ui.ImageByteFormat.rawRgba,
          );
          if (data == null) throw StateError('Missing cushion pixels');
          return Uint8List.fromList(
            data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
          );
        } finally {
          image.dispose();
        }
      }

      final empty = await tester.runAsync(pixels);
      await tester.drag(slider, const Offset(500, 0));
      await tester.pumpAndSettle();
      final full = await tester.runAsync(pixels);
      expect(empty, isNotNull);
      expect(full, isNotNull);
      expect(full, isNot(empty));
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'native controls update shapes at enlarged text and narrow/short widths',
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
                  child: PillowStudy(),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final slider = find.byType(Slider);
        await tester.ensureVisible(slider);
        await tester.pumpAndSettle();
        await tester.tap(slider);
        await tester.pumpAndSettle();
        expect(tester.widget<Slider>(slider).value, closeTo(.5, .1));
        await tester.ensureVisible(find.byType(SwitchListTile));
        await tester.tap(find.byType(SwitchListTile));
        await tester.pumpAndSettle();
        expect(
          tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
          isFalse,
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      }
    },
  );
}
