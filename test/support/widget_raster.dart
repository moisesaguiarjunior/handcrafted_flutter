import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Reads actual widget pixels and disposes the temporary image, without goldens.
Future<List<int>> widgetPixels(WidgetTester tester, GlobalKey boundary) async =>
    (await tester.runAsync(() async {
      final image =
          await (boundary.currentContext!.findRenderObject()!
                  as RenderRepaintBoundary)
              .toImage();
      try {
        final bytes = await image.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        );
        return bytes!.buffer.asUint8List().toList();
      } finally {
        image.dispose();
      }
    }))!;
