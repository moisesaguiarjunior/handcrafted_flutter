import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcrafted_example/main.dart';

void main() {
  testWidgets('independent gallery reseeds and settles without idle frames', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1200, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const ContourExample());
    await tester.pumpAndSettle();
    expect(find.text('Material & stitch study'), findsOneWidget);
    expect(find.text('linen'), findsOneWidget);
    await tester.ensureVisible(find.text('Reseed (7)'));
    await tester.tap(find.text('Reseed (7)'));
    await tester.pumpAndSettle();
    expect(find.text('Reseed (8)'), findsOneWidget);
    expect(tester.takeException(), isNull);
    expect(tester.binding.hasScheduledFrame, isFalse);
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
  });
}
