import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

import '../example/lib/living_material_art.dart';
import '../example/lib/motion_studies.dart';
import 'support/raster.dart';

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
  test('moving brush deposits change over time without changing earlier recipe inputs', () async {
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
  test('balloon and kite have different authored rhythms on the same supplied time', () {
    final kite = studySway(.4), balloon = studyBalloonDrift(.4);
    expect(kite.rotation, isNot(closeTo(balloon.rotation, .001)));
    expect(kite.translation, isNot(balloon.translation));
    expect(studyBalloonDrift(0).translation, Offset.zero);
    expect(studyBalloonDrift(1).translation, Offset.zero);
    expect(studyBalloonDrift(.4).translation, balloon.translation);
  });
}
