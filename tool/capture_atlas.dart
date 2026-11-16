import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../example/lib/material_studies.dart';
import 'capture_motion.dart' show captureMotionStudies;
import '../example/test/support/fonts.dart';
import 'capture_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('capture synthetic material and independent-motion studies', (
    tester,
  ) async {
    await tester.runAsync(
      () => loadShowcaseFonts(directory: 'example/assets/fonts'),
    );
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    Widget sheet(String title, Widget child) => Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontFamily: 'Caveat', fontSize: 48),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
    for (final item in [
      (
        'materials',
        'Five materials, many possibilities',
        const MaterialsSheet(),
        const Size(1100, 850),
      ),
      (
        'impressions',
        'Pressed into the fabric',
        const ImpressionsSheet(),
        const Size(1100, 540),
      ),
      (
        'watercolor',
        'Pigment, paper & a little water',
        const WatercolorsSheet(),
        const Size(1100, 540),
      ),
    ]) {
      await captureExample(
        tester,
        'build/atlas/${item.$1}.png',
        item.$4,
        sheet(item.$2, item.$3),
      );
    }
    await captureMotionStudies(tester);
    await tester.pumpWidget(const SizedBox());
    expect(tester.binding.transientCallbackCount, 0);
  });
}
