import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';
import 'support/raster.dart';
import 'support/texture_canvas.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'repeated grain paint reuses shaders; replacement and owner disposal release them',
    () async {
      final owner = MaterialTextures();
      final recorder = ui.PictureRecorder();
      final spy = TextureCanvas(Canvas(recorder));
      final cut = Path()..addRect(const Rect.fromLTWH(0, 0, 80, 70));
      try {
        for (var i = 0; i < 60; i++) {
          owner.paint(
            spy,
            cut,
            material: CraftMaterial.felt,
            color: Colors.blue,
            strength: .5,
          );
        }
        expect(spy.shaders.toSet(), hasLength(1));
        expect(spy.layers, 60);
        final first = spy.shaders.first;
        expect(first.debugDisposed, isFalse);
        owner.paint(
          spy,
          cut,
          material: CraftMaterial.felt,
          color: Colors.red,
          scale: 2,
        );
        expect(first.debugDisposed, isTrue);
        final replacement = spy.shaders.last;
        owner.paint(
          spy,
          cut,
          material: CraftMaterial.paper,
          color: Colors.white,
        );
        expect(replacement.debugDisposed, isFalse);
        final paper = spy.shaders.last;
        owner.dispose();
        owner.dispose();
        expect(replacement.debugDisposed, isTrue);
        expect(paper.debugDisposed, isTrue);
      } finally {
        recorder.endRecording().dispose();
        owner.dispose();
      }
    },
  );

  test(
    'dotted brush keeps its artistic slant relative to a rotated path',
    () async {
      const angle = math.pi / 4;
      final horizontal = Path()
        ..moveTo(25, 30)
        ..lineTo(65, 30);
      final rotated = Path()
        ..moveTo(25, 30)
        ..lineTo(25 + 40 * math.cos(angle), 30 + 40 * math.sin(angle));
      const style = CraftStrokeStyle(
        tool: CraftStrokeTool.brush,
        pattern: CraftLinePattern.dotted,
        width: 12,
        gap: 8,
        variation: 0,
      );
      final actual = await pixels(
        (c) => paintCraftStroke(c, rotated, color: Colors.blue, style: style),
      );
      final expected = await pixels((c) {
        c.translate(25, 30);
        c.rotate(angle);
        c.translate(-25, -30);
        paintCraftStroke(c, horizontal, color: Colors.blue, style: style);
      });
      // Native rasterization of mathematically equal paths may differ by a pixel
      // at the distant dabs; the first dab shares the exact same center.
      var differences = 0;
      for (var y = 20; y < 40; y++) {
        for (var x = 15; x < 35; x++) {
          final i = (y * 100 + x) * 4;
          for (var j = 0; j < 4; j++) {
            if ((actual[i + j] - expected[i + j]).abs() > 2) differences++;
          }
        }
      }
      expect(differences, lessThan(8));
    },
  );

  testWidgets(
    '48px selected choice reflows at 200% and retains native selection and activation',
    (tester) async {
      final semantics = tester.ensureSemantics();
      try {
        var tapped = false;
        await tester.pumpWidget(
          MaterialApp(
            home: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(2)),
              child: Center(
                child: SizedBox(
                  width: 48,
                  child: CraftChoice(
                    selected: true,
                    onSelected: (v) => tapped = !v,
                    style: CraftPanelStyle(
                      material: CraftMaterial.paper,
                      color: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: const Text('A'),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final button = find.byType(TextButton);
        expect(tester.getSize(button).width, greaterThanOrEqualTo(48));
        expect(tester.getSize(button).height, greaterThanOrEqualTo(48));
        expect(
          tester.getSemantics(button),
          // ignore: deprecated_member_use
          containsSemantics(isSelected: true, hasSelectedState: true),
        );
        expect(
          tester
              .getSemantics(button)
              .getSemanticsData()
              .hasAction(SemanticsAction.tap),
          isTrue,
        );
        await tester.tap(button);
        expect(tapped, isTrue);
        await tester.pumpWidget(const SizedBox());
      } finally {
        semantics.dispose();
      }
    },
  );
}
