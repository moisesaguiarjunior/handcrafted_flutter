import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcrafted_example/contact_artwork.dart';
import 'package:handcrafted_example/contact_poses.dart';
import 'package:handcrafted_example/contact_study.dart';
import 'package:handcrafted_example/continuous_cloth.dart';
import 'package:handcrafted_example/showcase_theme.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

double cross(Offset a, Offset b) => a.dx * b.dy - a.dy * b.dx;

Future<ui.Image> raster(
  ContinuousClothFrame frame,
  ClothPrint print, {
  bool guides = false,
}) async {
  final recorder = ui.PictureRecorder();
  frame.paint(Canvas(recorder), print, guides: guides);
  final picture = recorder.endRecording();
  try {
    return await picture.toImage(640, 360);
  } finally {
    picture.dispose();
  }
}

void main() {
  test(
    'two cuts keep a pinned source, non-folding patches and constant center length',
    () {
      for (final cut in ClothCut.values) {
        for (var i = 0; i <= 100; i++) {
          final frame = ContinuousClothFrame(i / 100, cut);
          expect(
            (frame.mapSource(Offset(frame.width / 2, 0)) - ClothPose.shoulder)
                .distance,
            lessThan(1e-6),
          );
          expect(
            frame.band.centerline.computeMetrics().single.length,
            closeTo(frame.length, .01),
          );
          for (var row = 0; row < ContinuousClothFrame.intervals; row++) {
            final a = frame.railPoint(row, false),
                b = frame.railPoint(row, true);
            final c = frame.railPoint(row + 1, false),
                d = frame.railPoint(row + 1, true);
            expect(cross(b - a, c - a), greaterThan(1), reason: '$cut $i $row');
            expect(cross(d - b, c - b), greaterThan(1));
          }
        }
        expect(
          ContinuousClothFrame(.25, cut).mapSource(const Offset(20, 70)),
          ContinuousClothFrame(0, cut).mapSource(const Offset(20, 70)),
        );
        expect(
          ContinuousClothFrame(.95, cut).mapSource(const Offset(20, 70)),
          ContinuousClothFrame(1, cut).mapSource(const Offset(20, 70)),
        );
      }
    },
  );

  test(
    'actual printed marks follow mapped coordinates and internal joins stay opaque',
    () async {
      final textures = MaterialTextures(seed: 117);
      try {
        for (final cut in ClothCut.values) {
          final print = ClothPrint.prepare(textures, cut);
          try {
            List<int>? original;
            for (final t in [.5, 1.0, 0.0, .75, .25, .5]) {
              final frame = ContinuousClothFrame(t, cut);
              final image = await raster(frame, print);
              try {
                final bytes = (await image.toByteData())!.buffer.asUint8List();
                List<int> at(Offset point) {
                  final i = (point.dy.floor() * 640 + point.dx.floor()) * 4;
                  return bytes.sublist(i, i + 4);
                }

                for (final y in [48.0, 80.0, 112.0]) {
                  final ink = at(frame.mapSource(Offset(frame.width / 2, y)));
                  final cloth = at(
                    frame.mapSource(Offset(frame.width / 2, y + 7)),
                  );
                  expect(
                    ink[0] - cloth[0],
                    greaterThan(12),
                    reason: '$cut $t y=$y',
                  );
                }
                for (var row = 1; row < ContinuousClothFrame.intervals; row++) {
                  final sourceY =
                      row / ContinuousClothFrame.intervals * frame.length;
                  expect(
                    at(frame.mapSource(Offset(frame.width / 2, sourceY)))[3],
                    255,
                  );
                }
                if (t == .5 && original == null) {
                  original = List.of(bytes);
                } else if (t == .5) {
                  expect(bytes, orderedEquals(original!));
                }
              } finally {
                image.dispose();
              }
            }
            final guided = ContinuousClothFrame(.5, cut);
            final guidedImage = await raster(guided, print, guides: true);
            try {
              final bytes = (await guidedImage.toByteData())!.buffer
                  .asUint8List();
              for (final marker in [
                (0.0, DemoPalette.indigo),
                (guided.length / 2, DemoPalette.terracotta),
                (guided.length, DemoPalette.terracotta),
              ]) {
                final point = guided.mapSource(
                  Offset(guided.width / 2, marker.$1),
                );
                final index = (point.dy.floor() * 640 + point.dx.floor()) * 4;
                final argb = marker.$2.toARGB32();
                expect(
                  bytes.sublist(index, index + 4),
                  [(argb >> 16) & 255, (argb >> 8) & 255, argb & 255, 255],
                  reason: 'Only the shoulder is pinned; the other markers move',
                );
              }
            } finally {
              guidedImage.dispose();
            }
          } finally {
            print.dispose();
          }
          final recorder = ui.PictureRecorder();
          expect(
            () => ContinuousClothFrame(0, cut).paint(Canvas(recorder), print),
            throwsArgumentError,
          );
          recorder.endRecording().dispose();
        }
        // Releasing one print did not release the borrowed material owner.
        final again = ClothPrint.prepare(textures, ClothCut.sleeve);
        again.dispose();
      } finally {
        textures.dispose();
      }
    },
  );

  test(
    'failed source recording disposes its picture without borrowing ownership',
    () {
      final created = <ui.Picture>{}, disposed = <ui.Picture>{};
      final oldCreate = ui.Picture.onCreate, oldDispose = ui.Picture.onDispose;
      ui.Picture.onCreate = (picture) {
        oldCreate?.call(picture);
        created.add(picture);
      };
      ui.Picture.onDispose = (picture) {
        oldDispose?.call(picture);
        if (created.contains(picture)) {
          disposed.add(picture);
        }
      };
      try {
        final textures = MaterialTextures(seed: 117)..dispose();
        expect(
          () => ClothPrint.prepare(textures, ClothCut.sleeve),
          throwsStateError,
        );
        expect(created, hasLength(1));
        expect(disposed, unorderedEquals(created));
      } finally {
        ui.Picture.onCreate = oldCreate;
        ui.Picture.onDispose = oldDispose;
      }
    },
  );

  testWidgets(
    'continuous artwork keeps native controls, pose and resources through replay',
    (tester) async {
      final created = <ui.Image>{}, disposed = <ui.Image>{};
      final oldCreate = ui.Image.onCreate, oldDispose = ui.Image.onDispose;
      ui.Image.onCreate = (image) {
        oldCreate?.call(image);
        if ((image.width == 108 && image.height == 400) ||
            (image.width == 148 && image.height == 324)) {
          created.add(image);
        }
      };
      ui.Image.onDispose = (image) {
        oldDispose?.call(image);
        if (created.contains(image)) disposed.add(image);
      };
      addTearDown(() {
        ui.Image.onCreate = oldCreate;
        ui.Image.onDispose = oldDispose;
      });
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(2)),
            child: Scaffold(body: SingleChildScrollView(child: ContactStudy())),
          ),
        ),
      );
      await tester.ensureVisible(find.text('Let cloth settle'));
      await tester.tap(find.text('Let cloth settle'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Continuous strip'));
      await tester.tap(find.text('Continuous strip'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<ContactArtwork>(find.byType(ContactArtwork)).continuous,
        isTrue,
      );
      expect(created.length, 1);
      await tester.ensureVisible(find.text('Short & wide'));
      await tester.tap(find.text('Short & wide'));
      await tester.pumpAndSettle();
      expect(created.length, 2);
      await tester.ensureVisible(find.byKey(const ValueKey('contact-play')));
      await tester.tap(find.byKey(const ValueKey('contact-play')));
      await tester.pump();
      await tester.pump(const Duration(seconds: 6));
      expect(
        tester.widget<ContactArtwork>(find.byType(ContactArtwork)).progress,
        1,
      );
      expect(tester.binding.transientCallbackCount, 0);
      await tester.tap(find.byKey(const ValueKey('contact-play')));
      await tester.pump();
      await tester.pump(const Duration(seconds: 6));
      expect(created.length, 2, reason: 'Replay reuses both material sources');
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      expect(disposed, unorderedEquals(created));
      expect(tester.takeException(), isNull);
    },
  );
}
