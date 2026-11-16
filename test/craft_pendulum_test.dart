import 'dart:math' as math;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

void main() {
  test(
    'gravity restores a released mass, damping settles it without timers',
    () {
      final model = CraftPendulum(initialAngle: .5, damping: 2);
      expect(
        model.sample(const Duration(milliseconds: 100)).angle,
        lessThan(.5),
      );
      final settled = model.sample(const Duration(seconds: 12));
      expect(settled.angle.abs(), lessThan(.001));
      expect(settled.angularVelocity.abs(), lessThan(.001));
      expect(
        CraftPendulum(
          gravity: 0,
          damping: 0,
        ).sample(const Duration(seconds: 12)).angle,
        .5,
      );
    },
  );
  test(
    'wind blows in screen direction and converges near force equilibrium',
    () {
      final model = CraftPendulum(
        initialAngle: 0,
        wind: const Offset(300, 0),
        damping: 2,
      );
      final sample = model.sample(const Duration(seconds: 12));
      expect(sample.angle, closeTo(-math.atan2(300, 980), .001));
      expect(sample.bobOffset.dx, greaterThan(0));
      final reverse = CraftPendulum(
        initialAngle: 0,
        wind: const Offset(-300, 0),
      ).sample(const Duration(milliseconds: 250));
      expect(reverse.bobOffset.dx, lessThan(0));
    },
  );
  test('seek order, style response, native mapping and fractional time are explicit', () {
    final model = CraftPendulum(wind: const Offset(200, 0));
    final first = model.sample(const Duration(seconds: 2));
    model.sample(const Duration(seconds: 7));
    model.sample(Duration.zero);
    expect(model.sample(const Duration(seconds: 2)).angle, first.angle);
    expect(model.sample(const Duration(microseconds: 8000)).angle, .5);
    expect(model.sample(const Duration(microseconds: 8334)).ticks, 1);
    final cartoon = CraftPendulum(
      wind: const Offset(200, 0),
      style: CraftPhysicsStyle.cartoon,
    );
    expect(
      cartoon.sample(const Duration(seconds: 2)).angle,
      isNot(first.angle),
    );
    final mapped = first.pose.mapPoint(
      const Offset(40, 140),
      size: const Size(80, 160),
    );
    expect(
      (mapped - const Offset(40, 0) - first.bobOffset).distance,
      lessThan(1e-9),
    );
  });
  test('bounded extreme forces stay finite; invalid time and recipes fail explicitly', () {
    for (final style in CraftPhysicsStyle.values) {
      final model = CraftPendulum(
        length: 16,
        gravity: 4000,
        wind: const Offset(2000, 0),
        damping: 0,
        initialAngle: math.pi,
        initialAngularVelocity: 8,
        style: style,
      );
      final result = model.sample(const Duration(seconds: 30));
      expect(result.angle.isFinite && result.angularVelocity.isFinite, isTrue);
      expect(result.ticks, 3600);
      expect(result.bobOffset.distance, closeTo(16, 1e-9));
    }
    expect(() => CraftPendulum(length: 0), throwsArgumentError);
    expect(() => CraftPendulum(gravity: double.nan), throwsArgumentError);
    expect(
      () => CraftPendulum(wind: const Offset(2001, 0)),
      throwsArgumentError,
    );
    expect(() => CraftPendulum(damping: -1), throwsArgumentError);
    expect(() => CraftPendulum(initialAngle: 4), throwsArgumentError);
    expect(
      () => CraftPendulum(initialAngularVelocity: double.infinity),
      throwsArgumentError,
    );
    expect(
      () => CraftPendulum().sample(const Duration(microseconds: -1)),
      throwsArgumentError,
    );
    expect(
      () => CraftPendulum().sample(const Duration(microseconds: 30000001)),
      throwsArgumentError,
    );
  });
}
