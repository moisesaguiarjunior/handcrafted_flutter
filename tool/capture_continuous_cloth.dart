import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../example/lib/contact_artwork.dart';
import '../example/lib/contact_poses.dart';
import '../example/test/support/fonts.dart';
import 'capture_support.dart';

void main() {
  testWidgets('capture the continuous strip beside the articulated baseline', (
    tester,
  ) async {
    await tester.runAsync(
      () => loadShowcaseFonts(directory: 'example/assets/fonts'),
    );
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await captureExample(
      tester,
      'docs/assets/continuous-cloth.png',
      const Size(1100, 1100),
      Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'A bend, without a break',
              style: TextStyle(fontFamily: 'Caveat', fontSize: 48),
            ),
            const Text(
              'One source of linen, print and sewing follows the whole strip.',
            ),
            for (final continuous in [false, true]) ...[
              const SizedBox(height: 20),
              Text(
                continuous ? 'Continuous strip' : 'Articulated baseline',
                style: const TextStyle(fontSize: 20),
              ),
              Row(
                children: [
                  for (final progress in [0.0, .6, 1.0])
                    Expanded(
                      child: Column(
                        children: [
                          ContactArtwork(
                            progress: progress,
                            cloth: true,
                            continuous: continuous,
                          ),
                          Text('${(progress * 100).round()}%'),
                        ],
                      ),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            const Text(
              'Same gesture, another cut',
              style: TextStyle(fontSize: 20),
            ),
            const Row(
              children: [
                Expanded(
                  child: ContactArtwork(
                    progress: .4,
                    cloth: true,
                    continuous: true,
                    contacts: true,
                  ),
                ),
                Expanded(
                  child: ContactArtwork(
                    progress: .4,
                    cloth: true,
                    continuous: true,
                    contacts: true,
                    cut: ClothCut.scarf,
                  ),
                ),
              ],
            ),
            const Text(
              'Continuous planar deformation. Inner and outer edges compress and stretch; this is not cloth physics.',
            ),
          ],
        ),
      ),
    );
    for (var i = 0; i < 48; i++) {
      final progress = (i / 39).clamp(0.0, 1.0);
      await captureExample(
        tester,
        'build/continuous-cloth-frames/${i.toString().padLeft(3, '0')}.png',
        const Size(640, 720),
        Column(
          children: [
            ContactArtwork(progress: progress, cloth: true),
            ContactArtwork(progress: progress, cloth: true, continuous: true),
          ],
        ),
      );
    }
    await tester.pumpWidget(const SizedBox());
  });
}
