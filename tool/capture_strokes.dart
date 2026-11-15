import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

import '../example/lib/main_strokes.dart';
import '../example/test/support/fonts.dart';
import 'capture_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('capture the real drawing playground with synthetic content', (
    tester,
  ) async {
    await tester.runAsync(
      () => loadShowcaseFonts(
        directory: 'example/assets/fonts',
        materialIcons: true,
      ),
    );
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1100, 1050);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(const StrokePlaygroundApp());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final boundary = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(const ValueKey('stroke-playground')),
    );
    await writeExampleCapture(
      tester,
      boundary,
      'build/showcase/stroke-playground.png',
    );
    await tester.pumpWidget(const SizedBox());
    expect(tester.binding.transientCallbackCount, 0);
  });
}
