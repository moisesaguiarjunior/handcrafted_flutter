import 'package:flutter/material.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

import 'showcase_theme.dart';

/// Two palettes supplied entirely by the example, not by the package.
CraftTheme exampleMaterialTheme({required bool cloth}) {
  final ink = cloth ? const Color(0xFF3F5E55) : const Color(0xFF8A5A3C);
  CraftPanelStyle recipe(
    CraftMaterial material,
    Color color, {
    CraftOutline? shape,
    CraftStitchKind kind = CraftStitchKind.running,
    EdgeInsetsGeometry? padding,
    bool sewn = true,
    double seamInset = 14,
  }) => CraftPanelStyle(
    material: material,
    color: color,
    seed: cloth ? 37 : 19,
    strength: .65,
    shape:
        shape ??
        (cloth
            ? const CraftOutline.paper(
                edge: PaperEdge.torn,
                edgeDepth: 4,
                edgePitch: 20,
                seed: 37,
                padding: 4,
              )
            : const CraftOutline.paper(
                edge: PaperEdge.deckle,
                edgePitch: 24,
                padding: 4,
              )),
    padding: padding ?? const EdgeInsets.all(28),
    // Thread marks the card and the main action only; quieter chips and
    // choices keep the form readable.
    seam: sewn
        ? CraftSeam(
            color: ink.withValues(alpha: .75),
            kind: kind,
            pitch: 14,
            inset: seamInset,
            depth: 4,
          )
        : null,
  );
  final base = recipe(
    cloth ? CraftMaterial.linen : CraftMaterial.paper,
    cloth ? const Color(0xFFE2E9DD) : const Color(0xFFFBF3E4),
    kind: cloth ? CraftStitchKind.blanket : CraftStitchKind.running,
  );
  final button = recipe(
    cloth ? CraftMaterial.felt : CraftMaterial.paper,
    cloth ? const Color(0xFFBCD3C2) : const Color(0xFFEFCB8C),
    kind: cloth ? CraftStitchKind.blanket : CraftStitchKind.running,
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 26),
    seamInset: 8,
  );
  return CraftTheme(
    surface: base,
    heading: CraftReliefStyle(
      kind: cloth ? CraftReliefKind.raised : CraftReliefKind.inset,
      depth: cloth ? 1.1 : 1.6,
    ),
    roles: {
      CraftRole.button: button,
      CraftRole.choice: recipe(
        cloth ? CraftMaterial.twill : CraftMaterial.paper,
        cloth ? const Color(0xFFEDE4D6) : const Color(0xFFF4E8D6),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        sewn: false,
      ),
      CraftRole.selectedChoice: recipe(
        cloth ? CraftMaterial.felt : CraftMaterial.paper,
        cloth ? const Color(0xFFC9DCCB) : const Color(0xFFF2DDB8),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        sewn: false,
      ),
      CraftRole.tag: recipe(
        cloth ? CraftMaterial.felt : CraftMaterial.paper,
        cloth ? const Color(0xFFEBC6B8) : const Color(0xFFF1CDBE),
        shape: const CraftOutline.pigment(seed: 73, broad: true, padding: 3),
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
        sewn: false,
      ),
      CraftRole.ribbon: recipe(
        cloth ? CraftMaterial.twill : CraftMaterial.paper,
        cloth ? const Color(0xFFC9D8E0) : const Color(0xFFDCE5D3),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        sewn: false,
      ),
    },
  );
}

/// Stateful native content whose identity survives a material-theme change.
class MaterialVocabularyStudy extends StatefulWidget {
  /// Creates the interactive host-theme example.
  const MaterialVocabularyStudy({super.key, this.initialCloth = false});

  /// Initial example-owned palette, useful for side-by-side captures.
  final bool initialCloth;
  @override
  State<MaterialVocabularyStudy> createState() =>
      _MaterialVocabularyStudyState();
}

class _MaterialVocabularyStudyState extends State<MaterialVocabularyStudy> {
  late bool cloth = widget.initialCloth;
  bool attending = true;
  bool sent = false;
  final name = TextEditingController(text: 'Ana, Leo and the kids');
  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  void _choose(bool value) => setState(() {
    attending = value;
    sent = false;
  });

  @override
  Widget build(BuildContext context) {
    final nativeTheme = Theme.of(context);
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'One invitation, two materials',
          style: TextStyle(fontFamily: 'Caveat', fontSize: 38),
        ),
        const Text(
          'Switch the material while you reply. Text, focus, choices and actions stay native.',
        ),
        SwitchListTile(
          key: const ValueKey('material-theme'),
          contentPadding: EdgeInsets.zero,
          title: const Text('Use a cloth theme'),
          value: cloth,
          onChanged: (v) => setState(() => cloth = v),
        ),
        const SizedBox(height: 16),
        Theme(
          data: nativeTheme.copyWith(
            extensions: [
              ...nativeTheme.extensions.values.where(
                (extension) => extension is! CraftTheme,
              ),
              exampleMaterialTheme(cloth: cloth),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CraftPanel(
                role: CraftRole.card,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        CraftPanel(
                          role: CraftRole.tag,
                          child: Text('SUNDAY · 4 PM'),
                        ),
                        CraftPanel(
                          role: CraftRole.ribbon,
                          child: Text('BY THE LAKE'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const CraftHeading(
                      'Picnic for Grandma’s birthday',
                      style: TextStyle(
                        fontFamily: 'Caveat',
                        fontSize: 36,
                        height: 1.1,
                        color: DemoPalette.ink,
                      ),
                    ),
                    const Text('Bring a blanket. We’ll bring the cake.'),
                    const SizedBox(height: 18),
                    TextField(
                      key: const ValueKey('material-note-title'),
                      controller: name,
                      minLines: 1,
                      maxLines: null,
                      onChanged: (_) {
                        if (sent) setState(() => sent = false);
                      },
                      decoration: const InputDecoration(
                        labelText: 'Who is coming',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        CraftChoice(
                          key: const ValueKey('rsvp-yes'),
                          selected: attending,
                          onSelected: (_) => _choose(true),
                          child: const Text('We’ll be there'),
                        ),
                        CraftChoice(
                          key: const ValueKey('rsvp-no'),
                          selected: !attending,
                          onSelected: (_) => _choose(false),
                          child: const Text('Can’t make it'),
                        ),
                        CraftButton(
                          onPressed: () => setState(() => sent = true),
                          child: const Text('Send reply'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      sent
                          ? (attending
                                ? 'Reply sent: see you Sunday.'
                                : 'Reply sent: we’ll miss you.')
                          : 'Your reply stays in this demo.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Both material themes belong to this example. Your app supplies its own palette, fonts, content and role styles. Large native content keeps a plain background when decorative budgets are exhausted.',
        ),
      ],
    );
    // Keep the specimen within the existing decorative budget; never shrink text.
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 800),
      child: content,
    );
  }
}
