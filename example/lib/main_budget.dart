import 'package:flutter/material.dart';

import 'rendering_budget.dart';
import 'showcase_theme.dart';

void main() => runApp(const RenderingBudgetApp());

/// Standalone rendering measurement harness.
class RenderingBudgetApp extends StatelessWidget {
  /// Creates the manual profiling entry point.
  const RenderingBudgetApp({super.key});
  @override
  Widget build(BuildContext context) =>
      MaterialApp(theme: showcaseTheme(), home: const RenderingBudgetPage());
}
