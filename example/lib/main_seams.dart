import 'package:flutter/material.dart';

import 'seam_studies.dart';
import 'showcase_theme.dart';

void main() => runApp(const ContourSeamApp());

/// Interactive contour-following stitch examples.
class ContourSeamApp extends StatelessWidget {
  /// Creates a responsive specimen page with native controls.
  const ContourSeamApp({super.key});
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
              child: const SeamPlayground(),
            ),
          ),
        ),
      ),
    ),
  );
}
