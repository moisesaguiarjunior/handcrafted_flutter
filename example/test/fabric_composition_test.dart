import 'dart:typed_data';

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';
import 'package:handcrafted_flutter/src/testing/raster_fixture.dart';
import 'package:handcrafted_example/fabric_composition.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'a note enters behind the pocket face while its upper part remains visible',
    () async {
      final geometry = PocketGeometry(), textures = MaterialTextures(seed: 93);
      addTearDown(textures.dispose);
      Future<Uint8List> render(double insertion) => pixels((c) {
        c.drawColor(const Color(0xFFFFFAF1), BlendMode.src);
        c.scale(.5, 80 / 280);
        geometry.paint(
          c,
          textures,
          CraftLight(),
          color: const Color(0xFF73B6C8),
          insertion: insertion,
        );
      });
      final start = await render(0), end = await render(1);
      final upper = (16 * 100 + 49) * 4, inside = (60 * 100 + 65) * 4;
      expect(start[upper], greaterThan(end[upper] + 25));
      expect(
        end.sublist(inside, inside + 4),
        start.sublist(inside, inside + 4),
      );
      expect(end[inside], lessThan(180));
    },
  );
  test(
    'pocket sewing stays on its face and light changes the folded construction',
    () async {
      final geometry = PocketGeometry(), textures = MaterialTextures(seed: 93);
      addTearDown(textures.dispose);
      for (final metric in geometry.seam.computeMetrics()) {
        expect(
          geometry.front.contains(
            metric.getTangentForOffset(metric.length * .5)!.position,
          ),
          isTrue,
        );
      }
      Future<Uint8List> render(double x) => pixels((c) {
        c.drawColor(const Color(0xFFFFFAF1), BlendMode.src);
        c.scale(.5, 80 / 280);
        geometry.paint(
          c,
          textures,
          CraftLight(x: x),
          color: const Color(0xFF73B6C8),
        );
      });
      expect(await render(-1), isNot(await render(1)));
    },
  );
}
