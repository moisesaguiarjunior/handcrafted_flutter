import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../example/lib/painted_note.dart';
import '../example/lib/gallery_welcome.dart';
import '../example/lib/main_gallery.dart';
import '../example/test/support/fonts.dart';
import 'capture_support.dart';

void main() {
  testWidgets('capture the runnable note and responsive welcome', (
    tester,
  ) async {
    await tester.runAsync(
      () => loadShowcaseFonts(directory: 'example/assets/fonts'),
    );
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await captureExample(
      tester,
      'doc/screenshots/painted-note.png',
      const Size(920, 680),
      const Padding(padding: EdgeInsets.all(32), child: PaintedNote()),
    );
    for (final width in [390.0, 1100.0]) {
      await captureExample(
        tester,
        'build/painted-note/welcome-${width.toInt()}.png',
        Size(width, 844),
        GalleryWelcome(select: (_) {}),
      );
    }
    for (final width in [390.0, 1440.0]) {
      await captureExample(
        tester,
        'build/painted-note/gallery-${width.toInt()}.png',
        Size(width, 900),
        const HandcraftedGalleryApp(),
      );
    }
  });
}
