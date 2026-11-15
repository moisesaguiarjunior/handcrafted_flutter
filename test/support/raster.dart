import 'dart:typed_data';
import 'dart:ui' as ui;

/// Renders a small fixture and disposes both its image and recorded picture.
Future<Uint8List> pixels(void Function(ui.Canvas) paint) async {
  final recorder = ui.PictureRecorder();
  paint(ui.Canvas(recorder));
  final picture = recorder.endRecording();
  final image = await picture.toImage(100, 80);
  try {
    final data = await image.toByteData();
    return Uint8List.fromList(data!.buffer.asUint8List());
  } finally {
    image.dispose();
    picture.dispose();
  }
}
