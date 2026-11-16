import 'package:flutter/material.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

import 'experience_frame.dart';
import 'imported_layers.dart';
import 'material_vocabulary.dart';

/// Coordinate size of the original synthetic cabinet artboard.
const experienceArtboardSize = Size(400, 400);

/// Native contain-fit destination, shared by the illustration and its overlay.
Rect experienceArtworkRect(Size viewport) {
  final available = (Offset.zero & viewport).deflate(24);
  if (available.isEmpty) return Rect.zero;
  final fit = applyBoxFit(
    BoxFit.contain,
    experienceArtboardSize,
    available.size,
  );
  return Alignment.center.inscribe(fit.destination, available);
}

/// Imported pixels scale; the native 48px lid action is positioned independently.
class ExperienceIllustration extends StatelessWidget {
  /// No clock is created; the host supplies the pose and activation.
  const ExperienceIllustration({
    super.key,
    required this.progress,
    required this.onToggle,
  });

  /// Authored opening progress, 0..1.
  final double progress;

  /// Native action on the mapped lid center.
  final VoidCallback onToggle;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, bounds) {
      final destination = experienceArtworkRect(bounds.biggest);
      if (destination.isEmpty) return const SizedBox();
      final lid = importedLidPart(progress: progress);
      final point = lid.mapSourcePoint(lidSourceRect.center);
      final mapped = Offset(
        destination.left +
            point.dx * destination.width / experienceArtboardSize.width,
        destination.top +
            point.dy * destination.height / experienceArtboardSize.height,
      );
      return Stack(
        children: [
          Positioned.fill(
            child: ExcludeSemantics(
              child: IgnorePointer(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: FittedBox(
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                    child: SizedBox(
                      width: experienceArtboardSize.width,
                      height: experienceArtboardSize.height,
                      child: Stack(children: [importedBasePart(), lid]),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned.fromRect(
            rect: Rect.fromCenter(center: mapped, width: 48, height: 48),
            child: SizedBox(
              width: 48,
              height: 48,
              child: IconButton.filledTonal(
                key: const ValueKey('experience-lid-action'),
                tooltip: progress >= .5 ? 'Close the lid' : 'Lift the lid',
                onPressed: onToggle,
                icon: Icon(
                  progress >= .5
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_up,
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}

/// Synthetic form/art recipe with no consumer content or persistence claim.
class ExperienceFrameStudy extends StatefulWidget {
  /// The surrounding Scaffold must resize for keyboard insets.
  const ExperienceFrameStudy({super.key, this.initialProgress = 0})
    : assert(initialProgress >= 0 && initialProgress <= 1);

  /// Initial explicit pose, useful for deterministic captures.
  final double initialProgress;
  @override
  State<ExperienceFrameStudy> createState() => _ExperienceFrameStudyState();
}

class _ExperienceFrameStudyState extends State<ExperienceFrameStudy> {
  late double progress = widget.initialProgress;
  bool userPositioned = false, selected = true;
  int actions = 0;
  final title = TextEditingController(text: 'A tiny blue feather');
  @override
  void dispose() {
    title.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pose = MediaQuery.disableAnimationsOf(context) && !userPositioned
        ? 1.0
        : progress;
    return Theme(
      data: theme.copyWith(
        extensions: [
          ...theme.extensions.values.where(
            (extension) => extension is! CraftTheme,
          ),
          exampleMaterialTheme(cloth: false),
        ],
      ),
      child: ExperienceFrame(
        heading: Semantics(
          header: true,
          child: const Text(
            'A cabinet for tiny wonders',
            style: TextStyle(fontFamily: 'Caveat', fontSize: 34),
          ),
        ),
        illustration: ExperienceIllustration(
          progress: pose,
          onToggle: () => setState(() {
            progress = pose >= .5 ? 0 : 1;
            userPositioned = true;
          }),
        ),
        content: CraftPanel(
          role: CraftRole.card,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Artwork has its own coordinates. Your words keep their own size.',
              ),
              const SizedBox(height: 16),
              TextField(
                key: const ValueKey('experience-note'),
                controller: title,
                minLines: 1,
                maxLines: null,
                decoration: const InputDecoration(
                  labelText: 'Observation',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              CraftChoice(
                selected: selected,
                onSelected: (v) => setState(() => selected = v),
                child: const Text('Add a label'),
              ),
              const SizedBox(height: 12),
              const Text('Lid opening'),
              Slider(
                key: const ValueKey('experience-progress'),
                value: pose,
                semanticFormatterCallback: (v) =>
                    '${(v * 100).round()} percent open',
                onChanged: (v) => setState(() {
                  progress = v;
                  userPositioned = true;
                }),
              ),
              Text('Preview actions $actions'),
            ],
          ),
        ),
        footer: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: SizedBox(
                width: double.infinity,
                child: CraftButton(
                  key: const ValueKey('experience-continue'),
                  onPressed: () => setState(() => actions++),
                  child: const Text('Continue'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
