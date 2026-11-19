import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';
import 'package:handcrafted_flutter/src/testing/raster_fixture.dart';
import 'package:handcrafted_example/fabric_composition.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  Future<Uint8List> render(PocketGeometry geometry, {double seam = .2}) async {
    final textures = MaterialTextures(seed: 93);
    try {
      return await pixels((c) {
        c.drawColor(const Color(0xFFFFFAF1), BlendMode.src);
        c.scale(.5, 80 / 280);
        geometry.paint(
          c,
          textures,
          CraftLight(),
          color: const Color(0xFF73B6C8),
          seamCompression: seam,
        );
      });
    } finally {
      textures.dispose();
    }
  }

  int changes(Uint8List a, Uint8List b, Rect rect) {
    var n = 0;
    for (var y = rect.top.toInt(); y < rect.bottom; y++) {
      for (var x = rect.left.toInt(); x < rect.right; x++) {
        final i = (y * 100 + x) * 4;
        if (a[i] != b[i] || a[i + 1] != b[i + 1] || a[i + 2] != b[i + 2]) n++;
      }
    }
    return n;
  }

  test(
    'mouth fold and thickness alter their actual regions; pressure is localized',
    () async {
      final open = await render(PocketGeometry()),
          closed = await render(PocketGeometry(opening: 0));
      expect(
        changes(open, closed, const Rect.fromLTWH(12, 12, 75, 24)),
        greaterThan(30),
      );
      final shallow = await render(PocketGeometry(foldDepth: 2)),
          deep = await render(PocketGeometry(foldDepth: 12));
      expect(
        changes(shallow, deep, const Rect.fromLTWH(10, 25, 80, 12)),
        greaterThan(20),
      );
      expect(changes(shallow, deep, const Rect.fromLTWH(30, 58, 35, 6)), 0);
      final thin = await render(PocketGeometry(surfaceHeight: 1)),
          thick = await render(PocketGeometry(surfaceHeight: 7));
      expect(
        changes(thin, thick, const Rect.fromLTWH(7, 35, 10, 30)),
        greaterThan(20),
      );
      final geometry = PocketGeometry(),
          unpressed = await render(PocketGeometry(), seam: 0);
      final pressed = await render(geometry, seam: 1);
      expect(
        changes(unpressed, pressed, const Rect.fromLTWH(10, 35, 78, 40)),
        greaterThan(30),
      );
      expect(changes(unpressed, pressed, const Rect.fromLTWH(60, 57, 6, 6)), 0);
    },
  );
  testWidgets(
    'paint-only pressure and insertion reuse geometry, mouth changes replace it',
    (tester) async {
      Widget app({
        double seam = .2,
        double insertion = .25,
        double opening = 1,
      }) => MaterialApp(
        home: Scaffold(
          body: FabricComposition(
            seamCompression: seam,
            insertion: insertion,
            pocketOpening: opening,
          ),
        ),
      );
      Object geometry() =>
          (tester
                          .widget<CustomPaint>(
                            find
                                .descendant(
                                  of: find.byType(FabricComposition),
                                  matching: find.byType(CustomPaint),
                                )
                                .first,
                          )
                          .painter
                      as dynamic)
                  .geometry
              as Object;
      await tester.pumpWidget(app());
      final first = geometry();
      await tester.pumpWidget(app(seam: .9, insertion: .8));
      expect(identical(geometry(), first), isTrue);
      await tester.pumpWidget(app(opening: .25));
      expect(identical(geometry(), first), isFalse);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
  test('invalid geometry is rejected before volume preparation', () {
    expect(() => PocketGeometry(opening: -1), throwsArgumentError);
    expect(() => PocketGeometry(foldDepth: double.nan), throwsArgumentError);
    expect(() => PocketGeometry(surfaceHeight: 9), throwsArgumentError);
  });
}
