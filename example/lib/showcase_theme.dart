import 'package:flutter/material.dart';

/// Colors shared by runnable examples and deterministic README captures.
///
/// One warm, earthy family (clay, ochre, cognac) balanced by two cool anchors
/// (sage and indigo), so any two fills placed side by side stay in harmony.
abstract final class DemoPalette {
  /// Warm oat presentation workspace.
  static const board = Color(0xFFF4EFE6);

  /// Deep graphite reading ink.
  static const ink = Color(0xFF2B2D35);

  /// Light paper fill.
  static const paper = Color(0xFFFFFCF6);

  /// Muted sage cloth fill.
  static const sage = Color(0xFF8EA58A);

  /// Clay rose felt fill, warm enough to sit beside ochre.
  static const rose = Color(0xFFD69A86);

  /// Rust thread, kept distinct from paper and felt substrates.
  static const thread = Color(0xFFAE5E46);

  /// Wooden support fill.
  static const wood = Color(0xFFC49A6C);

  /// Fired-clay accent.
  static const terracotta = Color(0xFFC4694D);

  /// Warm ochre accent.
  static const ochre = Color(0xFFE0A84A);

  /// Deep indigo cloth and thread.
  static const indigo = Color(0xFF3D5672);

  /// Saddle-tan leather.
  static const cognac = Color(0xFF94562F);

  /// Unbleached cotton thread.
  static const cream = Color(0xFFF3E6CC);
}

/// Theme for the gallery and capture harness; fonts live only in the example.
ThemeData showcaseTheme() => ThemeData(
  fontFamily: 'Inter',
  scaffoldBackgroundColor: DemoPalette.board,
  colorScheme: ColorScheme.fromSeed(seedColor: DemoPalette.ink),
  textTheme: const TextTheme(bodyMedium: TextStyle(color: DemoPalette.ink)),
);
