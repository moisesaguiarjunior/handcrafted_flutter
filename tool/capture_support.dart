import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import '../example/lib/showcase_theme.dart';

/// Captures actual example widgets in the existing controlled showcase shell.
/// Caller sets pixel ratio 1 and restores the test view after its capture batch.
Future<void> captureExample(
  WidgetTester tester,
  String path,
  Size size,
  Widget child,
) async {
  tester.view.physicalSize = size;
  final key = GlobalKey();
  await tester.pumpWidget(
    MaterialApp(
      theme: showcaseTheme(),
      home: RepaintBoundary(
        key: key,
        child: Scaffold(
          backgroundColor: DemoPalette.board,
          body: Center(child: child),
        ),
      ),
    ),
  );
  await tester.pump();
  expect(tester.takeException(), isNull);
  final boundary = key.currentContext?.findRenderObject();
  if (boundary is! RenderRepaintBoundary)
    throw StateError('Missing capture boundary');
  await writeExampleCapture(tester, boundary, path);
}

/// Writes PNG data and always disposes the temporary raster image.
Future<void> writeExampleCapture(
  WidgetTester tester,
  RenderRepaintBoundary boundary,
  String path,
) async {
  await tester.runAsync(() async {
    final image = await boundary.toImage();
    try {
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) throw StateError('PNG encoding failed');
      final file = File(path);
      await file.parent.create(recursive: true);
      await file.writeAsBytes(bytes.buffer.asUint8List());
    } finally {
      image.dispose();
    }
  });
}
