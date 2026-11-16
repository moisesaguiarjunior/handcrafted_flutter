import 'package:flutter/material.dart';

import 'paper_studies.dart';
import 'showcase_theme.dart';

void main() => runApp(const PaperRecipesApp());

/// Standalone paper-stock and edge inventory.
class PaperRecipesApp extends StatelessWidget {
  /// Creates native parameter controls and responsive specimen plates.
  const PaperRecipesApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    theme: showcaseTheme(),
    home: Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: const PaperPlayground(),
            ),
          ),
        ),
      ),
    ),
  );
}
