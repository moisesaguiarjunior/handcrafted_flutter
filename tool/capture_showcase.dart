import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

import '../example/lib/use_cases.dart';
import '../example/test/support/fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('capture actual showcase widgets at controlled poses', (
    tester,
  ) async {
    await tester.runAsync(
      () => loadShowcaseFonts(directory: 'example/assets/fonts'),
    );
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    Future<void> capture(String path, Size size, Widget child) async {
      tester.view.physicalSize = size;
      final key = GlobalKey();
      await tester.pumpWidget(
        MaterialApp(
          theme: showcaseTheme(),
          home: RepaintBoundary(
            key: key,
            child: Scaffold(
              backgroundColor: DemoPalette.board,
              body: Center(child: child),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
      final boundary = key.currentContext?.findRenderObject();
      if (boundary is! RenderRepaintBoundary)
        throw StateError('Missing capture boundary');
      await tester.runAsync(() async {
        final image = await boundary.toImage();
        try {
          final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
          if (bytes == null) throw StateError('PNG encoding failed');
          final file = File(path);
          await file.parent.create(recursive: true);
          await file.writeAsBytes(bytes.buffer.asUint8List());
        } finally {
          image.dispose();
        }
      });
    }

    await capture(
      'build/showcase/hero.png',
      const Size(1100, 500),
      const _Hero(),
    );
    for (final kind in CraftUseCase.values) {
      await capture(
        'build/showcase/${kind.name}.png',
        const Size(440, 340),
        UseCaseArt(kind: kind, onAction: () {}),
      );
    }
    for (final kind in [CraftUseCase.hanging, CraftUseCase.kite]) {
      for (var frame = 0; frame <= 50; frame++) {
        await capture(
          'build/showcase/${kind.name}/frame_${frame.toString().padLeft(3, '0')}.png',
          const Size(440, 340),
          UseCaseArt(kind: kind, progress: frame / 50, onAction: () {}),
        );
      }
    }
    await tester.pumpWidget(const SizedBox());
    expect(tester.binding.transientCallbackCount, 0);
  });
}

class _Hero extends StatelessWidget {
  const _Hero();
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 1100,
    height: 500,
    child: Stack(
      children: [
        const Positioned(
          left: 48,
          top: 34,
          child: Text(
            'handcrafted_flutter',
            style: TextStyle(
              fontFamily: 'Caveat',
              fontSize: 68,
              color: DemoPalette.ink,
            ),
          ),
        ),
        const Positioned(
          left: 52,
          top: 132,
          width: 440,
          child: Text(
            'A little texture.\nA lot of possibility.',
            style: TextStyle(
              fontSize: 28,
              height: 1.25,
              fontWeight: FontWeight.w500,
              color: DemoPalette.ink,
            ),
          ),
        ),
        Positioned(
          left: 550,
          top: 66,
          child: UseCaseArt(kind: CraftUseCase.keepsake, onAction: () {}),
        ),
        Positioned(
          left: 52,
          top: 278,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final material in CraftMaterial.values)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      SizedBox(
                        width: 86,
                        height: 70,
                        child: CraftSurface(
                          material: material,
                          color: switch (material) {
                            CraftMaterial.felt => DemoPalette.rose,
                            CraftMaterial.paper => DemoPalette.paper,
                            CraftMaterial.wood => DemoPalette.wood,
                            _ => DemoPalette.sage,
                          },
                          outline: (size) => pigmentOutline(
                            Offset.zero & size,
                            seed: 11,
                            broad: true,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        material.name,
                        style: const TextStyle(
                          fontSize: 13,
                          color: DemoPalette.ink,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const Positioned(
          left: 52,
          bottom: 36,
          child: Text(
            'Real Flutter surfaces. Native controls. Finite motion.',
            style: TextStyle(fontSize: 17, color: DemoPalette.ink),
          ),
        ),
      ],
    ),
  );
}
