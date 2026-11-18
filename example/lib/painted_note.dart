import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

import 'material_vocabulary.dart';
import 'showcase_theme.dart';

/// A runnable postcard: material decoration around an ordinary native form.
///
/// The painting, stamp and postmark are decoration; the message, recipient,
/// border choice and send action are native widgets. Sending only updates this
/// example's state; nothing leaves the demo.
class PaintedNote extends StatefulWidget {
  /// Creates the postcard used in the welcome page and README capture.
  const PaintedNote({super.key});

  @override
  State<PaintedNote> createState() => _PaintedNoteState();
}

class _PaintedNoteState extends State<PaintedNote> {
  final note = TextEditingController(
    text: 'The water was cold and perfect. I found you a shell.',
  );
  final to = TextEditingController(text: 'Grandma Rosa');
  // Move the native editors between the two decorative arrangements without
  // replacing their elements, editing state or focus attachments.
  final messageLocation = GlobalKey();
  final recipientLocation = GlobalKey();
  bool stitched = true;
  bool kept = false;

  @override
  void dispose() {
    note.dispose();
    to.dispose();
    super.dispose();
  }

  void _edited(String _) {
    if (kept) setState(() => kept = false);
  }

  @override
  Widget build(BuildContext context) {
    final message = KeyedSubtree(
      key: messageLocation,
      child: TextField(
        key: const ValueKey('painted-note-text'),
        controller: note,
        minLines: 2,
        maxLines: null,
        onChanged: _edited,
        decoration: const InputDecoration(
          labelText: 'Message',
          border: UnderlineInputBorder(),
        ),
      ),
    );
    final recipient = KeyedSubtree(
      key: recipientLocation,
      child: TextField(
        key: const ValueKey('postcard-to'),
        controller: to,
        onChanged: _edited,
        decoration: const InputDecoration(
          labelText: 'To',
          border: UnderlineInputBorder(),
        ),
      ),
    );
    return ConstrainedBox(
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
          child: LayoutBuilder(
            builder: (context, box) {
              final wide = box.maxWidth >= 560;
              final art = ExcludeSemantics(
                child: IgnorePointer(
                  child: SizedBox(
                    height: wide ? 170 : 130,
                    child: const CustomPaint(painter: _CoastWash()),
                  ),
                ),
              );
              const stamp = ExcludeSemantics(
                child: IgnorePointer(
                  child: SizedBox(
                    width: 112,
                    height: 128,
                    child: CustomPaint(painter: _Stamp()),
                  ),
                ),
              );
              const heading = CraftHeading(
                'Greetings from the coast',
                style: TextStyle(
                  fontFamily: 'Caveat',
                  fontSize: 40,
                  height: 1.05,
                  color: DemoPalette.ink,
                ),
              );
              final actions = Wrap(
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
                    child: const Text('Send postcard'),
                  ),
                ],
              );
              final status = Text(
                kept
                    ? 'Sent! It stays in this demo.'
                    : 'Write a line, then send it. Nothing leaves this demo.',
                style: Theme.of(context).textTheme.bodySmall,
              );
              if (!wide) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    art,
                    const SizedBox(height: 12),
                    heading,
                    const SizedBox(height: 8),
                    message,
                    const SizedBox(height: 12),
                    recipient,
                    const SizedBox(height: 20),
                    actions,
                    const SizedBox(height: 12),
                    status,
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: art),
                      const SizedBox(width: 20),
                      stamp,
                    ],
                  ),
                  const SizedBox(height: 14),
                  heading,
                  const SizedBox(height: 6),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(flex: 3, child: message),
                        const VerticalDivider(width: 36, thickness: 1),
                        Expanded(
                          flex: 2,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [recipient],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  actions,
                  const SizedBox(height: 12),
                  status,
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// An original coastal watercolor: sky, sun, sea and sand, painted by the
/// package rather than an image.
class _CoastWash extends CustomPainter {
  const _CoastWash();

  @override
  void paint(Canvas canvas, Size size) {
    final r = Offset.zero & size;
    void wash(Path shape, Color pigment, Color companion, int seed, double o) =>
        paintWatercolor(
          canvas,
          shape,
          pigment: pigment,
          companion: companion,
          paper: DemoPalette.paper,
          seed: seed,
          opacity: o,
        );
    wash(
      pigmentOutline(r.deflate(6), seed: 44, broad: true),
      const Color(0xFF9DBCC6),
      const Color(0xFFC9D9DC),
      42,
      .7,
    );
    wash(
      Path()..addOval(
        Rect.fromCircle(
          center: Offset(r.width * .74, r.height * .3),
          radius: math.min(r.height * .17, 30),
        ),
      ),
      const Color(0xFFE2B26A),
      const Color(0xFFF0CF96),
      22,
      .9,
    );
    Path band(double top, double wave, int seed) {
      final path = Path()..moveTo(8, r.height * top + 6);
      for (var x = 8.0; x <= r.width - 8; x += 12) {
        path.lineTo(x, r.height * top + math.sin(x / 38 + seed) * wave);
      }
      return path
        ..lineTo(r.width - 8, r.height - 8)
        ..lineTo(8, r.height - 8)
        ..close();
    }

    wash(
      band(.56, 5, 3),
      const Color(0xFF4F8E99),
      const Color(0xFF7FAFB2),
      34,
      .72,
    );
    wash(
      band(.8, 4, 7),
      const Color(0xFFE3C795),
      const Color(0xFFEFD9B0),
      36,
      .8,
    );
  }

  @override
  bool shouldRepaint(_CoastWash oldDelegate) => false;
}

/// A perforated stamp with a tiny painting, and an inked postmark over it.
class _Stamp extends CustomPainter {
  const _Stamp();

  @override
  void paint(Canvas canvas, Size size) {
    final card = Rect.fromLTWH(14, 6, size.width - 20, size.height - 26);
    final edge = paperOutline(
      card,
      edge: PaperEdge.postage,
      depth: 3,
      pitch: 9,
      seed: 5,
    );
    canvas.drawShadow(edge, const Color(0x40000000), 2, false);
    canvas.drawPath(edge, Paint()..color = const Color(0xFFFFFBF2));
    final art = card.deflate(10);
    paintWatercolor(
      canvas,
      Path()..addRect(art),
      pigment: const Color(0xFFD58A6E),
      companion: const Color(0xFFE9B98C),
      paper: const Color(0xFFFFFBF2),
      seed: 9,
      opacity: .75,
    );
    paintWatercolor(
      canvas,
      Path()
        ..moveTo(art.left, art.bottom - art.height * .35)
        ..quadraticBezierTo(
          art.center.dx,
          art.bottom - art.height * .6,
          art.right,
          art.bottom - art.height * .3,
        )
        ..lineTo(art.right, art.bottom)
        ..lineTo(art.left, art.bottom)
        ..close(),
      pigment: const Color(0xFF4F8E99),
      paper: const Color(0xFFFFFBF2),
      seed: 13,
      opacity: .8,
    );
    final value = TextPainter(
      text: const TextSpan(
        text: '25',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFFFFFBF2),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    value.paint(canvas, art.topLeft + const Offset(5, 4));
    value.dispose();

    // Postmark: two rings and wavy cancellation lines in thin, uneven ink.
    final ink = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = const Color(0x8C3D4A5C);
    final mark = Offset(14, size.height - 34);
    canvas.drawCircle(mark, 24, ink);
    canvas.drawCircle(mark, 18, ink..strokeWidth = .9);
    for (var i = 0; i < 3; i++) {
      final y = mark.dy - 10 + i * 9.0;
      final wave = Path()..moveTo(mark.dx + 26, y);
      for (var x = 0.0; x <= 64; x += 4) {
        wave.lineTo(mark.dx + 26 + x, y + math.sin(x / 6 + i) * 2.2);
      }
      canvas.drawPath(wave, ink..strokeWidth = 1.2);
    }
  }

  @override
  bool shouldRepaint(_Stamp oldDelegate) => false;
}
