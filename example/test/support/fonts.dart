import 'dart:io';

import 'package:flutter/services.dart';

/// Loads the same licensed fonts for widget tests and README captures.
Future<void> loadShowcaseFonts({String directory = 'assets/fonts'}) async {
  for (final family in ['Inter', 'Caveat']) {
    final bytes = File('$directory/$family.ttf').readAsBytesSync();
    await (FontLoader(
      family,
    )..addFont(Future.value(ByteData.sublistView(bytes)))).load();
  }
}
