import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

const _source = Rect.fromLTWH(0, 0, 140, 100);
const _visible = Rect.fromLTWH(26, 18, 80, 60);
const _marker = Rect.fromLTWH(17, 31, 8, 8);

void _art(Canvas canvas) {
  canvas.drawRect(_visible, Paint()..color = const Color(0xFFB46D53));
  canvas.drawRect(_marker, Paint()..color = const Color(0xFF00FF00));
}

class _Vector extends CustomPainter {
  _Vector(this.placement);
  final CraftPlacement placement;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    try {
      canvas.scale(placement.scaleX, placement.scaleY);
      canvas.translate(-placement.sourceRect.left, -placement.sourceRect.top);
      _art(canvas);
    } finally {
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_Vector old) => true;
}

void main() {
  late MemoryImage image;
  setUpAll(() async {
    final recorder = ui.PictureRecorder();
    _art(Canvas(recorder));
    final picture = recorder.endRecording(),
        raster = await picture.toImage(140, 100);
    try {
      image = MemoryImage(
        Uint8List.fromList(
          (await raster.toByteData(
            format: ui.ImageByteFormat.png,
          ))!.buffer.asUint8List(),
        ),
      );
    } finally {
      raster.dispose();
      picture.dispose();
    }
  });
  tearDownAll(() => image.evict());
  testWidgets(
    'padded raster and procedural cut share pose, native hit and retained outside paint',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      // Warm the provider before mounting an image. Starting its decode in the
      // test's fake-async widget build can leave a browser codec waiting for time.
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      await tester.runAsync(
        () => precacheImage(image, tester.element(find.byType(SizedBox).first)),
      );
      for (final width in [320.0, 390.0, 428.0]) {
        tester.view.physicalSize = Size(width, 350);
        for (final angle in [-.4, 0.0, .4]) {
          final placement = CraftPlacement.fit(
            sourceRect: _source,
            visibleBounds: _visible,
            target: Rect.fromLTWH(width * .35, 80, width * .3, 90),
            pose: PartPose(rotation: angle, translation: const Offset(3, 2)),
          );
          for (final raster in [true, false]) {
            final boundary = GlobalKey();
            var taps = 0;
            final anchor = Offset(
              (66 - _source.left) * placement.scaleX,
              (48 - _source.top) * placement.scaleY,
            );
            final overlay = Stack(
              children: [
                Positioned(
                  left: anchor.dx - 24,
                  top: anchor.dy - 24,
                  width: 48,
                  height: 48,
                  child: TextButton(
                    onPressed: () => taps++,
                    child: const Text('Go'),
                  ),
                ),
              ],
            );
            final part = raster
                ? CraftImagePart.placed(
                    key: const ValueKey('placed-image'),
                    image: image,
                    sourceSize: _source.size,
                    placement: placement,
                    child: overlay,
                  )
                : Positioned.fromRect(
                    rect: placement.rect,
                    child: CraftPart(
                      key: const ValueKey('placed-vector'),
                      size: placement.rect.size,
                      pose: placement.pose,
                      pivot: placement.pivot,
                      child: ClipRect(
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CustomPaint(painter: _Vector(placement)),
                            overlay,
                          ],
                        ),
                      ),
                    ),
                  );
            await tester.pumpWidget(
              MaterialApp(
                home: RepaintBoundary(
                  key: boundary,
                  child: Scaffold(body: Stack(children: [part])),
                ),
              ),
            );
            await tester.runAsync(
              () => precacheImage(image, tester.element(find.byType(Scaffold))),
            );
            await tester.pumpAndSettle();
            // The independent expected hinge is the fitted target's center + translation.
            final expected = Offset(width * .5 + 3, 125 + 2);
            expect(
              (placement.mapSourcePoint(const Offset(66, 48)) - expected)
                  .distance,
              lessThan(1e-7),
            );
            await tester.tapAt(expected);
            await tester.pumpAndSettle();
            expect(taps, 1);
            final mark = placement.mapSourcePoint(_marker.center);
            final render =
                boundary.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary;
            final bytes = (await tester.runAsync(() async {
              final snapshot = await render.toImage();
              try {
                return Uint8List.fromList(
                  (await snapshot.toByteData())!.buffer.asUint8List(),
                );
              } finally {
                snapshot.dispose();
              }
            }))!;
            final index =
                (mark.dy.floor() * width.toInt() + mark.dx.floor()) * 4;
            expect(
              bytes[index + 1],
              greaterThan(240),
              reason: 'full source margin was trimmed',
            );
            expect(bytes[index], lessThan(20));
            expect(tester.takeException(), isNull);
            await tester.pumpWidget(const SizedBox());
          }
        }
      }
    },
  );
}
