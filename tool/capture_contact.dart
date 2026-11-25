import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../example/lib/contact_artwork.dart';
import '../example/lib/contact_poses.dart';
import 'capture_support.dart';
import '../example/test/support/fonts.dart';

void main() {
  testWidgets('capture synthetic contact poses and finite clip frames', (
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
      'docs/assets/contact-and-cloth.png',
      const Size(1100, 1100),
      Padding(
        padding: const EdgeInsets.all(36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Held, then let go',
              style: TextStyle(fontFamily: 'Caveat', fontSize: 48),
            ),
            const Text(
              'Contact, shared support and a gentle release. One supplied timeline.',
            ),
            const SizedBox(height: 12),
            for (final cloth in [false, true]) ...[
              Text(
                cloth
                    ? 'A pinned textile, two cuts'
                    : 'A sheet passed from hand to hand',
                style: const TextStyle(fontSize: 18),
              ),
              Row(
                children: [
                  for (final t in [0.0, .5, 1.0])
                    Expanded(
                      child: Column(
                        children: [
                          ContactArtwork(progress: t, cloth: cloth),
                          Text('${(t * 100).round()}%'),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
            ],
            const Row(
              children: [
                Expanded(
                  child: ContactArtwork(
                    progress: .5,
                    cloth: true,
                    contacts: true,
                  ),
                ),
                Expanded(
                  child: ContactArtwork(
                    progress: .5,
                    cloth: true,
                    cut: ClothCut.scarf,
                    contacts: true,
                  ),
                ),
              ],
            ),
            const Text(
              'Articulated links with local cloth coordinates; not a flexible-cloth solver.',
            ),
          ],
        ),
      ),
    );
    for (var i = 0; i < 48; i++) {
      await captureExample(
        tester,
        'build/contact-frames/${i.toString().padLeft(3, '0')}.png',
        const Size(640, 720),
        Column(
          children: [
            ContactArtwork(progress: (i / 39).clamp(0.0, 1.0)),
            ContactArtwork(progress: (i / 39).clamp(0.0, 1.0), cloth: true),
          ],
        ),
      );
    }
    await tester.pumpWidget(const SizedBox());
  });
}
