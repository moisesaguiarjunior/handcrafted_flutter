import 'package:flutter/material.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

import 'contact_artwork.dart';
import 'contact_poses.dart';
import 'gesture_surfaces.dart';
import 'material_story_art.dart';

/// Native controls around two externally sampleable contact recipes.
class ContactStudy extends StatefulWidget {
  /// Creates a manually started finite study; hosts supply visibility activity.
  const ContactStudy({super.key, this.active = true, this.initialRecipe});

  /// Optional extended recipe; null retains the original contact study.
  final MaterialRecipe? initialRecipe;

  /// Explicit host visibility; no automatic scroll visibility is inferred.
  final bool active;
  @override
  State<ContactStudy> createState() => _ContactStudyState();
}

class _ContactStudyState extends State<ContactStudy> {
  // Preserve native focus and prepared artwork while restarting only the clock.
  final contentKey = GlobalKey();
  double? manual = 0;
  double start = 0;
  int replay = 0;
  bool playing = false, cloth = false, contacts = false;
  ClothCut cut = ClothCut.sleeve;
  bool continuous = false;
  double cameraAngle = 0;
  late MaterialRecipe? recipe = widget.initialRecipe;
  FigureMaterial material = FigureMaterial.felt;
  bool lightFromRight = false;
  double windStrength = 1;

  void play(double progress) => setState(() {
    start = progress >= 1 ? 0 : progress;
    manual = null;
    playing = true;
    replay++;
  });

  @override
  Widget build(BuildContext context) {
    final reduced = MediaQuery.disableAnimationsOf(context);
    return SceneEntrance(
      key: ValueKey(replay),
      duration: Duration(
        milliseconds: (5200 * (1 - start)).round().clamp(1, 5200),
      ),
      active: widget.active && playing && manual == null,
      startSettled: manual != null,
      builder: (context, time) {
        final progress = reduced ? 1.0 : manual ?? start + (1 - start) * time;
        return Column(
          key: contentKey,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              recipe == null ? 'Held, then let go' : 'Materials in a gesture',
              style: TextStyle(fontFamily: 'Caveat', fontSize: 40),
            ),
            Text(
              recipe == null
                  ? 'Follow a sheet from one pair of fingers to the other, or let a folded textile settle.'
                  : 'Turn a fold, pull a stool closer, or follow one breeze through three materials.',
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (recipe != null)
                  for (final r in MaterialRecipe.values)
                    ChoiceChip(
                      label: Text(materialRecipeTitle(r)),
                      selected: recipe == r,
                      onSelected: (_) => setState(() {
                        recipe = r;
                        manual = 0;
                        playing = false;
                      }),
                    ),
                if (recipe == null)
                  for (final item in [
                    (false, 'Pass the paper'),
                    (true, 'Let cloth settle'),
                  ])
                    ChoiceChip(
                      label: Text(item.$2),
                      selected: cloth == item.$1,
                      onSelected: (_) => setState(() {
                        cloth = item.$1;
                        manual = 0;
                        playing = false;
                      }),
                    ),
              ],
            ),
            const SizedBox(height: 16),
            if (recipe != null)
              MaterialStoryArtwork(
                key: ValueKey(recipe),
                recipe: recipe!,
                progress: progress,
                cut: cut,
                material: material,
                guides: contacts,
                cameraAngle: cameraAngle,
                lightFromRight: lightFromRight,
                windStrength: windStrength,
              )
            else
              ContactArtwork(
                progress: progress,
                cloth: cloth,
                continuous: continuous,
                cut: cut,
                contacts: contacts,
                cameraAngle: cameraAngle,
              ),
            const SizedBox(height: 12),
            Text(
              recipe != null
                  ? materialRecipeDescription(recipe!)
                  : cloth
                  ? continuous
                        ? 'One printed strip bends continuously. The same marks stay on the cloth; inner and outer edges compress and stretch. This is authored planar deformation.'
                        : 'A pinned shoulder, a shared elbow and a delayed cuff. Two rigid links meet under an overlapping fold; this is not flexible cloth.'
                  : 'The receiving hand closes before the giving hand lets go. Fingers stay at the edges of the sheet.',
            ),
            if (cloth && recipe == null) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final item in [
                    (false, 'Articulated links'),
                    (true, 'Continuous strip'),
                  ])
                    ChoiceChip(
                      label: Text(item.$2),
                      selected: continuous == item.$1,
                      onSelected: (_) => setState(() => continuous = item.$1),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(
                  key: const ValueKey('contact-play'),
                  onPressed: reduced
                      ? null
                      : () {
                          if (playing && manual == null && progress < 1) {
                            setState(() {
                              manual = progress;
                              playing = false;
                            });
                          } else {
                            play(progress);
                          }
                        },
                  child: Text(
                    playing && manual == null && progress < 1
                        ? 'Pause'
                        : progress >= 1
                        ? 'Replay'
                        : 'Play',
                  ),
                ),
                OutlinedButton(
                  onPressed: () => setState(() {
                    manual = 1;
                    playing = false;
                  }),
                  child: const Text('Show result'),
                ),
                if (recipe == MaterialRecipe.cloth || (cloth && recipe == null))
                  for (final item in [
                    (ClothCut.sleeve, 'Long & narrow'),
                    (ClothCut.scarf, 'Short & wide'),
                  ])
                    ChoiceChip(
                      label: Text(item.$2),
                      selected: cut == item.$1,
                      onSelected: (_) => setState(() => cut = item.$1),
                    ),
              ],
            ),
            if (recipe == MaterialRecipe.figure)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final m in FigureMaterial.values)
                    ChoiceChip(
                      label: Text(m.name),
                      selected: material == m,
                      onSelected: (_) => setState(() => material = m),
                    ),
                ],
              ),
            if (recipe != null)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Light from the right'),
                value: lightFromRight,
                onChanged: (v) => setState(() => lightFromRight = v),
              ),
            if (recipe == MaterialRecipe.wind) ...[
              const Text('Breeze strength'),
              Slider(
                key: const ValueKey('gust-strength'),
                value: windStrength,
                onChanged: (v) => setState(() => windStrength = v),
              ),
            ],
            Semantics(
              label: 'Gesture progress',
              child: Slider(
                key: const ValueKey('contact-progress'),
                value: progress,
                semanticFormatterCallback: (v) =>
                    '${(v * 100).round()} percent',
                onChanged: reduced
                    ? null
                    : (v) => setState(() {
                        manual = v;
                        playing = false;
                      }),
              ),
            ),
            Text(
              reduced
                  ? 'Reduced motion: final pose.'
                  : 'Gesture: ${(progress * 100).round()}%',
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                recipe != null
                    ? 'Show anchors'
                    : cloth && continuous
                    ? 'Show material points'
                    : 'Show contact points',
              ),
              subtitle: Text(
                recipe != null
                    ? 'Blue stays fixed. Coral follows the material.'
                    : cloth && continuous
                    ? 'Blue is pinned. Coral follows the cloth.'
                    : 'Blue is held. Coral is free.',
              ),
              value: contacts,
              onChanged: (v) => setState(() => contacts = v),
            ),
            const Text('Turn the whole composition'),
            Semantics(
              label: 'Composition angle',
              child: Slider(
                key: const ValueKey('contact-camera-angle'),
                value: cameraAngle,
                min: -.12,
                max: .12,
                semanticFormatterCallback: (v) =>
                    '${(v * 180 / 3.141592653589793).round()} degrees',
                onChanged: (v) => setState(() => cameraAngle = v),
              ),
            ),
          ],
        );
      },
    );
  }
}
