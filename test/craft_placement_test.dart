import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

void main() {
  test('visible contour fits while full painting margins and source hinge are retained', () {
    final pose = PartPose(
      translation: const Offset(8, -4),
      rotation: .4,
      scale: .9,
    );
    final placement = CraftPlacement.fit(
      sourceRect: const Rect.fromLTWH(0, 0, 200, 140),
      visibleBounds: const Rect.fromLTWH(40, 30, 100, 80),
      target: const Rect.fromLTWH(10, 20, 150, 160),
      pose: pose,
    );
    expect(placement.rect, const Rect.fromLTWH(-50, -5, 300, 210));
    expect(
      placement.mapSourcePoint(const Offset(90, 70)),
      const Offset(93, 96),
    );
    final d = const Offset(30, -20) * (1.5 * .9);
    final expected =
        const Offset(93, 96) +
        Offset(
          d.dx * math.cos(.4) - d.dy * math.sin(.4),
          d.dx * math.sin(.4) + d.dy * math.cos(.4),
        );
    expect(
      (placement.mapSourcePoint(const Offset(120, 50)) - expected).distance,
      lessThan(1e-9),
    );
    final translated = CraftPlacement.fit(
      sourceRect: const Rect.fromLTWH(-40, -30, 200, 140),
      visibleBounds: const Rect.fromLTWH(0, 0, 100, 80),
      target: const Rect.fromLTWH(10, 20, 150, 160),
      pose: pose,
    );
    expect(
      (translated.mapSourcePoint(const Offset(80, 20)) - expected).distance,
      lessThan(1e-9),
    );
  });
  test('alignment and explicit external hinge preserve authored anchors', () {
    final placement = CraftPlacement.fit(
      sourceRect: const Rect.fromLTWH(-10, -10, 120, 100),
      visibleBounds: const Rect.fromLTWH(0, 0, 100, 80),
      target: const Rect.fromLTWH(20, 30, 200, 200),
      alignment: Alignment.topLeft,
      sourceHinge: const Offset(-20, -30),
      pose: PartPose(rotation: .6),
    );
    expect(
      placement.mapSourcePoint(const Offset(-20, -30)),
      const Offset(-20, -30),
    );
  });
  test('unrepresentable retained margins fail while coherent large origins remain usable', () {
    for (final pose in [PartPose(), PartPose(rotation: .4)]) {
      expect(
        () => CraftPlacement.fit(
          sourceRect: const Rect.fromLTRB(-1e18, 0, 128, 64),
          visibleBounds: const Rect.fromLTWH(0, 0, 64, 64),
          target: const Rect.fromLTWH(10, 20, 64, 64),
          pose: pose,
        ),
        throwsArgumentError,
      );
    }
    expect(
      () => CraftPlacement.fit(
        sourceRect: const Rect.fromLTRB(-1e18, 0, 512, 256),
        visibleBounds: const Rect.fromLTWH(0, 0, 256, 256),
        target: const Rect.fromLTWH(0, 0, 256, 256),
        pose: PartPose(rotation: .47),
      ),
      throwsArgumentError,
    );
    expect(
      () => CraftPlacement.fit(
        sourceRect: const Rect.fromLTWH(0, 0, 128, 128),
        target: const Rect.fromLTWH(0, 0, 128, 128),
        pose: PartPose(translation: const Offset(1e18, 0)),
      ),
      throwsArgumentError,
    );
    final translated = CraftPlacement.fit(
      sourceRect: const Rect.fromLTWH(-1e12, 1e12, 200, 140),
      visibleBounds: const Rect.fromLTWH(-1e12 + 40, 1e12 + 30, 100, 80),
      target: const Rect.fromLTWH(10, 20, 150, 160),
    );
    expect(
      (translated.mapSourcePoint(const Offset(-1e12 + 90, 1e12 + 70)) -
              const Offset(85, 100))
          .distance,
      lessThan(1e-6),
    );
  });
  test('bad bounds, underflow and nonfinite results fail before paint', () {
    const valid = Rect.fromLTWH(0, 0, 100, 100);
    for (final bad in [
      Rect.zero,
      const Rect.fromLTWH(0, 0, double.infinity, 20),
    ]) {
      expect(
        () => CraftPlacement.fit(sourceRect: valid, target: bad),
        throwsArgumentError,
      );
    }
    expect(
      () => CraftPlacement.fit(
        sourceRect: valid,
        target: valid,
        visibleBounds: const Rect.fromLTWH(-1, 0, 50, 50),
      ),
      throwsArgumentError,
    );
    expect(
      () => CraftPlacement.fit(
        sourceRect: valid,
        target: valid,
        alignment: const Alignment(2, 0),
      ),
      throwsArgumentError,
    );
    expect(
      () => CraftPlacement(
        sourceRect: valid,
        rect: const Rect.fromLTWH(1e308, 0, 1e307, 100),
        pose: PartPose(translation: const Offset(1e308, 0)),
      ),
      throwsArgumentError,
    );
    final placement = CraftPlacement(sourceRect: valid, rect: valid);
    expect(
      () => placement.mapSourcePoint(const Offset(double.nan, 0)),
      throwsArgumentError,
    );
    expect(
      () => CraftPlacement(
        sourceRect: const Rect.fromLTWH(0, 0, 1e200, 1e200),
        rect: const Rect.fromLTWH(0, 0, 1e-200, 1e-200),
      ),
      throwsArgumentError,
    );
  });
}
