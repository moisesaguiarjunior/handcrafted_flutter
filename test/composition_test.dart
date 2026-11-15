import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

void main() {
  testWidgets(
    'constrained parts share the laid-out pivot with touch and anchors',
    (tester) async {
      for (final actual in [const Size(50, 50), const Size(120, 80)]) {
        const childKey = ValueKey('constrained-control');
        var taps = 0;
        Offset? mappedCenter;
        final pose = PartPose(rotation: math.pi / 2);
        await tester.pumpWidget(
          Directionality(
            textDirection: TextDirection.ltr,
            child: Align(
              alignment: Alignment.topLeft,
              child: SizedBox.fromSize(
                size: actual,
                child: CraftPart(
                  key: const ValueKey('constrained-part'),
                  size: const Size(100, 100),
                  pose: pose,
                  pivot: Alignment.center,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final laidOut = constraints.biggest;
                      mappedCenter = pose.mapPoint(
                        laidOut.center(Offset.zero),
                        size: laidOut,
                        pivot: Alignment.center,
                      );
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => taps++,
                        child: const SizedBox.expand(key: childKey),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
        final box = tester.renderObject<RenderBox>(find.byKey(childKey));
        expect(box.size, actual);
        final center = box.localToGlobal(actual.center(Offset.zero));
        expect(center.dx, closeTo(actual.width / 2, .001));
        expect(center.dy, closeTo(actual.height / 2, .001));
        expect(mappedCenter?.dx, closeTo(center.dx, .001));
        expect(mappedCenter?.dy, closeTo(center.dy, .001));
        await tester.tapAt(actual.center(Offset.zero));
        expect(taps, 1);
      }
    },
  );

  test('attachment mapping rejects nonfinite local coordinates', () {
    final pose = PartPose();
    for (final value in [
      double.nan,
      double.infinity,
      double.negativeInfinity,
    ]) {
      for (final point in [Offset(value, 0), Offset(0, value)]) {
        expect(
          () => pose.mapPoint(point, size: const Size(80, 60)),
          throwsArgumentError,
        );
      }
    }
    expect(pose.mapPoint(Offset.zero, size: const Size(80, 60)), Offset.zero);
  });

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
