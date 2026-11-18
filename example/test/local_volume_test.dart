import 'dart:typed_data';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_test/flutter_test.dart';
import 'package:handcrafted_example/local_volume.dart';
import 'package:handcrafted_example/volume_studies.dart';

import 'support/fonts.dart';

import 'package:handcrafted_example/test_support/raster.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  Path cut() => Path()..addOval(const Rect.fromLTWH(18, 12, 60, 54));
  Future<Uint8List> sample(PreparedVolume model, VolumeLight light) =>
      pixels((c) {
        c.drawColor(const Color(0xFFF8F1E7), BlendMode.src);
        c.drawPath(model.outline, Paint()..color = const Color(0xFFEFA07C));
        model.shade(c, light);
      });

  test('profiles differ with the same cut, color and light', () async {
    final sheet = PreparedVolume(cut(), VolumeProfile.sheet);
    final rounded = PreparedVolume(cut(), VolumeProfile.rounded);
    expect(
      await sample(sheet, VolumeLight()),
      isNot(await sample(rounded, VolumeLight())),
    );
    expect(
      await sample(rounded, VolumeLight()),
      await sample(PreparedVolume(cut(), VolumeProfile.rounded), VolumeLight()),
    );
  });

  test(
    'direction and warmth change paint without changing prepared geometry',
    () async {
      final model = PreparedVolume(cut(), VolumeProfile.rounded);
      final geometry = Float32List.fromList(model.positions);
      final normals = Float32List.fromList(model.normals);
      final left = await sample(
        model,
        VolumeLight(x: -1, ambient: .5, warmth: 0),
      );
      expect(
        left,
        isNot(await sample(model, VolumeLight(x: 1, ambient: .5, warmth: 0))),
      );
      expect(
        left,
        isNot(await sample(model, VolumeLight(x: -1, ambient: .5, warmth: 1))),
      );
      expect(model.positions, geometry);
      expect(model.normals, normals);
    },
  );

  test('source mutation does not change the prepared cut', () {
    final source = cut();
    final model = PreparedVolume(source, VolumeProfile.sheet);
    source.reset();
    expect(model.outline.contains(const Offset(48, 39)), isTrue);
  });

  test(
    'receiver clipping preserves the paper outside and inside its hole',
    () async {
      final model = PreparedVolume(cut(), VolumeProfile.rounded);
      final receiver = Path()
        ..fillType = PathFillType.evenOdd
        ..addRect(const Rect.fromLTWH(30, 10, 50, 65))
        ..addRect(const Rect.fromLTWH(40, 30, 15, 15));
      final ink = await pixels((c) {
        c.drawColor(Colors.white, BlendMode.src);
        model.shadow(c, VolumeLight(), receiver: receiver, lift: 8);
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
    expect(() => VolumeLight(z: 0), throwsArgumentError);
    expect(() => VolumeLight(warmth: double.nan), throwsArgumentError);
    expect(
      () => PreparedVolume(Path()..lineTo(30, 30), VolumeProfile.sheet),
      throwsArgumentError,
    );
    expect(
      () => PreparedVolume(
        Path()..addRect(const Rect.fromLTWH(0, 0, 321, 4)),
        VolumeProfile.sheet,
      ),
      throwsArgumentError,
    );
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    expect(
      () => PreparedVolume(
        cut(),
        VolumeProfile.sheet,
      ).shadow(canvas, VolumeLight(), lift: 25),
      throwsArgumentError,
    );
    recorder.endRecording().dispose();
  });
  test(
    'slow light travel changes continuously without geometry jumps',
    () async {
      final model = PreparedVolume(cut(), VolumeProfile.rounded);
      final first = await sample(model, VolumeLight(x: -.8));
      var previous = first;
      for (var step = 1; step <= 20; step++) {
        final next = await sample(model, VolumeLight(x: -.8 + step * .08));
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
      final model = PreparedVolume(cut(), VolumeProfile.sheet);
      final light = VolumeLight(x: -1, y: 0, ambient: .5, warmth: 0);
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
      final model = PreparedVolume(cut(), VolumeProfile.sheet);
      Future<Uint8List> shadow(double lift, double direct) => pixels((c) {
        c.drawColor(Colors.white, BlendMode.src);
        model.shadow(c, VolumeLight(direct: direct), lift: lift);
      });
      expect(await shadow(0, .43), isNot(await shadow(20, .43)));
      expect(await shadow(0, 0), await shadow(20, 0));
    },
  );
  test('temporary meshes and canvas stack survive normal and failed draws', () {
    final model = PreparedVolume(cut(), VolumeProfile.sheet);
    for (final fail in [false, true]) {
      final canvas = _MeshCanvas(fail);
      if (fail) {
        expect(() => model.shade(canvas, VolumeLight()), throwsStateError);
      } else {
        model.shade(canvas, VolumeLight());
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
        () => PreparedVolume(
          Path()..addRect(const Rect.fromLTWH(0, 0, 300, 300)),
          VolumeProfile.rounded,
        ),
        throwsArgumentError,
      );
    },
  );
  for (final width in [320.0, 390.0]) {
    testWidgets('native volume controls at $width and enlarged text', (
      tester,
    ) async {
      await tester.runAsync(loadShowcaseFonts);
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 900);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(2.5)),
            child: child!,
          ),
          home: const Scaffold(
            body: SingleChildScrollView(child: LocalVolumePlayground()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final slider = find.byKey(const ValueKey('volume-direction'));
      final before = tester.widget<Slider>(slider).value;
      await tester.ensureVisible(slider);
      await tester.drag(slider, const Offset(80, 0));
      await tester.pumpAndSettle();
      expect(tester.widget<Slider>(slider).value, greaterThan(before));
      final elevation = tester.widget<Slider>(
        find.byKey(const ValueKey('volume-elevation')),
      );
      expect(elevation.semanticFormatterCallback!(1), '1.00 relative units');
      await tester.ensureVisible(
        find.text('At screen size: the same three cuts together'),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final compact = find.byWidgetPredicate(
        (w) => w is VolumeStudies && w.compact,
      );
      final paintSize = tester.getSize(
        find.descendant(of: compact, matching: find.byType(CustomPaint)).first,
      );
      expect(paintSize.aspectRatio, closeTo(300 / 160, .00001));
      await tester.pumpWidget(const SizedBox());
      expect(tester.binding.transientCallbackCount, 0);
    });
  }
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
