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

  testWidgets('leather mark lays out at narrow and tiny sizes', (tester) async {
    for (final size in const [Size(320, 140), Size(60, 24), Size(1, 1)]) {
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
  });
}
