import 'dart:typed_data';
import 'dart:ui_web' as web;

/// Reads test-server assets directly; the test engine ignores asset-channel messages.
Future<ByteData> readFont(String path) =>
    web.AssetManager(assetsDir: '').load(path);
