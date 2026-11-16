import 'dart:io';
import 'dart:typed_data';

/// Reads canonical font bytes for native widget tests and captures.
Future<ByteData> readFont(String path) async =>
    ByteData.sublistView(File(path).readAsBytesSync());
