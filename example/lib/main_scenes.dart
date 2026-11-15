import 'package:flutter/material.dart';

import 'imported_layers.dart';
import 'showcase_theme.dart';

void main() => runApp(const SceneRecipesApp());

/// Standalone entry point for consumer-driven composition recipes.
class SceneRecipesApp extends StatelessWidget {
  /// Creates the scrollable scene gallery.
  const SceneRecipesApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: showcaseTheme(),
    home: Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: const ImportedLayerPlayground(),
            ),
          ),
        ),
      ),
    ),
  );
}
