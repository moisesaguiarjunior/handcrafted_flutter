import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcrafted_example/contact_poses.dart';
import 'package:handcrafted_example/contact_study.dart';
import 'package:handcrafted_example/gesture_surfaces.dart';
import 'package:handcrafted_example/main_gallery.dart';
import 'package:handcrafted_example/material_story_art.dart';
import 'package:handcrafted_example/projected_material.dart';
import 'package:handcrafted_example/soft_figure.dart';
import 'package:handcrafted_example/wind_art.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

void near(MaterialPoint a, MaterialPoint b) =>
    expect((a - b).dot(a - b), lessThan(1e-14));
double length(MaterialPoint p) => math.sqrt(p.dot(p));

Future<List<int>> pixels(ProjectedMaterial frame, PrintedMaterial print) async {
  final recorder = ui.PictureRecorder();
  frame.paint(Canvas(recorder), print, CraftLight());
  final picture = recorder.endRecording();
  final image = await picture.toImage(640, 360);
  picture.dispose();
  try {
    return (await image.toByteData())!.buffer.asUint8List().toList();
  } finally {
    image.dispose();
  }
}

void main() {
  test('lining turns, shoulder holds, delayed cuff settles for both cuts', () {
    for (final cut in ClothCut.values) {
      final first = LiftedClothFrame(0, cut);
      for (var i = 0; i <= 100; i++) {
        final f = LiftedClothFrame(i / 100, cut);
        expect(
          (f.sheet.cells.first.map(Offset(f.width / 2, 0)).screen -
                  const Offset(340, 84))
              .distance,
          lessThan(1e-8),
        );
        for (var row = 0; row < f.sheet.cells.length; row++) {
          final c = f.sheet.cells[row];
          for (var j = 0; j < 4; j++) {
            expect(length(c.front[j] - c.back[j]), closeTo(1.6, 1e-8));
            expect(c.center[j].z, greaterThanOrEqualTo(0));
          }
          if (row > 0) {
            final previous = f.sheet.cells[row - 1];
            near(previous.front[3], c.front[0]);
            near(previous.back[2], c.back[1]);
          }
        }
      }
      near(
        first.sheet.attach(Offset(first.width / 2, first.length)),
        LiftedClothFrame(
          .25,
          cut,
        ).sheet.attach(Offset(first.width / 2, first.length)),
      );
      final rest = LiftedClothFrame(1, cut);
      near(
        rest.sheet.attach(Offset(rest.width / 2, rest.length)),
        LiftedClothFrame(
          .95,
          cut,
        ).sheet.attach(Offset(rest.width / 2, rest.length)),
      );
      expect(first.sheet.height, greaterThan(rest.sheet.height + 5));
      expect(
        first.sheet.groundShadow(CraftLight()).getBounds(),
        isNot(rest.sheet.groundShadow(CraftLight()).getBounds()),
      );
    }
  });

  test('two hinges preserve midline, thickness and stay above the board', () {
    for (var i = 0; i <= 100; i++) {
      final f = FoldedPaperFrame(i / 100);
      for (var panel = 0; panel < 3; panel++) {
        final c = f.sheet.cells[panel];
        for (var j = 0; j < 4; j++) {
          expect(length(c.front[j] - c.back[j]), closeTo(.8, 1e-8));
          expect(c.front[j].z, greaterThanOrEqualTo(-1e-8));
          expect(c.back[j].z, greaterThanOrEqualTo(-1e-8));
        }
        if (panel > 0) {
          near(f.sheet.cells[panel - 1].center[1], c.center[0]);
          near(f.sheet.cells[panel - 1].center[2], c.center[3]);
        }
        expect(length(c.center[1] - c.center[0]), closeTo(80, 1e-8));
      }
    }
    final open = FoldedPaperFrame(1);
    expect(open.angles, everyElement(0));
    expect(open.hinges.last.x, 440);
    expect(FoldedPaperFrame(0).angles[1], greaterThan(math.pi / 2));
  });

  test('paper guide uses its fixed hinge and tracks the second fold axis', () {
    final sources = materialGuideSources(
      MaterialRecipe.paper,
      FoldedPaperFrame.size,
    );
    expect(sources[0], const Offset(80, 0));
    expect(sources[1], const Offset(160, 0));
    final fixed = FoldedPaperFrame(0).sheet.surfacePoint(sources[0]);
    for (var i = 0; i <= 100; i++) {
      final f = FoldedPaperFrame(i / 100);
      near(f.sheet.surfacePoint(sources[0]), fixed);
      near(f.sheet.attach(sources[1]), f.hinges[2]);
    }
  });

  test(
    'actual raster changes lining, retains print and random-access output',
    () async {
      final textures = MaterialTextures(seed: 143);
      final print = PrintedMaterial(
        const Size(54, 200),
        textures,
        material: CraftMaterial.linen,
        frontColor: Colors.green,
        backColor: Colors.amber,
      );
      try {
        final folded = await pixels(
          LiftedClothFrame(0, ClothCut.sleeve).sheet,
          print,
        );
        final open = await pixels(
          LiftedClothFrame(1, ClothCut.sleeve).sheet,
          print,
        );
        int yellow(List<int> p) {
          var n = 0;
          for (var i = 0; i < p.length; i += 4) {
            if (p[i] > 120 &&
                p[i + 1] > 80 &&
                p[i + 2] < 70 &&
                p[i + 3] > 240) {
              n++;
            }
          }
          return n;
        }

        expect(yellow(folded), greaterThan(yellow(open) + 100));
        final source = print.front;
        final reference = await pixels(
          LiftedClothFrame(.5, ClothCut.sleeve).sheet,
          print,
        );
        for (final t in [1.0, .25, .75, 0.0]) {
          await pixels(LiftedClothFrame(t, ClothCut.sleeve).sheet, print);
          expect(print.front, same(source));
        }
        expect(
          await pixels(LiftedClothFrame(.5, ClothCut.sleeve).sheet, print),
          reference,
        );
      } finally {
        print.dispose();
        textures.dispose();
      }
    },
  );

  test(
    'paper raster exposes real reverse and continuous opaque open print',
    () async {
      final textures = MaterialTextures(seed: 143);
      final print = PrintedMaterial(
        FoldedPaperFrame.size,
        textures,
        material: CraftMaterial.paper,
        frontColor: Colors.white,
        backColor: Colors.blue,
        paper: true,
      );
      try {
        final closed = await pixels(FoldedPaperFrame(0).sheet, print);
        final open = await pixels(FoldedPaperFrame(1).sheet, print);
        int blue(List<int> p) {
          var n = 0;
          for (var i = 0; i < p.length; i += 4) {
            if (p[i + 2] > p[i] + 40 &&
                p[i + 2] > p[i + 1] + 10 &&
                p[i + 3] > 240) {
              n++;
            }
          }
          return n;
        }

        expect(blue(closed), greaterThan(50));
        expect(blue(open), 0);
        for (final x in [279, 280, 281, 359, 360, 361]) {
          expect(
            open[(185 * 640 + x) * 4 + 3],
            255,
            reason: 'opaque crease at $x',
          );
        }
      } finally {
        print.dispose();
        textures.dispose();
      }
    },
  );

  test(
    'arm lengths and mapped grip remain exact, head tilts independently',
    () {
      for (var i = 0; i <= 100; i++) {
        final f = SoftFigureFrame(i / 100);
        expect(
          (f.elbow - SoftFigureFrame.shoulder).distance,
          closeTo(63, 1e-8),
        );
        expect((f.hand - f.elbow).distance, closeTo(57, 1e-8));
        final endpoint = f.lower.mapPoint(
          const Offset(57, 0),
          size: Size.zero,
          pivot: Alignment.topLeft,
        );
        expect((endpoint - f.hand).distance, lessThan(1e-8));
        if (f.touching) expect((f.hand - f.grip).distance, lessThan(1e-8));
      }
      expect(
        SoftFigureFrame(1).grip.dx,
        lessThan(SoftFigureFrame(.3).grip.dx - 40),
      );
      expect(
        SoftFigureFrame(1).head.rotation,
        isNot(SoftFigureFrame(0).head.rotation),
      );
    },
  );

  test(
    'one gust has distinct lags, fixed supports and a geometry-derived shadow',
    () {
      expect(AuthoredGust(.2).curtain, greaterThan(0));
      expect(AuthoredGust(.2).note, 0);
      expect(AuthoredGust(.3).note, greaterThan(0));
      expect(AuthoredGust(.3).plant, 0);
      final art = WindArt(), light = CraftLight();
      for (var i = 0; i <= 100; i++) {
        final f = WindMaterialFrame(i / 100), start = WindMaterialFrame(0);
        near(
          f.curtain.cells.first.center[0],
          start.curtain.cells.first.center[0],
        );
        near(
          f.curtain.cells.first.center[1],
          start.curtain.cells.first.center[1],
        );
        near(f.note.cells.single.center[0], start.note.cells.single.center[0]);
        near(f.note.cells.single.center[3], start.note.cells.single.center[3]);
      }
      expect(
        art.plantShadow(WindMaterialFrame(.65), light).getBounds(),
        isNot(art.plantShadow(WindMaterialFrame(0), light).getBounds()),
      );
      final end = AuthoredGust(1);
      expect([end.curtain, end.note, end.plant], everyElement(0));
      final supplied = WindMaterialFrame(
        .1,
        supplied: AuthoredGust.responses(curtain: 0, note: 1, plant: 0),
      );
      expect(supplied.note.height, greaterThan(50));
      expect(supplied.curtain.height, 1);
      expect(
        () => AuthoredGust.responses(curtain: double.nan, note: 0, plant: 0),
        throwsArgumentError,
      );
    },
  );

  testWidgets(
    'all recipes paint deterministically at phone scale and parent rotation',
    (tester) async {
      Future<List<int>> frame(
        MaterialRecipe recipe,
        double p,
        FigureMaterial material,
      ) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Center(
              child: RepaintBoundary(
                key: const ValueKey('raster'),
                child: SizedBox(
                  width: 360,
                  height: 203,
                  child: MaterialStoryArtwork(
                    recipe: recipe,
                    progress: p,
                    material: material,
                    cameraAngle: .1,
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pump();
        final boundary = tester.renderObject<RenderRepaintBoundary>(
          find.byKey(const ValueKey('raster')),
        );
        return (await tester.runAsync(() async {
          final image = await boundary.toImage();
          try {
            return (await image.toByteData())!.buffer.asUint8List().toList();
          } finally {
            image.dispose();
          }
        }))!;
      }

      for (final recipe in MaterialRecipe.values) {
        final reference = await frame(recipe, .5, FigureMaterial.felt);
        for (final t in [1.0, 0.0, .75, .25]) {
          await frame(recipe, t, FigureMaterial.felt);
        }
        expect(await frame(recipe, .5, FigureMaterial.felt), reference);
        if (recipe == MaterialRecipe.figure) {
          expect(
            await frame(recipe, .5, FigureMaterial.linen),
            isNot(reference),
          );
          expect(
            await frame(recipe, .5, FigureMaterial.clay),
            isNot(reference),
          );
        }
      }
      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'native controls retain focus, pause visibility and respect 250% text and reduced motion',
    (tester) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      Future<void> mount({bool active = true, bool reduced = false}) =>
          tester.pumpWidget(
            MaterialApp(
              home: MediaQuery(
                data: MediaQueryData(
                  textScaler: const TextScaler.linear(2.5),
                  disableAnimations: reduced,
                ),
                child: Scaffold(
                  body: SingleChildScrollView(
                    child: ContactStudy(
                      initialRecipe: MaterialRecipe.figure,
                      active: active,
                    ),
                  ),
                ),
              ),
            ),
          );
      await mount();
      await tester.pumpAndSettle();
      final button = find.byKey(const ValueKey('contact-play'));
      await tester.ensureVisible(button);
      final node = Focus.of(
        tester.element(
          find.descendant(of: button, matching: find.text('Play')),
        ),
      );
      node.requestFocus();
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      final before = tester
          .widget<MaterialStoryArtwork>(find.byType(MaterialStoryArtwork))
          .progress;
      expect(before, greaterThan(0));
      expect(node.hasPrimaryFocus, isTrue);
      await mount(active: false);
      await tester.pump(const Duration(seconds: 2));
      expect(
        tester
            .widget<MaterialStoryArtwork>(find.byType(MaterialStoryArtwork))
            .progress,
        before,
      );
      for (final recipe in MaterialRecipe.values) {
        final label = materialRecipeTitle(recipe);
        await tester.ensureVisible(find.text(label));
        await tester.tap(find.text(label));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
      await mount(reduced: true);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<MaterialStoryArtwork>(find.byType(MaterialStoryArtwork))
            .progress,
        1,
      );
      expect(tester.binding.hasScheduledFrame, isFalse);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('breeze adjustable semantics includes its name and value', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: ContactStudy(initialRecipe: MaterialRecipe.wind),
          ),
        ),
      ),
    );
    await tester.ensureVisible(find.byKey(const ValueKey('gust-strength')));
    await tester.pumpAndSettle();
    final node = tester.getSemantics(
      find.byKey(const ValueKey('gust-strength')),
    );
    final data = node.getSemanticsData();
    expect(data.label, contains('Breeze strength'));
    expect(data.value, '100 percent');
    expect(data.hasAction(ui.SemanticsAction.decrease), isTrue);
    for (final item in [
      ('contact-progress', 'Gesture progress'),
      ('contact-camera-angle', 'Composition angle'),
    ]) {
      await tester.ensureVisible(find.byKey(ValueKey(item.$1)));
      await tester.pumpAndSettle();
      final control = tester
          .getSemantics(find.byKey(ValueKey(item.$1)))
          .getSemanticsData();
      expect(control.label, contains(item.$2));
      expect(control.value, isNotEmpty);
      expect(control.hasAction(ui.SemanticsAction.increase), isTrue);
    }
    semantics.dispose();
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('sources survive frames and are disposed on recipe replacement', (
    tester,
  ) async {
    final created = <ui.Image>{}, disposed = <ui.Image>{};
    final oldCreate = ui.Image.onCreate, oldDispose = ui.Image.onDispose;
    ui.Image.onCreate = (image) {
      oldCreate?.call(image);
      if (image.width == 108 && image.height == 400) created.add(image);
    };
    ui.Image.onDispose = (image) {
      oldDispose?.call(image);
      if (created.contains(image)) disposed.add(image);
    };
    addTearDown(() {
      ui.Image.onCreate = oldCreate;
      ui.Image.onDispose = oldDispose;
    });
    for (final t in [0.0, .25, .5, .75, 1.0]) {
      await tester.pumpWidget(
        MaterialApp(
          home: MaterialStoryArtwork(
            key: const ValueKey('cloth'),
            recipe: MaterialRecipe.cloth,
            progress: t,
          ),
        ),
      );
      await tester.pump();
      expect(created, hasLength(2));
      expect(disposed, isEmpty);
    }
    await tester.pumpWidget(
      const MaterialApp(
        home: MaterialStoryArtwork(
          key: ValueKey('paper'),
          recipe: MaterialRecipe.paper,
          progress: 0,
        ),
      ),
    );
    await tester.pump();
    expect(disposed, unorderedEquals(created));
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('gallery routes to extended recipes', (tester) async {
    await tester.pumpWidget(
      const HandcraftedGalleryApp(initialStudy: GalleryStudy.gestures),
    );
    await tester.pumpAndSettle();
    expect(find.byType(MaterialStoryArtwork), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
