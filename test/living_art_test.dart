import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

import '../example/lib/living_material_art.dart';
import '../example/lib/living_materials.dart' show LivingMaterialArtwork;
import '../example/lib/motion_studies.dart';
import 'support/raster.dart';
import 'support/widget_raster.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('dry and wet pink bases react differently while time and layer content replay', () async {
    Future<List<int>> render(double wetness, double progress) => pixels((c) {
      c.drawColor(const Color(0xFFFFFDF8), BlendMode.src);
      LivingMaterialPainter(
        LivingTechnique.watercolor,
        progress,
        experiment: WatercolorExperiment.layers,
        wetness: wetness,
      ).paint(c, const Size(100, 80));
    });
    final dry = await render(0, .6), wet = await render(1, .6);
    expect(dry, isNot(wet));
    await render(.3, .15);
    expect(wet, await render(1, .6));
    expect(
      await render(1, 0),
      await render(0, 0),
      reason: 'The existing pink layer precedes the new brush contact',
    );
    expect(wet, isNot(await render(1, .2)));
  });
  test('moving brush wash changes over time without changing earlier recipe inputs', () async {
    Future<List<int>> render(double p) => pixels(
      (c) => LivingMaterialPainter(
        LivingTechnique.watercolor,
        p,
        experiment: WatercolorExperiment.stroke,
      ).paint(c, const Size(100, 80)),
    );
    final early = await render(.2), late = await render(.8);
    expect(early, isNot(late));
    expect(early, await render(.2));
  });
  test(
    'dragged wash stays on a continuous swept band with an unpainted future',
    () async {
      final route = craftCurveThrough(const [
        Offset(90, 230),
        Offset(210, 125),
        Offset(355, 220),
        Offset(485, 125),
      ]).computeMetrics().single;
      final samples = [
        for (var i = 0; i <= 128; i++)
          route.getTangentForOffset(route.length * i / 128)!.position,
      ];
      Future<List<int>> render(double p, {bool fade = true}) => pixels(
        (c) => LivingMaterialPainter(
          LivingTechnique.watercolor,
          p,
          experiment: WatercolorExperiment.stroke,
          wetness: 1,
          showBrush: false,
          fadeBrush: fade,
        ).paint(c, const Size(100, 80)),
      );
      final finalInk = await render(1);
      for (var i = 2; i < 127; i++) {
        final point = samples[i];
        expect(
          finalInk[((point.dy * 80 / 375).floor() * 100 +
                      (point.dx / 6).floor()) *
                  4 +
              3],
          greaterThan(0),
          reason: 'Continuous centerline at $i',
        );
      }
      for (var y = 0; y < 80; y++) {
        for (var x = 0; x < 100; x++) {
          if (finalInk[(y * 100 + x) * 4 + 3] == 0) continue;
          final point = Offset((x + .5) * 6, (y + .5) * 375 / 80);
          final nearest = samples
              .map((p) => (point - p).distance)
              .reduce((a, b) => a < b ? a : b);
          expect(
            nearest,
            lessThan(39),
            reason: 'No separate circular bloom outside the dragged band',
          );
        }
      }
      final early = await render(.25);
      expect(
        early[(26 * 100 + 80) * 4 + 3],
        0,
        reason: 'The future endpoint is still dry',
      );
      expect(early, await render(.25));
      expect(
        finalInk,
        await render(1, fade: false),
        reason: 'Prop visibility does not alter pigment',
      );
    },
  );
  testWidgets(
    'brush visibility and fade changes repaint at fixed progress without changing the wash',
    (tester) async {
      final boundary = GlobalKey();
      Widget view(bool show, bool fade) => MaterialApp(
        home: Center(
          child: RepaintBoundary(
            key: boundary,
            child: SizedBox(
              width: 600,
              child: LivingMaterialArtwork(
                technique: LivingTechnique.watercolor,
                progress: 1,
                experiment: WatercolorExperiment.stroke,
                showBrush: show,
                fadeBrush: fade,
              ),
            ),
          ),
        ),
      );
      await tester.pumpWidget(view(true, true));
      await tester.pumpAndSettle();
      final hidden = await widgetPixels(tester, boundary);
      await tester.pumpWidget(view(true, false));
      await tester.pumpAndSettle();
      expect(await widgetPixels(tester, boundary), isNot(hidden));
      await tester.pumpWidget(view(false, false));
      await tester.pumpAndSettle();
      expect(await widgetPixels(tester, boundary), hidden);
    },
  );
  test('thread passes have nonperiodic motion and never paint the below-cloth connectors', () async {
    Future<List<int>> render(double p) => pixels(
      (c) => LivingMaterialPainter(
        LivingTechnique.embroidery,
        p,
      ).paint(c, const Size(100, 80)),
    );
    final first = await render(.13);
    expect(first, await render(.13));
    expect(first, isNot(await render(.57)));
    for (final p in [0.0, .13, .42, .81, 1.0]) {
      final image = await render(p);
      expect(
        image[(42 * 100 + 41) * 4 + 3],
        0,
        reason: 'Connector is beneath the cloth at $p',
      );
    }
    final end = await render(1);
    expect(
      [
        for (var y = 44; y < 48; y++)
          for (var x = 31; x < 36; x++) end[(y * 100 + x) * 4 + 3],
      ].any((v) => v > 0),
      isTrue,
    );
  });
  test(
    'finishing preserves existing stitches and adds the chosen count in order',
    () async {
      Future<List<int>> render(double p, int remaining) => pixels(
        (c) => LivingMaterialPainter(
          LivingTechnique.embroidery,
          p,
          threadExperiment: ThreadExperiment.finishing,
          remainingStitches: remaining,
        ).paint(c, const Size(100, 80)),
      );
      final start = await render(0, 4);
      expect(
        start.any((v) => v > 0),
        isTrue,
        reason: 'The seam is already mostly sewn',
      );
      expect(start, isNot(await render(0, 1)));
      expect(start, isNot(await render(0, 8)));
      expect(
        await render(.25, 4),
        await render(0, 3),
        reason: 'Exactly one of the four missing stitches has settled',
      );
      expect(await render(.5, 4), await render(0, 2));
      expect(await render(.75, 4), await render(0, 1));
      expect(
        await render(.23, 4),
        await render(.25, 4),
        reason: 'The hidden return adds no visible connector',
      );
      final moving = await render(.08, 4);
      expect(moving, isNot(start));
      expect(moving, isNot(await render(.15, 4)));
      await render(.8, 8);
      expect(
        moving,
        await render(.08, 4),
        reason: 'Scroll reversal is deterministic',
      );
      expect(await render(1, 1), await render(1, 4));
      expect(await render(1, 4), await render(1, 8));
    },
  );
  test('loose thread and needle props are independent and hidden below cloth', () async {
    Future<List<int>> render(double p, bool loose, bool needle) => pixels(
      (c) => LivingMaterialPainter(
        LivingTechnique.embroidery,
        p,
        threadExperiment: ThreadExperiment.embroidery,
        showLooseThread: loose,
        showNeedle: needle,
      ).paint(c, const Size(100, 80)),
    );
    // One strand is underway near the start of the reveal.
    final plain = await render(.003, false, false);
    expect(await render(.003, true, false), isNot(plain));
    expect(await render(.003, false, true), isNot(plain));
    expect(
      await render(.003, true, true),
      isNot(await render(.003, true, false)),
    );
    // Every contour uses .72 above-cloth and .28 hidden return. Probe within
    // the first return interval (the authored sprig currently has >100 spans).
    final seam = Path()
      ..moveTo(270, 290)
      ..cubicTo(275, 230, 330, 160, 310, 65);
    final total =
        craftStitchPath(
          seam,
          kind: CraftStitchKind.backstitch,
          pitch: 9,
        ).computeMetrics().length +
        100;
    final below = .9 / total;
    expect(await render(below, true, true), await render(below, false, false));
    expect(await render(1, true, true), await render(1, false, false));
  });
  test('balloon and kite have different authored rhythms on the same supplied time', () {
    final kite = studySway(.4), balloon = studyBalloonDrift(.4);
    expect(kite.rotation, isNot(closeTo(balloon.rotation, .001)));
    expect(kite.translation, isNot(balloon.translation));
    expect(studyBalloonDrift(0).translation, Offset.zero);
    expect(studyBalloonDrift(1).translation, Offset.zero);
    expect(studyBalloonDrift(.4).translation, balloon.translation);
  });
}
