import 'package:flutter/material.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

import 'material_vocabulary.dart';
import 'showcase_theme.dart';

/// A runnable composition: material decoration around an ordinary native form.
/// State belongs to this example; keeping a note does not persist it anywhere.
class PaintedNote extends StatefulWidget {
  /// Creates the same note used in the welcome page and README capture.
  const PaintedNote({super.key});

  @override
  State<PaintedNote> createState() => _PaintedNoteState();
}

class _PaintedNoteState extends State<PaintedNote> {
  final note = TextEditingController(text: 'The sky after the rain');
  bool stitched = true;
  bool kept = false;

  @override
  void dispose() {
    note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 760),
    child: Theme(
      data: Theme.of(context).copyWith(
        extensions: [
          ...Theme.of(context).extensions.values
              .where((extension) => extension is! CraftTheme),
          exampleMaterialTheme(cloth: false),
        ],
      ),
      child: CraftPanel(
        role: CraftRole.card,
        padding: const EdgeInsets.all(32),
        style: CraftPanelStyle(
          material: CraftMaterial.paper,
          color: DemoPalette.paper,
          seed: 47,
          strength: .8,
          shape: const CraftOutline.paper(
            edge: PaperEdge.deckle,
            seed: 47,
            edgePitch: 28,
            padding: 4,
          ),
          seam: stitched
              ? CraftSeam(
                  color: DemoPalette.thread,
                  inset: 17,
                  pitch: 15,
                  width: 1.6,
                )
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const ExcludeSemantics(
              child: IgnorePointer(
                child: SizedBox(
                  height: 136,
                  child: CustomPaint(painter: _NoteWash()),
                ),
              ),
            ),
            const CraftHeading(
              'Keep a little wonder.',
              style: TextStyle(
                fontFamily: 'Caveat',
                fontSize: 42,
                height: 1.05,
                color: DemoPalette.ink,
              ),
            ),
            const SizedBox(height: 8),
            const Text('Something you noticed. Something worth a line.'),
            const SizedBox(height: 24),
            TextField(
              key: const ValueKey('painted-note-text'),
              controller: note,
              minLines: 1,
              maxLines: null,
              onChanged: (_) {
                if (kept) setState(() => kept = false);
              },
              decoration: const InputDecoration(
                labelText: 'Your little wonder',
                border: UnderlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                CraftChoice(
                  key: const ValueKey('painted-note-stitch'),
                  selected: stitched,
                  onSelected: (v) => setState(() => stitched = v),
                  child: const Text('Stitched edge'),
                ),
                CraftButton(
                  onPressed: () => setState(() => kept = true),
                  child: const Text('Keep this note'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              kept
                  ? 'Kept here until you leave this demo.'
                  : 'Try the controls. This note stays in the demo.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    ),
  );
}

// Two original, asymmetric washes, painted by the package rather than an image.
class _NoteWash extends CustomPainter {
  const _NoteWash();

  @override
  void paint(Canvas canvas, Size size) {
    final unit = size.width.clamp(0.0, 520.0);
    final center = Offset(size.width / 2, size.height / 2);
    final rose = pigmentOutline(
      Rect.fromCenter(
        center: center + Offset(-unit * .13, 5),
        width: unit * .58,
        height: 103,
      ),
      seed: 39,
    );
    final blue = pigmentOutline(
      Rect.fromCenter(
        center: center + Offset(unit * .15, -5),
        width: unit * .6,
        height: 120,
      ),
      seed: 82,
    );
    paintWatercolor(
      canvas,
      rose,
      pigment: const Color(0xFFBD668C),
      paper: DemoPalette.paper,
      companion: const Color(0xFFE8AD9F),
      seed: 39,
      opacity: .65,
    );
    paintWatercolor(
      canvas,
      blue,
      pigment: const Color(0xFF438EAC),
      paper: DemoPalette.paper,
      companion: const Color(0xFF777AB2),
      seed: 82,
      opacity: .62,
    );
  }

  @override
  bool shouldRepaint(_NoteWash oldDelegate) => false;
}
