import 'package:flutter/material.dart';

import 'gallery_catalog.dart';
import 'living_materials.dart';
import 'motion_studies.dart';

/// A painting-led introduction with direct routes to the interactive studies.
class GalleryWelcome extends StatelessWidget {
  /// Reuses the gallery's native route selection.
  const GalleryWelcome({super.key, required this.select});

  /// Opens one study, retaining only its clock/resources.
  final ValueChanged<GalleryStudy> select;
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(24),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'A little color. A world of texture.',
              style: TextStyle(fontFamily: 'Caveat', fontSize: 48),
            ),
            const Text(
              'Watch pigment spread, follow a strand, or give your own widgets a handmade surface.',
            ),
            const SizedBox(height: 24),
            const LivingMaterialArtwork(
              technique: LivingTechnique.watercolor,
              progress: .84,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                FilledButton(
                  onPressed: () => select(GalleryStudy.spreading),
                  child: const Text('Watch the paint spread'),
                ),
                OutlinedButton(
                  onPressed: () => select(GalleryStudy.embroidery),
                  child: const Text('Follow the thread'),
                ),
                TextButton(
                  onPressed: () => select(GalleryStudy.ink),
                  child: const Text('Try the instruments'),
                ),
              ],
            ),
            const SizedBox(height: 36),
            const Text(
              'Different things move differently',
              style: TextStyle(fontFamily: 'Caveat', fontSize: 34),
            ),
            const MotionStage(progress: .31),
            OutlinedButton(
              onPressed: () => select(GalleryStudy.motion),
              child: const Text('Explore body, tail and tether'),
            ),
          ],
        ),
      ),
    ),
  );
}
