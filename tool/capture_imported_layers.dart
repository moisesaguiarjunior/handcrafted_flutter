import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../example/lib/imported_layers.dart';
import '../example/test/support/fonts.dart';
import 'capture_support.dart';

void main() {
  testWidgets('capture supplied artwork at three explicit poses', (
    tester,
  ) async {
    await tester.runAsync(
      () => loadShowcaseFonts(directory: 'assets/fonts', materialIcons: true),
    );
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    await tester.runAsync(
      () => precacheImage(
        const AssetImage(layerAsset),
        tester.element(find.byType(SizedBox).first),
      ),
    );
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await captureExample(
      tester,
      'build/scenes/imported-layers.png',
      const Size(1100, 540),
      Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Imported art, living attachments',
              style: TextStyle(fontFamily: 'Caveat', fontSize: 44),
            ),
            const Text(
              'The same source pixels at closed, partial and open poses.',
              style: TextStyle(fontFamily: 'Inter'),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Row(
                children: [
                  for (final p in [0.0, .5, 1.0])
                    Expanded(
                      child: ImportedComposition(
                        progress: p,
                        onLidPressed: () {},
                        onInspect: () {},
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  });
}
