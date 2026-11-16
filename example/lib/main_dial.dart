import 'package:flutter/material.dart';

import 'rotary_control.dart';
import 'showcase_theme.dart';

void main() => runApp(const RotaryExampleApp());

/// Standalone accessible rotary recipe.
class RotaryExampleApp extends StatelessWidget {
  /// Creates the native-control demonstration.
  const RotaryExampleApp({super.key});
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
              child: const RotaryControlPlayground(),
            ),
          ),
        ),
      ),
    ),
  );
}
