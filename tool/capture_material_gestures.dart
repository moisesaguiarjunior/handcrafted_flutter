import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../example/lib/gesture_surfaces.dart';
import '../example/lib/material_story_art.dart';
import '../example/test/support/fonts.dart';
import 'capture_support.dart';

void main() {
  testWidgets('capture the actual material gesture recipes', (tester) async {
    await tester.runAsync(
      () => loadShowcaseFonts(directory: 'example/assets/fonts'),
    );
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await captureExample(
      tester,
      'build/gesture-surfaces.png',
      const Size(1400, 1000),
      Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Materials in a gesture',
              style: TextStyle(fontFamily: 'Caveat', fontSize: 48),
            ),
            for (final recipe in MaterialRecipe.values) ...[
              Text(
                materialRecipeTitle(recipe),
                style: const TextStyle(fontSize: 20),
              ),
              Row(
                children: [
                  for (final t in [0.0, .25, .5, .75, 1.0])
                    Expanded(
                      child: Column(
                        children: [
                          MaterialStoryArtwork(recipe: recipe, progress: t),
                          Text('${(t * 100).round()}%'),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
    for (final recipe in MaterialRecipe.values) {
      await captureExample(
        tester,
        'build/${recipe.name}-viewport.png',
        const Size(360, 240),
        MaterialStoryArtwork(recipe: recipe, progress: .25),
      );
    }
    for (var i = 0; i < 48; i++) {
      final t = (i / 39).clamp(0.0, 1.0);
      await captureExample(
        tester,
        'build/material-gesture-frames/${i.toString().padLeft(3, '0')}.png',
        const Size(960, 600),
        Column(
          children: [
            for (final row in [
              [MaterialRecipe.cloth, MaterialRecipe.figure],
              [MaterialRecipe.wind, MaterialRecipe.paper],
            ])
              Row(
                children: [
                  for (final recipe in row)
                    Expanded(
                      child: Column(
                        children: [
                          Text(materialRecipeTitle(recipe)),
                          MaterialStoryArtwork(recipe: recipe, progress: t),
                        ],
                      ),
                    ),
                ],
              ),
          ],
        ),
      );
    }
    await tester.pumpWidget(const SizedBox());
  });
}
