import 'package:flutter/material.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

import 'contact_artwork.dart';
import 'contact_poses.dart';

/// Native controls around two externally sampleable contact recipes.
class ContactStudy extends StatefulWidget {
  /// Creates a manually started finite study; hosts supply visibility activity.
  const ContactStudy({super.key, this.active = true});

  /// Explicit host visibility; no automatic scroll visibility is inferred.
  final bool active;
  @override
  State<ContactStudy> createState() => _ContactStudyState();
}

class _ContactStudyState extends State<ContactStudy> {
  double? manual = 0;
  double start = 0;
  int replay = 0;
  bool playing = false, cloth = false, contacts = false;
  ClothCut cut = ClothCut.sleeve;
  double cameraAngle = 0;

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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Held, then let go',
              style: TextStyle(fontFamily: 'Caveat', fontSize: 40),
            ),
            const Text(
              'Follow a sheet from one pair of fingers to the other, or let a folded textile settle.',
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
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
            ContactArtwork(
              progress: progress,
              cloth: cloth,
              cut: cut,
              contacts: contacts,
              cameraAngle: cameraAngle,
            ),
            const SizedBox(height: 12),
            Text(
              cloth
                  ? 'A pinned shoulder, a shared elbow and a delayed cuff. Two rigid links meet under an overlapping fold; this is not flexible cloth.'
                  : 'The receiving hand closes before the giving hand lets go. Fingers stay at the edges of the sheet.',
            ),
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
                if (cloth)
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
              title: const Text('Show contact points'),
              subtitle: const Text('Blue is held. Coral is free.'),
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
