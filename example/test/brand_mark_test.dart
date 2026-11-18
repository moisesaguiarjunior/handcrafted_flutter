import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcrafted_example/brand_mark.dart';

void main() {
  testWidgets('leather mark keeps its words as native, readable text', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    try {
      await tester.pumpWidget(
        const MaterialApp(
          home: Center(
            child: SizedBox(width: 900, height: 300, child: LeatherBrandMark()),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('handcrafted'), findsOneWidget);
      expect(find.bySemanticsLabel('handcrafted'), findsOneWidget);
      expect(find.bySemanticsLabel('FOR FLUTTER'), findsOneWidget);
    } finally {
      handle.dispose();
    }
  });

  testWidgets(
    'leather mark stays within paint budgets at tiny and large sizes',
    (tester) async {
      tester.view.physicalSize = const Size(3000, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      for (final size in const [
        Size(320, 140),
        Size(60, 24),
        Size(1, 1),
        Size(1800, 600),
        Size(2560, 1000),
      ]) {
        await tester.pumpWidget(
          MaterialApp(
            home: Center(
              child: SizedBox.fromSize(
                size: size,
                child: const LeatherBrandMark(),
              ),
            ),
          ),
        );
        expect(tester.takeException(), isNull, reason: '$size');
      }
    },
  );
}
