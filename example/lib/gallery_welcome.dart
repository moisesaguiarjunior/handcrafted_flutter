import 'package:flutter/material.dart';

import 'gallery_catalog.dart';
import 'living_materials.dart';
import 'motion_studies.dart';
import 'painted_note.dart';

/// A usable note before the individual material and motion studies.
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
              'Make something worth keeping.',
              style: TextStyle(fontFamily: 'Caveat', fontSize: 44),
            ),
            const Text('Paper, pigment and thread. Your words and controls.'),
            const SizedBox(height: 12),
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
            const SizedBox(height: 20),
            const Center(child: PaintedNote()),
            const SizedBox(height: 36),
            const Text(
              'Color finds its own edges',
              style: TextStyle(fontFamily: 'Caveat', fontSize: 34),
            ),
            const LivingMaterialArtwork(
              technique: LivingTechnique.watercolor,
              progress: .84,
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
