import 'dart:typed_data';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_test/flutter_test.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

import 'support/raster.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  Path cut() => Path()..addOval(const Rect.fromLTWH(18, 12, 60, 54));
  Future<Uint8List> sample(CraftVolume model, CraftLight light) => pixels((c) {
    c.drawColor(const Color(0xFFF8F1E7), BlendMode.src);
    c.drawPath(model.outline, Paint()..color = const Color(0xFFEFA07C));
    model.shade(c, light);
  });

  test('profiles differ with the same cut, color and light', () async {
    final sheet = CraftVolume(cut(), CraftVolumeProfile.sheet);
    final rounded = CraftVolume(cut(), CraftVolumeProfile.rounded);
    expect(
      await sample(sheet, CraftLight()),
      isNot(await sample(rounded, CraftLight())),
    );
    expect(
      await sample(rounded, CraftLight()),
      await sample(
        CraftVolume(cut(), CraftVolumeProfile.rounded),
        CraftLight(),
      ),
    );
  });

  test(
    'direction and warmth change paint without changing prepared geometry',
    () async {
      final model = CraftVolume(cut(), CraftVolumeProfile.rounded);
      final left = await sample(
        model,
        CraftLight(x: -1, ambient: .5, warmth: 0),
      );
      expect(
        left,
        isNot(await sample(model, CraftLight(x: 1, ambient: .5, warmth: 0))),
      );
      expect(
        left,
        isNot(await sample(model, CraftLight(x: -1, ambient: .5, warmth: 1))),
      );
      expect(
        await sample(model, CraftLight(x: -1, ambient: .5, warmth: 0)),
        left,
      );
    },
  );

  test('source mutation does not change the prepared cut', () {
    final source = cut();
    final model = CraftVolume(source, CraftVolumeProfile.sheet);
    source.reset();
    model.outline.reset();
    expect(model.outline.contains(const Offset(48, 39)), isTrue);
  });

  test(
    'receiver clipping preserves the paper outside and inside its hole',
    () async {
      final model = CraftVolume(cut(), CraftVolumeProfile.rounded);
      final receiver = Path()
        ..fillType = PathFillType.evenOdd
        ..addRect(const Rect.fromLTWH(30, 10, 50, 65))
        ..addRect(const Rect.fromLTWH(40, 30, 15, 15));
      final ink = await pixels((c) {
        c.drawColor(Colors.white, BlendMode.src);
        model.shadow(c, CraftLight(), receiver: receiver, lift: 8);
      });
      for (final point in [const Offset(25, 40), const Offset(47, 37)]) {
        final i = (point.dy.toInt() * 100 + point.dx.toInt()) * 4;
        expect(ink.sublist(i, i + 4), [255, 255, 255, 255]);
      }
      final i = (50 * 100 + 60) * 4;
      expect(ink.sublist(i, i + 3), isNot([255, 255, 255]));
    },
  );

  test('invalid light and open or oversized cuts are rejected', () {
    expect(() => CraftLight(z: 0), throwsArgumentError);
    expect(() => CraftLight(warmth: double.nan), throwsArgumentError);
    expect(
      () => CraftVolume(Path()..lineTo(30, 30), CraftVolumeProfile.sheet),
      throwsArgumentError,
    );
    expect(
      () => CraftVolume(
        Path()..addRect(const Rect.fromLTWH(0, 0, 321, 4)),
        CraftVolumeProfile.sheet,
      ),
      throwsArgumentError,
    );
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    expect(
      () => CraftVolume(
        cut(),
        CraftVolumeProfile.sheet,
      ).shadow(canvas, CraftLight(), lift: 25),
      throwsArgumentError,
    );
    recorder.endRecording().dispose();
  });
  test(
    'slow light travel changes continuously without geometry jumps',
    () async {
      final model = CraftVolume(cut(), CraftVolumeProfile.rounded);
      final first = await sample(model, CraftLight(x: -.8));
      var previous = first;
      for (var step = 1; step <= 20; step++) {
        final next = await sample(model, CraftLight(x: -.8 + step * .08));
        var largest = 0;
        for (var i = 0; i < next.length; i++) {
          largest = math.max(largest, (next[i] - previous[i]).abs());
        }
        expect(largest, lessThanOrEqualTo(8));
        previous = next;
      }
      expect(previous, isNot(first));
    },
  );
  test(
    'rotating a piece keeps the bright edge facing the scene source',
    () async {
      final model = CraftVolume(cut(), CraftVolumeProfile.sheet);
      final light = CraftLight(x: -1, y: 0, ambient: .5, warmth: 0);
      Future<Uint8List> turned(bool convert) => pixels((c) {
        c.drawColor(const Color(0xFFF8F1E7), BlendMode.src);
        c.translate(48, 39);
        c.rotate(math.pi);
        c.translate(-48, -39);
        c.drawPath(model.outline, Paint()..color = const Color(0xFFEFA07C));
        model.shade(c, convert ? light.inLocalSpace(math.pi) : light);
      });
      final baseline = await sample(model, light);
      final correct = await turned(true), incorrect = await turned(false);
      int error(Uint8List candidate) {
        var total = 0;
        for (var y = 16; y < 62; y++) {
          for (var x = 22; x < 74; x++) {
            if (!model.outline.contains(Offset(x + .5, y + .5))) continue;
            final i = (y * 100 + x) * 4;
            total += (candidate[i] - baseline[i]).abs();
          }
        }
        return total;
      }

      expect(error(incorrect), greaterThan(100));
      expect(error(correct), lessThan(error(incorrect) * .15));
    },
  );
  test(
    'shadow lift moves projection and zero directional light removes it',
    () async {
      final model = CraftVolume(cut(), CraftVolumeProfile.sheet);
      Future<Uint8List> shadow(double lift, double direct) => pixels((c) {
        c.drawColor(Colors.white, BlendMode.src);
        model.shadow(c, CraftLight(direct: direct), lift: lift);
      });
      expect(await shadow(0, .43), isNot(await shadow(20, .43)));
      expect(await shadow(0, 0), await shadow(20, 0));
    },
  );
  test('temporary meshes and canvas stack survive normal and failed draws', () {
    final model = CraftVolume(cut(), CraftVolumeProfile.sheet);
    for (final fail in [false, true]) {
      final canvas = _MeshCanvas(fail);
      if (fail) {
        expect(() => model.shade(canvas, CraftLight()), throwsStateError);
      } else {
        model.shade(canvas, CraftLight());
      }
      expect(canvas.meshes, hasLength(2));
      expect(canvas.meshes.every((m) => m.debugDisposed), isTrue);
      expect(canvas.depth, 0);
    }
  });
  test('raster fixture closes the recording if its painter throws', () async {
    final oldCreate = ui.Picture.onCreate, oldDispose = ui.Picture.onDispose;
    final created = <ui.Picture>[], disposed = <ui.Picture>[];
    ui.Picture.onCreate = (p) {
      created.add(p);
      oldCreate?.call(p);
    };
    ui.Picture.onDispose = (p) {
      disposed.add(p);
      oldDispose?.call(p);
    };
    try {
      await expectLater(
        pixels((c) => throw StateError('Fixture failure')),
        throwsStateError,
      );
      expect(created, hasLength(1));
      expect(disposed, orderedEquals(created));
    } finally {
      ui.Picture.onCreate = oldCreate;
      ui.Picture.onDispose = oldDispose;
    }
  }, skip: kIsWeb); // Native lifecycle callbacks are the observation mechanism.

  test(
    'preparation rejects excessive contour work before creating a field',
    () {
      expect(
        () => CraftVolume(
          Path()..addRect(const Rect.fromLTWH(0, 0, 300, 300)),
          CraftVolumeProfile.rounded,
        ),
        throwsArgumentError,
      );
    },
  );
}

class _MeshCanvas implements Canvas {
  _MeshCanvas(this.fail);
  final bool fail;
  final meshes = <ui.Vertices>[];
  int depth = 0;
  @override
  void save() => depth++;
  @override
  void restore() => depth--;
  @override
  void clipPath(Path path, {bool doAntiAlias = true}) {}
  @override
  void drawVertices(ui.Vertices vertices, BlendMode blendMode, Paint paint) {
    meshes.add(vertices);
    if (fail && meshes.length == 2) throw StateError('Deliberate draw failure');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
