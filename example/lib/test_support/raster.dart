import 'dart:typed_data';
import 'dart:ui' as ui;

/// Renders a small fixture, closing every native resource even on failure.
Future<Uint8List> pixels(void Function(ui.Canvas) paint) async {
  final recorder = ui.PictureRecorder();
  ui.Picture? picture;
  ui.Image? image;
  try {
    paint(ui.Canvas(recorder));
    picture = recorder.endRecording();
    image = await picture.toImage(100, 80);
    final data = await image.toByteData();
    if (data == null) throw StateError('Raster fixture has no pixel data');
    return Uint8List.fromList(data.buffer.asUint8List());
  } finally {
    image?.dispose();
    if (recorder.isRecording) recorder.endRecording().dispose();
    picture?.dispose();
  }
}
