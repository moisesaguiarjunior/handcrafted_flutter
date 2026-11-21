import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late MemoryImage provider;
  const sourceSize = Size(100, 60), crop = Rect.fromLTWH(30, 10, 40, 20);
  const hinge = Offset(35, 15), mark = Offset(61, 17);
  setUpAll(() async {
    final recorder = ui.PictureRecorder(), canvas = Canvas(recorder);
    canvas.drawColor(const Color(0xFF0000FF), BlendMode.src);
    canvas.drawRect(crop, Paint()..color = const Color(0xFFFF0000));
    canvas.drawRect(
      const Rect.fromLTWH(58, 14, 6, 6),
      Paint()..color = const Color(0xFF00FF00),
    );
    final picture = recorder.endRecording(),
        image = await picture.toImage(100, 60);
    try {
      provider = MemoryImage(
        Uint8List.fromList(
          (await image.toByteData(
            format: ui.ImageByteFormat.png,
          ))!.buffer.asUint8List(),
        ),
      );
    } finally {
      image.dispose();
      picture.dispose();
    }
  });
  tearDownAll(() => provider.evict());

  testWidgets(
    'pose updates retain clipping; new masks and crops invalidate it',
    (tester) async {
      final mask = Path()..addRect(crop);
      Future<CustomClipper<Path>> mount(
        Path path,
        Rect source,
        double angle,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Stack(
              children: [
                CraftImagePart(
                  key: const ValueKey('stable-mask'),
                  image: provider,
                  sourceSize: sourceSize,
                  sourceRect: source,
                  rect: const Rect.fromLTWH(30, 30, 80, 40),
                  sourceClip: path,
                  pose: PartPose(rotation: angle),
                ),
              ],
            ),
          ),
        );
        await tester.pumpAndSettle();
        return tester
            .widget<ClipPath>(
              find.descendant(
                of: find.byType(CraftImagePart),
                matching: find.byType(ClipPath),
              ),
            )
            .clipper!;
      }

      var prior = await mount(mask, crop, 0);
      final original = prior.getClip(const Size(80, 40));
      for (var i = 1; i <= 60; i++) {
        final current = await mount(mask, crop, i * .01);
        expect(current.shouldReclip(prior), isFalse);
        prior = current;
      }
      final changed = await mount(Path()..addOval(crop), crop, 0);
      expect(changed.shouldReclip(prior), isTrue);
      expect(
        changed.getClip(const Size(80, 40)).contains(const Offset(1, 1)),
        isFalse,
      );
      final moved = await mount(mask, const Rect.fromLTWH(20, 10, 40, 20), 0);
      expect(moved.shouldReclip(changed), isTrue);
      expect(moved.shouldReclip(prior), isTrue);
      expect(original.contains(const Offset(1, 1)), isTrue);
      await tester.pumpWidget(const SizedBox());
    },
  );

  Offset expected(Offset source, Rect rect, PartPose pose) {
    final sx = rect.width / crop.width, sy = rect.height / crop.height;
    final anchor = Offset(
      (hinge.dx - crop.left) * sx,
      (hinge.dy - crop.top) * sy,
    );
    final delta =
        Offset((source.dx - hinge.dx) * sx, (source.dy - hinge.dy) * sy) *
        pose.scale;
    return rect.topLeft +
        anchor +
        pose.translation +
        Offset(
          delta.dx * math.cos(pose.rotation) -
              delta.dy * math.sin(pose.rotation),
          delta.dx * math.sin(pose.rotation) +
              delta.dy * math.cos(pose.rotation),
        );
  }

  testWidgets(
    'crop, mapped mark and native touch share the pose at two sizes',
    (tester) async {
      var taps = 0;
      final boundaryKey = GlobalKey();
      for (final scale in [1.0, .5]) {
        for (final angle in [0.0, .6, -.4]) {
          final rect = Rect.fromLTWH(
            70,
            90,
            160 * scale,
            (angle < 0 ? 60 : 80) * scale,
          );
          final pose = PartPose(
            rotation: angle,
            scale: 1.2,
            translation: const Offset(12, 8),
          );
          final part = CraftImagePart(
            key: const ValueKey('sample'),
            image: provider,
            sourceSize: sourceSize,
            sourceRect: crop,
            sourceHinge: hinge,
            rect: rect,
            pose: pose,
            filterQuality: FilterQuality.none,
            child: TextButton(
              onPressed: () => taps++,
              style: TextButton.styleFrom(padding: const EdgeInsets.all(10)),
              child: Semantics(
                label: 'Select the crop',
                child: SizedBox.expand(),
              ),
            ),
          );
          await tester.pumpWidget(
            MaterialApp(
              home: Material(
                color: Colors.black,
                child: Align(
                  alignment: Alignment.topLeft,
                  child: RepaintBoundary(
                    key: boundaryKey,
                    child: SizedBox(
                      width: 400,
                      height: 340,
                      child: Stack(children: [part]),
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.runAsync(
            () => precacheImage(
              provider,
              tester.element(find.byType(Image).first),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          final local = expected(mark, rect, pose);
          expect(part.mapSourcePoint(mark), offsetMoreOrLessEquals(local));
          final boundary = tester.renderObject<RenderRepaintBoundary>(
            find.byKey(boundaryKey),
          );
          final bytes = await tester.runAsync(() async {
            final bitmap = await boundary.toImage(pixelRatio: 1);
            try {
              return Uint8List.fromList(
                (await bitmap.toByteData(
                  format: ui.ImageByteFormat.rawRgba,
                ))!.buffer.asUint8List(),
              );
            } finally {
              bitmap.dispose();
            }
          });
          final offset = (local.dy.floor() * 400 + local.dx.floor()) * 4;
          expect(bytes!.sublist(offset, offset + 4), [
            0,
            255,
            0,
            255,
          ], reason: 'Overlay padding must not move the imported pixels');
          final before = taps;
          await tester.tapAt(
            tester.getTopLeft(find.byKey(boundaryKey)) + local,
          );
          await tester.pumpAndSettle();
          expect(taps, before + 1);
          expect(tester.binding.hasScheduledFrame, isFalse);
        }
      }
    },
  );

  testWidgets(
    'source clip excludes holes from touch and keeps real regions and native focus',
    (tester) async {
      var taps = 0;
      final focus = FocusNode();
      final clip = Path()
        ..fillType = PathFillType.evenOdd
        ..addRect(crop)
        ..addRect(const Rect.fromLTWH(40, 20, 5, 5));
      Future<void> show(double rotation) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 340,
                child: Stack(
                  children: [
                    CraftImagePart(
                      key: const ValueKey('clipped'),
                      image: provider,
                      sourceSize: sourceSize,
                      sourceRect: crop,
                      sourceHinge: hinge,
                      rect: const Rect.fromLTWH(70, 90, 160, 80),
                      sourceClip: clip,
                      pose: PartPose(rotation: rotation),
                      child: TextButton(
                        focusNode: focus,
                        onPressed: () => taps++,
                        child: Semantics(
                          label: 'Open specimen',
                          child: SizedBox.expand(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
      }

      await show(.4);
      final hole = expected(
        const Offset(42, 22),
        const Rect.fromLTWH(70, 90, 160, 80),
        PartPose(rotation: .4),
      );
      await tester.tapAt(hole);
      await tester.pumpAndSettle();
      expect(taps, 0);
      await tester.tapAt(
        expected(
          mark,
          const Rect.fromLTWH(70, 90, 160, 80),
          PartPose(rotation: .4),
        ),
      );
      await tester.pumpAndSettle();
      expect(taps, 1);
      focus.requestFocus();
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(taps, 2);
      await show(-.3);
      expect(focus.hasFocus, isTrue);
      expect(find.bySemanticsLabel('Open specimen'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      focus.dispose();
    },
  );

  testWidgets(
    'mask changes retain child-owned editable state in both directions',
    (tester) async {
      Future<void> show(Path? clip) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 400,
                height: 340,
                child: Stack(
                  children: [
                    CraftImagePart(
                      key: const ValueKey('editable-image'),
                      image: provider,
                      sourceSize: sourceSize,
                      sourceRect: crop,
                      rect: const Rect.fromLTWH(40, 60, 240, 100),
                      sourceClip: clip,
                      child: const TextField(
                        decoration: InputDecoration(labelText: 'Note'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        await tester.pump();
      }

      await show(null);
      await tester.enterText(find.byType(TextField), 'Keep this note');
      final editable = tester.element(find.byType(EditableText));
      for (final clip in [Path()..addRect(crop), null, Path()..addRect(crop)]) {
        await show(clip);
        expect(find.text('Keep this note'), findsOneWidget);
        expect(tester.element(find.byType(EditableText)), same(editable));
        expect(
          tester
              .widget<EditableText>(find.byType(EditableText))
              .focusNode
              .hasFocus,
          isTrue,
        );
      }
      await tester.pumpWidget(const SizedBox());
    },
  );

  test(
    'identity defaults and invalid source/destination/attachments are explicit',
    () {
      CraftImagePart part({
        Size size = sourceSize,
        Rect source = crop,
        Rect target = const Rect.fromLTWH(10, 20, 80, 40),
        Offset? pivot,
      }) => CraftImagePart(
        key: const ValueKey('mapping'),
        image: provider,
        sourceSize: size,
        sourceRect: source,
        rect: target,
        sourceHinge: pivot,
      );
      expect(part().mapSourcePoint(const Offset(40, 20)), const Offset(30, 40));
      expect(
        () => part(
          source: const Rect.fromLTWH(90, 10, 40, 20),
        ).mapSourcePoint(mark),
        throwsArgumentError,
      );
      expect(
        () => part(size: Size.zero).mapSourcePoint(mark),
        throwsArgumentError,
      );
      expect(
        () => part(target: Rect.zero).mapSourcePoint(mark),
        throwsArgumentError,
      );
      expect(
        () => part(pivot: const Offset(double.nan, 0)).mapSourcePoint(mark),
        throwsArgumentError,
      );
      expect(
        () => part().mapSourcePoint(const Offset(double.infinity, 0)),
        throwsArgumentError,
      );
    },
  );
}
