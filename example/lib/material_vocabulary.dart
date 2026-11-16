import 'package:flutter/material.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

import 'showcase_theme.dart';

/// Two palettes supplied entirely by the example, not by the package.
CraftTheme exampleMaterialTheme({required bool cloth}) {
  final ink = cloth ? const Color(0xFF355B55) : const Color(0xFF66513F);
  CraftPanelStyle recipe(
    CraftMaterial material,
    Color color, {
    CraftOutline? shape,
    CraftStitchKind kind = CraftStitchKind.running,
    EdgeInsetsGeometry? padding,
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
    seam: CraftSeam(
      color: ink.withValues(alpha: .75),
      kind: kind,
      pitch: 14,
      inset: 14,
      depth: 4,
    ),
  );
  final base = recipe(
    cloth ? CraftMaterial.linen : CraftMaterial.paper,
    cloth ? const Color(0xFFE0E9DD) : const Color(0xFFFFF1D7),
    kind: cloth ? CraftStitchKind.blanket : CraftStitchKind.running,
  );
  final button = recipe(
    cloth ? CraftMaterial.felt : CraftMaterial.paper,
    cloth ? const Color(0xFFC6D9CA) : const Color(0xFFE9C99E),
    kind: cloth ? CraftStitchKind.blanket : CraftStitchKind.running,
    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
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
        cloth ? const Color(0xFFEADDD1) : const Color(0xFFF2E4D1),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      ),
      CraftRole.selectedChoice: recipe(
        cloth ? CraftMaterial.felt : CraftMaterial.paper,
        cloth ? const Color(0xFFB7D2C2) : const Color(0xFFE7C299),
        kind: CraftStitchKind.backstitch,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      ),
      CraftRole.tag: recipe(
        cloth ? CraftMaterial.felt : CraftMaterial.paper,
        cloth ? const Color(0xFFE2C8C1) : const Color(0xFFF0DABC),
        shape: const CraftOutline.pigment(seed: 73, broad: true, padding: 3),
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 26),
      ),
      CraftRole.ribbon: recipe(
        cloth ? CraftMaterial.twill : CraftMaterial.paper,
        cloth ? const Color(0xFFC5D9DB) : const Color(0xFFE1D4B8),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 26),
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
  bool selected = true;
  int actions = 0;
  final title = TextEditingController(text: 'A feather beside the garden path');
  @override
  void dispose() {
    title.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nativeTheme = Theme.of(context);
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'The same note, two materials',
          style: TextStyle(fontFamily: 'Caveat', fontSize: 38),
        ),
        const Text(
          'Change the material, then keep writing. Text, focus, choices and actions stay native.',
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
                    const CraftHeading(
                      'Make room for small wonders',
                      style: TextStyle(
                        fontFamily: 'Caveat',
                        fontSize: 34,
                        color: DemoPalette.ink,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      key: const ValueKey('material-note-title'),
                      controller: title,
                      minLines: 1,
                      maxLines: null,
                      decoration: const InputDecoration(
                        labelText: 'Note title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        CraftChoice(
                          selected: selected,
                          onSelected: (v) => setState(() => selected = v),
                          child: const Text('Keep this note'),
                        ),
                        CraftButton(
                          onPressed: () => setState(() => actions++),
                          child: const Text('Try the action'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('Activations $actions'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  const CraftPanel(
                    role: CraftRole.tag,
                    child: Text('FIELD NOTE'),
                  ),
                  const CraftPanel(
                    role: CraftRole.ribbon,
                    child: Text('A LITTLE WONDER'),
                  ),
                ],
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
