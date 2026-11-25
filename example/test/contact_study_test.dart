import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter_test/flutter_test.dart';
import 'package:handcrafted_example/contact_artwork.dart';
import 'package:handcrafted_example/contact_poses.dart';
import 'package:handcrafted_example/contact_study.dart';
import 'package:handcrafted_example/main_gallery.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

void main() {
  test(
    'support never disappears and fingers leave the printed center clear',
    () {
      for (var i = 0; i <= 100; i++) {
        final pose = TransferPose(i / 100);
        expect(pose.leftSupports || pose.rightSupports, isTrue, reason: '$i');
        for (final left in [true, false]) {
          final fingers = TransferPose.fingers(left);
          final common = Path.combine(
            PathOperation.intersect,
            fingers,
            Path()..addRect(TransferPose.printArea),
          );
          expect(common.getBounds().isEmpty, isTrue);
          if (left ? pose.leftSupports : pose.rightSupports) {
            final local = Offset(left ? 7 : 177, 88);
            expect(fingers.contains(local), isTrue);
            final front = MatrixUtils.transformPoint(
              pose.handMatrix(left),
              local,
            );
            expect((front - pose.contact(left)).distance, lessThan(1e-8));
          }
        }
      }
    },
  );

  test(
    'elbow and cuff stay on the material for two independently sized cuts',
    () {
      for (final cut in ClothCut.values) {
        for (final t in [1.0, .5, 0.0, .75, .25, .5]) {
          final pose = ClothPose(t, cut);
          final shoulder =
              pose.upperOrigin +
              pose.upper.mapPoint(
                Offset(pose.width / 2, 0),
                size: Size(pose.width, pose.upperLength),
              );
          final elbow =
              pose.lowerOrigin +
              pose.lower.mapPoint(
                Offset(pose.width / 2, 0),
                size: Size(pose.width, pose.lowerLength),
              );
          expect((shoulder - ClothPose.shoulder).distance, lessThan(1e-8));
          expect((elbow - pose.elbow).distance, lessThan(1e-8));
          expect((pose.cuff - elbow).distance, closeTo(pose.lowerLength, 1e-8));
        }
        expect(ClothPose(.25, cut).cuff, ClothPose(0, cut).cuff);
        expect(ClothPose(.95, cut).cuff, ClothPose(1, cut).cuff);
        expect(
          ClothPose(.4, cut).lower.rotation,
          ClothPose(0, cut).lower.rotation,
        );
        expect(
          ClothPose(.4, cut).upper.rotation,
          isNot(ClothPose(0, cut).upper.rotation),
        );
      }
      for (final bad in [double.nan, double.infinity, -.01, 1.01]) {
        expect(() => TransferPose(bad), throwsArgumentError);
        expect(() => ClothPose(bad, ClothCut.sleeve), throwsArgumentError);
      }
    },
  );

  testWidgets(
    'actual transforms and raster frames survive out-of-order sampling',
    (tester) async {
      tester.view.physicalSize = const Size(800, 600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final boundaryKey = GlobalKey();
      Future<Uint8List> frame(
        double progress,
        bool cloth,
        double width,
        double angle,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Center(
              child: SizedBox(
                width: width,
                child: RepaintBoundary(
                  key: boundaryKey,
                  child: ContactArtwork(
                    progress: progress,
                    cloth: cloth,
                    cameraAngle: angle,
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
        final boundary = tester.renderObject<RenderRepaintBoundary>(
          find.byKey(boundaryKey),
        );
        return (await tester.runAsync(() async {
          final image = await boundary.toImage();
          try {
            return Uint8List.fromList(
              (await image.toByteData())!.buffer.asUint8List(),
            );
          } finally {
            image.dispose();
          }
        }))!;
      }

      for (final cloth in [false, true]) {
        for (final width in [320.0, 640.0]) {
          for (final angle in [0.0, .1]) {
            final reference = await frame(.5, cloth, width, angle);
            for (final t in [1.0, .25, .75, 0.0]) {
              await frame(t, cloth, width, angle);
            }
            expect(
              await frame(.5, cloth, width, angle),
              orderedEquals(reference),
            );
            if (!cloth) {
              final sheet = tester.widget<CraftPart>(
                find.byKey(const ValueKey('transfer-sheet')),
              );
              final transform = sheet.pose.matrixFor(
                TransferPose.sheetSize,
                sheet.pivot,
              );
              final expected = TransferPose(.5).contact(true);
              final actual =
                  TransferPose.sheetOrigin +
                  MatrixUtils.transformPoint(transform, const Offset(7, 88));
              expect((expected - actual).distance, lessThan(1e-8));
            }
          }
        }
      }
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'native controls stay usable at 200% text, reduced motion settles',
    (tester) async {
      tester.view.physicalSize = const Size(320, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      Future<void> mount({bool reduced = false, bool active = true}) =>
          tester.pumpWidget(
            MaterialApp(
              home: MediaQuery(
                data: MediaQueryData(
                  textScaler: const TextScaler.linear(2),
                  disableAnimations: reduced,
                ),
                child: Scaffold(
                  body: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: ContactStudy(active: active),
                    ),
                  ),
                ),
              ),
            ),
          );
      await mount();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.byKey(const ValueKey('contact-play')));
      await tester.tap(find.byKey(const ValueKey('contact-play')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 900));
      final before = tester
          .widget<ContactArtwork>(find.byType(ContactArtwork))
          .progress;
      expect(before, greaterThan(0));
      await mount(active: false);
      await tester.pump(const Duration(seconds: 2));
      expect(
        tester.widget<ContactArtwork>(find.byType(ContactArtwork)).progress,
        before,
      );
      await mount(reduced: true);
      await tester.pumpAndSettle();
      expect(
        tester.widget<ContactArtwork>(find.byType(ContactArtwork)).progress,
        1,
      );
      expect(
        tester
            .widget<Slider>(find.byKey(const ValueKey('contact-progress')))
            .onChanged,
        isNull,
      );
      expect(tester.binding.hasScheduledFrame, isFalse);
      await tester.ensureVisible(find.text('Let cloth settle'));
      await tester.tap(find.text('Let cloth settle'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<ContactArtwork>(find.byType(ContactArtwork)).cloth,
        isTrue,
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'keyboard Play, Pause and Replay retain the native control focus',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SingleChildScrollView(child: ContactStudy())),
        ),
      );
      final button = find.byKey(const ValueKey('contact-play'));
      await tester.ensureVisible(button);
      FocusNode controlFocus(String text) => Focus.of(
        tester.element(find.descendant(of: button, matching: find.text(text))),
      );
      final original = controlFocus('Play');
      original.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(controlFocus('Pause'), same(original));
      expect(original.hasPrimaryFocus, isTrue);
      await tester.pump(const Duration(milliseconds: 400));
      final progress = tester
          .widget<ContactArtwork>(find.byType(ContactArtwork))
          .progress;
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(controlFocus('Play'), same(original));
      await tester.pump(const Duration(seconds: 1));
      expect(
        tester.widget<ContactArtwork>(find.byType(ContactArtwork)).progress,
        progress,
      );
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      await tester.pump(const Duration(seconds: 6));
      expect(controlFocus('Replay'), same(original));
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(controlFocus('Pause'), same(original));
      expect(original.hasPrimaryFocus, isTrue);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('contact study is reachable through the gallery', (tester) async {
    await tester.pumpWidget(
      const HandcraftedGalleryApp(initialStudy: GalleryStudy.contact),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ContactStudy), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
