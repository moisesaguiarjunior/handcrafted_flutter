import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcrafted_example/main_gallery.dart';
import 'package:handcrafted_example/spatial_light_study.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

StudioPainter painter(WidgetTester t) =>
    t.widget<CustomPaint>(find.byKey(const ValueKey('studio-board'))).painter!
        as StudioPainter;
void main() {
  test(
    'near overhead lamp changes intensity and rotation keeps world light fixed',
    () {
      final center = studioCenters[0];
      final near = StudioLamp(position: center, height: 80).sample(center, 0);
      final far = StudioLamp(position: center, height: 480).sample(center, 0);
      expect(near.direct, greaterThan(far.direct));
      final lamp = StudioLamp(position: center + const Offset(110, -60));
      final world = lamp.sample(center, 0), local = lamp.sample(center, .71);
      expect(
        local.x * math.cos(.71) - local.y * math.sin(.71),
        closeTo(world.x, 1e-12),
      );
      expect(
        local.x * math.sin(.71) + local.y * math.cos(.71),
        closeTo(world.y, 1e-12),
      );
      for (final x in [24.0, 616.0]) {
        for (final y in [24.0, 336.0]) {
          for (final h in [80.0, 480.0]) {
            for (final p in studioCenters) {
              StudioLamp(position: Offset(x, y), height: h).sample(p, 1.5);
            }
          }
        }
      }
    },
  );
  testWidgets(
    'drag, shape, height and rotation retain prepared geometry and lamp position',
    (t) async {
      await t.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: SpatialLightStudy()),
          ),
        ),
      );
      await t.pumpAndSettle();
      final before = painter(t);
      final gesture = await t.startGesture(
        t.getCenter(find.byKey(const ValueKey('studio-lamp'))),
      );
      await gesture.moveBy(const Offset(25, 0));
      await t.pump();
      await gesture.moveBy(const Offset(65, 20));
      await gesture.up();
      await t.pump();
      final moved = painter(t);
      expect(moved.lamp.position, isNot(before.lamp.position));
      for (final key in ['studio-height', 'studio-rotation']) {
        t.widget<Slider>(find.byKey(ValueKey(key))).onChanged!(
          key == 'studio-height' ? 80 : 60,
        );
        await t.pump();
      }
      await t.ensureVisible(find.byKey(const ValueKey('studio-shape')));
      await t.tap(find.byKey(const ValueKey('studio-shape')));
      await t.pump();
      final after = painter(t);
      expect(after.lamp.position, moved.lamp.position);
      expect(after.lamp.height, 80);
      expect(after.rotations[0], closeTo(math.pi / 3, 1e-12));
      expect(after.rotations.sublist(1), before.rotations.sublist(1));
      expect(after.shapes, [1, 0, 0]);
      expect(after.cuts, same(before.cuts));
      expect(t.takeException(), isNull);
    },
  );
  testWidgets('narrow enlarged layout retains adjustable controls', (t) async {
    final semantics = t.ensureSemantics();

    t.view.physicalSize = const Size(320, 1100);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.resetPhysicalSize);
    addTearDown(t.view.resetDevicePixelRatio);
    await t.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(2.5)),
        child: HandcraftedGalleryApp(initialStudy: GalleryStudy.light),
      ),
    );
    await t.pumpAndSettle();
    expect(t.takeException(), isNull);
    for (final key in [
      'studio-x',
      'studio-y',
      'studio-height',
      'studio-rotation',
    ]) {
      final control = find.byKey(ValueKey(key));
      await t.ensureVisible(control);
      await t.pump();
      expect(
        t
            .getSemantics(control)
            .getSemanticsData()
            .hasAction(ui.SemanticsAction.increase),
        isTrue,
      );
    }
    expect(
      t.getSize(find.byKey(const ValueKey('studio-lamp'))),
      const Size(48, 48),
    );
    await t.pumpWidget(const SizedBox());
    expect(t.binding.transientCallbackCount, 0);
    semantics.dispose();
  });
  test(
    'real raster reacts to distance and rotation deterministically',
    () async {
      final cuts = StudioCuts(), textures = MaterialTextures(seed: 71);
      addTearDown(textures.dispose);
      Future<List<int>> render(StudioLamp lamp, double rotation) async {
        final recorder = ui.PictureRecorder();
        StudioPainter(
          textures: textures,
          cuts: cuts,
          lamp: lamp,
          shapes: [0, 0, 0],
          rotations: [rotation, 0, 0],
        ).paint(Canvas(recorder), const Size(640, 360));
        final picture = recorder.endRecording();
        final image = await picture.toImage(640, 360);
        try {
          return (await image.toByteData())!.buffer.asUint8List().toList();
        } finally {
          image.dispose();
          picture.dispose();
        }
      }

      final near = StudioLamp(position: studioCenters[0], height: 80);
      final a = await render(near, 0);
      expect(
        await render(StudioLamp(position: studioCenters[0], height: 480), 0),
        isNot(a),
      );
      expect(await render(near, .7), isNot(a));
      expect(await render(near, 0), a);
    },
  );
}
