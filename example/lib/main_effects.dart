import 'package:flutter/material.dart';

import 'bounded_effects.dart';
import 'showcase_theme.dart';

void main() => runApp(const BoundedEffectsApp());

/// Standalone finite pour/light recipe.
class BoundedEffectsApp extends StatelessWidget {
  /// Creates a scrollable native-control effect example.
  const BoundedEffectsApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: showcaseTheme(),
    home: Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: const BoundedEffectsPlayground(),
            ),
          ),
        ),
      ),
    ),
  );
}
