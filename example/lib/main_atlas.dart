import 'package:flutter/material.dart';

import 'material_studies.dart';
import 'motion_studies.dart';
import 'showcase_theme.dart';

void main() => runApp(const MaterialAtlasApp());

/// A visual inventory of implemented materials, impressions, pigment and motion.
class MaterialAtlasApp extends StatelessWidget {
  /// Creates the complete gallery with native, independently sized controls.
  const MaterialAtlasApp({super.key});
  @override
  Widget build(BuildContext context) =>
      MaterialApp(theme: showcaseTheme(), home: const _AtlasPage());
}

enum _Section { materials, impressions, watercolor, motion }

class _AtlasPage extends StatefulWidget {
  const _AtlasPage();
  @override
  State<_AtlasPage> createState() => _AtlasPageState();
}

class _AtlasPageState extends State<_AtlasPage> {
  _Section _section = _Section.materials;
  int _seed = 23;
  bool _raised = false, _reverseLight = false;
  double _opacity = .7, _granulation = .8;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cloth, pigment & moving paper',
                  style: TextStyle(
                    fontFamily: 'Caveat',
                    fontSize: 48,
                    color: DemoPalette.ink,
                  ),
                ),
                const Text('A cabinet of tactile studies, made with Flutter.'),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    for (final section in _Section.values)
                      ChoiceChip(
                        label: Text(switch (section) {
                          _Section.materials => 'Materials',
                          _Section.impressions => 'Impressions',
                          _Section.watercolor => 'Watercolor',
                          _Section.motion => 'Motion',
                        }),
                        selected: _section == section,
                        onSelected: (_) => setState(() => _section = section),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                if (_section == _Section.impressions)
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('Raised impression'),
                        selected: _raised,
                        onSelected: (v) => setState(() => _raised = v),
                      ),
                      FilterChip(
                        label: const Text('Reverse impression light'),
                        selected: _reverseLight,
                        onSelected: (v) => setState(() => _reverseLight = v),
                      ),
                    ],
                  ),
                if (_section == _Section.watercolor) ...[
                  Text('Pigment ${(_opacity * 100).round()}%'),
                  Slider(
                    key: const ValueKey('wash-opacity'),
                    value: _opacity,
                    onChanged: (v) => setState(() => _opacity = v),
                  ),
                  Text('Granulation ${(_granulation * 100).round()}%'),
                  Slider(
                    key: const ValueKey('wash-granulation'),
                    value: _granulation,
                    onChanged: (v) => setState(() => _granulation = v),
                  ),
                ],
                if (_section != _Section.motion)
                  TextButton(
                    onPressed: () => setState(() => _seed++),
                    child: const Text('Change seed'),
                  ),
                const SizedBox(height: 16),
                switch (_section) {
                  _Section.materials => MaterialsSheet(seed: _seed),
                  _Section.impressions => ImpressionsSheet(
                    seed: _seed,
                    raised: _raised,
                    reverseLight: _reverseLight,
                  ),
                  _Section.watercolor => WatercolorsSheet(
                    seed: _seed,
                    opacity: _opacity,
                    granulation: _granulation,
                  ),
                  _Section.motion => const MotionPlayground(),
                },
                const SizedBox(height: 28),
                const Text(
                  'These are synthetic specimens. Text and controls remain native widgets. '
                  'Watercolor and relief are visual approximations; motion is authored and finite.',
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
