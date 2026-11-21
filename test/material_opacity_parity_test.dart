import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';
import 'support/texture_canvas.dart';
import 'support/raster.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'material compositing matches the original layer; measure direct-alpha alternative',
    () async {
      final owner = MaterialTextures(seed: 71);
      var cases = 0, changedCases = 0, changedChannels = 0, maximumDelta = 0;
      final cut = Path()
        ..fillType = PathFillType.evenOdd
        ..addRRect(
          RRect.fromRectAndRadius(
            const Rect.fromLTWH(4, 4, 80, 60),
            const Radius.circular(11),
          ),
        )
        ..addOval(const Rect.fromLTWH(30, 20, 17, 17));
      try {
        for (final material in CraftMaterial.values) {
          for (final scale in [.5, 1.0, 2.5]) {
            for (final strength in [.1, .5, .9]) {
              for (final color in [
                const Color(0xFF9FC5DC),
                const Color(0x889FC5DC),
              ]) {
                Shader? sampledShader;
                Future<Uint8List> render(bool direct) => pixels((canvas) {
                  canvas.drawColor(const Color(0xFFF4EFE6), BlendMode.src);
                  canvas.translate(2, 3);
                  canvas.rotate(.07);
                  final proxy = TextureCanvas(canvas, directAlpha: direct);
                  owner.paint(
                    proxy,
                    cut,
                    material: material,
                    color: color,
                    scale: scale,
                    strength: strength,
                  );
                  sampledShader = proxy.shaders.single;
                });
                final a = await render(false);
                final legacy = await pixels((canvas) {
                  canvas.drawColor(const Color(0xFFF4EFE6), BlendMode.src);
                  canvas.translate(2, 3);
                  canvas.rotate(.07);
                  canvas.drawPath(cut, Paint()..color = color);
                  canvas.save();
                  canvas.clipPath(cut);
                  canvas.saveLayer(
                    cut.getBounds(),
                    Paint()..color = Color.fromRGBO(255, 255, 255, strength),
                  );
                  canvas.translate(cut.getBounds().left, cut.getBounds().top);
                  canvas.drawPaint(Paint()..shader = sampledShader);
                  canvas.restore();
                  canvas.restore();
                });
                expect(
                  a,
                  legacy,
                  reason: '${material.name}/$scale/$strength/$color',
                );
                final b = await render(true);
                var changed = false;
                for (var i = 0; i < a.length; i++) {
                  final delta = (a[i] - b[i]).abs();
                  if (delta > 0) {
                    changed = true;
                    changedChannels++;
                  }
                  if (delta > maximumDelta) maximumDelta = delta;
                }
                cases++;
                if (changed) changedCases++;
              }
            }
          }
        }
      } finally {
        owner.dispose();
      }
      // ignore: avoid_print
      print(
        'Opacity probe: $cases cases; $changedCases changed cases; $changedChannels changed channels; maximum delta $maximumDelta.',
      );
    },
  );
}
