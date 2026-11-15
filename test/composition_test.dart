import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

void main() {
  test('attachments use the same pivot rotation scale and translation', () {
    final pose = PartPose(
      translation: const Offset(10, 20),
      rotation: math.pi / 2,
      scale: 2,
    );
    const size = Size(100, 80);
    expect(
      pose.mapPoint(const Offset(50, 0), size: size),
      const Offset(60, 20),
    );
    final below = pose.mapPoint(const Offset(50, 10), size: size);
    expect(below.dx, closeTo(40, .0001));
    expect(below.dy, closeTo(20, .0001));
    expect(() => PartPose(scale: 0), throwsArgumentError);
    expect(() => PartPose(rotation: double.nan), throwsArgumentError);
  });

  testWidgets(
    'transformed supplied controls keep hit positions and held taps',
    (tester) async {
      var first = 0;
      var second = 0;
      Future<void> mount(double x) => tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  child: CraftPart(
                    key: const ValueKey('first'),
                    size: const Size(80, 60),
                    pivot: Alignment.topLeft,
                    pose: PartPose(translation: Offset(x, 100)),
                    child: TextButton(
                      onPressed: () => first++,
                      child: const Text('First'),
                    ),
                  ),
                ),
                Positioned(
                  left: 300,
                  top: 100,
                  child: SizedBox(
                    width: 80,
                    height: 60,
                    child: TextButton(
                      onPressed: () => second++,
                      child: const Text('Second'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      await mount(150);
      await tester.tapAt(const Offset(190, 130));
      expect(first, 1);
      expect(second, 0);
      final gesture = await tester.startGesture(const Offset(190, 130));
      await mount(180);
      await tester.pump(const Duration(milliseconds: 30));
      await gesture.up();
      await tester.pump();
      expect(first, 2);
      expect(second, 0);
    },
  );

  testWidgets('one cached silhouette controls material and child input', (
    tester,
  ) async {
    var calls = 0;
    var taps = 0;
    Path shape(Size size) {
      calls++;
      return Path()..addOval(Offset.zero & size);
    }

    final semantics = tester.ensureSemantics();
    // Disposed before end-of-widget-test verification below.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 100,
              height: 100,
              child: CraftSurface(
                material: CraftMaterial.felt,
                color: const Color(0xFF9FB8B0),
                outline: shape,
                child: TextButton(
                  onPressed: () => taps++,
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tapAt(const Offset(2, 2));
    expect(taps, 0);
    await tester.tapAt(const Offset(50, 50));
    expect(taps, 1);
    expect(calls, 1);
    expect(find.bySemanticsLabel('Open'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets('stable part keys retain native focus after reordering', (
    tester,
  ) async {
    final focus = FocusNode();
    addTearDown(focus.dispose);
    Future<void> mount(bool reverse) => tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              for (final id in reverse ? ['b', 'a'] : ['a', 'b'])
                CraftPart(
                  key: ValueKey(id),
                  size: const Size(100, 60),
                  pose: PartPose(translation: Offset(id == 'a' ? 0 : 160, 100)),
                  child: TextButton(
                    focusNode: id == 'a' ? focus : null,
                    onPressed: () {},
                    child: Text(id),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    await mount(false);
    focus.requestFocus();
    await tester.pump();
    expect(focus.hasFocus, isTrue);
    await mount(true);
    await tester.pump();
    expect(focus.hasFocus, isTrue);
  });
}
