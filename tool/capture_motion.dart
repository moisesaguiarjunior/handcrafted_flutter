import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../example/lib/motion_studies.dart';
import '../example/test/support/fonts.dart';
import 'capture_support.dart';

void main() {
  testWidgets('capture generic independent body tail and tether motion', (
    tester,
  ) async {
    await tester.runAsync(
      () => loadShowcaseFonts(directory: 'example/assets/fonts'),
    );
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await captureMotionStudies(tester);
    await tester.pumpWidget(const SizedBox());
    expect(tester.binding.transientCallbackCount, 0);
  });
}

/// Captures the actual generic atlas; callers configure fonts and test viewport.
Future<void> captureMotionStudies(WidgetTester tester) async {
  Widget sheet(double progress) => Padding(
    padding: const EdgeInsets.all(28),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Small movements, separate parts',
          style: TextStyle(fontFamily: 'Caveat', fontSize: 48),
        ),
        const SizedBox(height: 20),
        MotionAtlas(progress: progress),
      ],
    ),
  );
  await captureExample(
    tester,
    'build/atlas/motion.png',
    const Size(1000, 1000),
    sheet(.37),
  );
  for (var frame = 0; frame <= 48; frame++) {
    await captureExample(
      tester,
      'build/atlas/motion/frame_${frame.toString().padLeft(3, '0')}.png',
      const Size(1000, 1000),
      sheet(frame / 48),
    );
  }
}
