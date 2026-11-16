import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Loads the same licensed fonts for widget tests and README captures.
Future<void> loadShowcaseFonts({
  String directory = 'assets/fonts',
  bool materialIcons = false,
}) async {
  for (final family in ['Inter', 'Caveat']) {
    final data = kIsWeb
        ? await rootBundle.load('assets/fonts/$family.ttf')
        : ByteData.sublistView(
            File('$directory/$family.ttf').readAsBytesSync(),
          );
    await (FontLoader(family)..addFont(Future.value(data))).load();
  }
  if (materialIcons) {
    if (kIsWeb) throw UnsupportedError('SDK icon captures run natively');
    final sdk = Platform.environment['FLUTTER_ROOT'];
    if (sdk == null)
      throw StateError('FLUTTER_ROOT is required for icon captures');
    final bytes = File(
      '$sdk/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf',
    ).readAsBytesSync();
    await (FontLoader(
      'MaterialIcons',
    )..addFont(Future.value(ByteData.sublistView(bytes)))).load();
  }
}
