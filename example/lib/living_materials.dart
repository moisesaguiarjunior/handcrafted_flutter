import 'package:flutter/material.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

import 'living_material_art.dart';
import 'showcase_theme.dart';

export 'living_material_art.dart'
    show LivingTechnique, WatercolorExperiment, ThreadExperiment;

/// Replay, pause and inspect pigment spreading or an authored embroidered sprig.
class LivingMaterialStudy extends StatefulWidget {
  /// Creates a finite, manually started study.
  const LivingMaterialStudy({
    super.key,
    required this.technique,
    this.active = true,
  });

  /// Selected material process.
  final LivingTechnique technique;

  /// Host-supplied visibility/activity policy.
  final bool active;
  @override
  State<LivingMaterialStudy> createState() => _LivingMaterialStudyState();
}

class _LivingMaterialStudyState extends State<LivingMaterialStudy> {
  double? manual = .48;
  WatercolorExperiment experiment = WatercolorExperiment.contact;
  double wetness = .8;
  ThreadExperiment threadExperiment = ThreadExperiment.passing;
  double start = 0;
  bool playing = false;
  bool userScrubbed = false;
  int replay = 0;
  void play(double progress) => setState(() {
    if (manual != null || progress >= 1) {
      start = progress >= 1 ? 0 : progress;
      manual = null;
      replay++;
    }
    playing = true;
  });
  @override
  Widget build(BuildContext context) => SceneEntrance(
    key: ValueKey(replay),
    duration: Duration(
      milliseconds: (14000 * (1 - start)).round().clamp(1, 14000),
    ),
    active: widget.active && playing && manual == null,
    startSettled: manual != null,
    builder: (context, time) {
      final progress = MediaQuery.disableAnimationsOf(context) && !userScrubbed
          ? 1.0
          : manual ?? start + (1 - start) * time;
      final wash = widget.technique == LivingTechnique.watercolor;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            wash ? 'Let the color find its way' : 'Through the cloth',
            style: const TextStyle(fontFamily: 'Caveat', fontSize: 38),
          ),
          Text(
            wash
                ? 'Watch a wet edge travel through the paper. Pause anywhere to look closer.'
                : 'Watch loose loops pass above and below the cloth, then tighten in turn.',
          ),
          const SizedBox(height: 20),
          if (wash) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final item in [
                  (WatercolorExperiment.contact, 'First touch'),
                  (WatercolorExperiment.stroke, 'Brush stroke'),
                  (WatercolorExperiment.layers, 'Pink + blue'),
                  (WatercolorExperiment.botanical, 'Botanical'),
                ])
                  ChoiceChip(
                    label: Text(item.$2),
                    selected: experiment == item.$1,
                    onSelected: (_) => setState(() {
                      experiment = item.$1;
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          if (!wash) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final item in [
                  (ThreadExperiment.passing, 'Thread passing'),
                  (ThreadExperiment.embroidery, 'Embroidery reveal'),
                ])
                  ChoiceChip(
                    label: Text(item.$2),
                    selected: threadExperiment == item.$1,
                    onSelected: (_) =>
                        setState(() => threadExperiment = item.$1),
                  ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: () {
                  if (playing && progress < 1) {
                    setState(() => playing = false);
                  } else {
                    play(progress);
                  }
                },
                icon: Icon(
                  playing && progress < 1 ? Icons.pause : Icons.play_arrow,
                ),
                label: Text(
                  progress >= 1
                      ? 'Replay'
                      : playing
                      ? 'Pause'
                      : 'Play',
                ),
              ),
              OutlinedButton(
                onPressed: () => setState(() {
                  start = 0;
                  manual = null;
                  playing = true;
                  replay++;
                }),
                child: const Text('Restart'),
              ),
              OutlinedButton(
                onPressed: () => setState(() {
                  manual = 1;
                  playing = false;
                }),
                child: const Text('Show finished'),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: Slider(
                  key: const ValueKey('living-progress'),
                  value: progress,
                  semanticFormatterCallback: (v) =>
                      '${(v * 100).round()} percent complete',
                  onChanged: (v) => setState(() {
                    manual = v;
                    userScrubbed = true;
                    playing = false;
                  }),
                ),
              ),
              Text('${(progress * 100).round()}%'),
            ],
          ),
          const SizedBox(height: 12),
          ExcludeSemantics(
            child: IgnorePointer(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: LivingMaterialArtwork(
                    technique: widget.technique,
                    progress: progress,
                    experiment: experiment,
                    wetness: wetness,
                    threadExperiment: threadExperiment,
                  ),
                ),
              ),
            ),
          ),
          if (wash && experiment != WatercolorExperiment.botanical) ...[
            const SizedBox(height: 12),
            Text('Base wetness ${(wetness * 100).round()}%'),
            Slider(
              key: const ValueKey('base-wetness'),
              value: wetness,
              semanticFormatterCallback: (v) =>
                  '${(v * 100).round()} percent wet',
              onChanged: (v) => setState(() => wetness = v),
            ),
          ],
          Text(
            wash
                ? 'Seeded pigment and a soft wet front. An illustrative approximation, without fluid simulation.'
                : 'The strand moves above and below the cloth, with hidden return sections and irregular slack. This is authored movement, not thread physics.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      );
    },
  );
}

/// Actual study painter over owned material surfaces, also used for captures.
class LivingMaterialArtwork extends StatelessWidget {
  /// Creates one explicit pose for live display or capture.
  const LivingMaterialArtwork({
    super.key,
    required this.technique,
    required this.progress,
    this.experiment = WatercolorExperiment.botanical,
    this.wetness = .8,
    this.threadExperiment = ThreadExperiment.passing,
  });

  /// Selected material process.
  final LivingTechnique technique;

  /// Supplied normalized progress; no clock is created here.
  final double progress;

  /// Original watercolor contact/layering composition.
  final WatercolorExperiment experiment;

  /// Art-directed moisture for the example; 0..1.
  final double wetness;

  /// Selects loose thread movement or botanical completion.
  final ThreadExperiment threadExperiment;
  @override
  Widget build(BuildContext context) {
    final wash = technique == LivingTechnique.watercolor;
    Path circle(Size size) => Path()
      ..addOval(
        Rect.fromCircle(
          center: (Offset.zero & size).center,
          radius: size.shortestSide * .46,
        ),
      );
    return AspectRatio(
      aspectRatio: 1.6,
      child: wash
          ? CraftSurface(
              material: CraftMaterial.paper,
              color: DemoPalette.paper,
              seed: 17,
              shape: const CraftOutline.paper(
                edge: PaperEdge.deckle,
                edgeDepth: 3,
                edgePitch: 32,
                seed: 17,
              ),
              child: CustomPaint(
                painter: LivingMaterialPainter(
                  technique,
                  progress,
                  experiment: experiment,
                  wetness: wetness,
                  threadExperiment: threadExperiment,
                ),
              ),
            )
          : CraftSurface(
              material: CraftMaterial.wood,
              color: DemoPalette.wood,
              seed: 31,
              outline: circle,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: CraftSurface(
                  material: CraftMaterial.linen,
                  color: const Color(0xFFE9E4D1),
                  seed: 31,
                  outline: circle,
                  child: CustomPaint(
                    painter: LivingMaterialPainter(
                      technique,
                      progress,
                      experiment: experiment,
                      wetness: wetness,
                      threadExperiment: threadExperiment,
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
