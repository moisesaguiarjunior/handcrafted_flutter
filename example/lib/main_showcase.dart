import 'package:flutter/material.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

import 'use_cases.dart';

void main() => runApp(const ShowcaseApp());

/// Runnable use-case gallery, separate from the detailed material controls.
class ShowcaseApp extends StatelessWidget {
  /// Creates the gallery.
  const ShowcaseApp({super.key});
  @override
  Widget build(BuildContext context) =>
      MaterialApp(theme: showcaseTheme(), home: const _ShowcasePage());
}

class _ShowcasePage extends StatefulWidget {
  const _ShowcasePage();
  @override
  State<_ShowcasePage> createState() => _ShowcasePageState();
}

class _ShowcasePageState extends State<_ShowcasePage> {
  var _kind = CraftUseCase.keepsake;
  var _replay = 0;
  var _actions = 0;
  bool _still = false;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'handcrafted_flutter',
                  style: TextStyle(
                    fontFamily: 'Caveat',
                    fontSize: 58,
                    color: DemoPalette.ink,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Paper, cloth and thread. Composed with Flutter.',
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 28),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final kind in CraftUseCase.values)
                      ChoiceChip(
                        label: Text(switch (kind) {
                          CraftUseCase.keepsake => 'Keepsake card',
                          CraftUseCase.hanging => 'Hanging pieces',
                          CraftUseCase.kite => 'Kite tail',
                        }),
                        selected: _kind == kind,
                        onSelected: (_) => setState(() {
                          _kind = kind;
                          _replay++;
                        }),
                      ),
                  ],
                ),
                const SizedBox(height: 28),
                Text(
                  useCaseTitle(_kind),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: _kind == CraftUseCase.keepsake
                      ? UseCaseArt(
                          kind: _kind,
                          onAction: () => setState(() => _actions++),
                        )
                      : SceneEntrance(
                          key: ValueKey((_kind, _replay)),
                          startSettled: _still,
                          builder: (context, progress) => UseCaseArt(
                            kind: _kind,
                            progress: progress,
                            onAction: () => setState(() => _actions++),
                          ),
                        ),
                ),
                Wrap(
                  spacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    OutlinedButton(
                      onPressed: () => setState(() => _replay++),
                      child: const Text('Replay entrance'),
                    ),
                    FilterChip(
                      label: const Text('Still pose'),
                      selected: _still,
                      onSelected: (value) => setState(() => _still = value),
                    ),
                    Text('Demo actions: $_actions'),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'These examples use real material surfaces, native buttons and authored poses. '
                  'Punctures are shading; the hanging parts and kite tail are not force simulations. '
                  'System reduced motion always takes precedence.',
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
