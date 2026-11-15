import 'package:flutter/material.dart';

/// Colors shared by runnable examples and deterministic README captures.
abstract final class DemoPalette {
  /// Pale blue presentation workspace.
  static const board = Color(0xFFEDF3F8);

  /// Dark blue reading ink.
  static const ink = Color(0xFF1E3044);

  /// Light paper fill.
  static const paper = Color(0xFFFFFDF8);

  /// Sage cloth fill.
  static const sage = Color(0xFF80A99A);

  /// Rose felt fill.
  static const rose = Color(0xFFD4A0AE);

  /// Dark rose thread, kept distinct from the felt substrate.
  static const thread = Color(0xFFB77584);

  /// Wooden support fill.
  static const wood = Color(0xFFBF9D70);
}

/// Theme for the gallery and capture harness; fonts live only in the example.
ThemeData showcaseTheme() => ThemeData(
  fontFamily: 'Inter',
  scaffoldBackgroundColor: DemoPalette.board,
  colorScheme: ColorScheme.fromSeed(seedColor: DemoPalette.ink),
  textTheme: const TextTheme(bodyMedium: TextStyle(color: DemoPalette.ink)),
);
