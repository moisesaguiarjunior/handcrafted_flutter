import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

import '../example/lib/placement_studies.dart';

void main() {
  test(
    'author original padded pebble from its actual procedural painter',
    () async {
      final art = PlacementArtwork(), recorder = ui.PictureRecorder();
      ui.Picture? picture;
      ui.Image? image;
      try {
        art.paint(ui.Canvas(recorder)..scale(2));
        picture = recorder.endRecording();
        image = await picture.toImage(360, 280);
        final bytes = (await image.toByteData(format: ui.ImageByteFormat.png))!;
        final file = File('example/assets/layers/placement-pebble.png');
        await file.parent.create(recursive: true);
        await file.writeAsBytes(bytes.buffer.asUint8List());
      } finally {
        image?.dispose();
        if (recorder.isRecording) recorder.endRecording().dispose();
        picture?.dispose();
        art.dispose();
      }
    },
  );
}
