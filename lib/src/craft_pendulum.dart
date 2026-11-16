import 'dart:math' as math;

import 'package:flutter/painting.dart';

import 'craft_part.dart';

/// Force-response treatments for a bounded illustrative pendulum.
enum CraftPhysicsStyle {
  /// Uses supplied acceleration and damping directly.
  realistic,

  /// Uses 0.7x gravity, 1.7x wind and 0.65x damping for exaggerated response.
  cartoon,
}

/// A clock-free fixed-step pendulum with constant gravity and wind acceleration.
///
/// [length] is logical pixels (16..1024); [gravity] is downward logical px/s²
/// (0..4000). [wind] is an additional screen-space acceleration, magnitude at
/// most 2000 px/s²: positive x blows right, positive y down. [damping] is angular
/// drag in s⁻¹ (0..20), independent of device pixels. Initial angle is clockwise
/// radians from downward (-pi..pi), angular velocity radians/s (-8..8).
///
/// The realistic style is a simple rigid point-mass pendulum approximation,
/// not a calibrated material/cloth/rope solver. Cartoon applies documented force
/// gains, without adding random motion or a separate clock. There are no
/// collisions, lift, buoyancy, changing wind fields or coupled pendulums.
///
/// [sample] deterministically replays from the initial state at 120 fixed steps
/// per second, supporting reverse seeks/repeated frames. It floors supplied time
/// to a step and accepts at most 30 seconds (3600 steps). Prepare/capture outside
/// paint when sampling many parts; no resources, caches, tickers or timers are
/// retained. The host owns progress, pause, visibility and reduced-motion policy.
class CraftPendulum {
  /// Creates a validated simulation recipe. Invalid input throws [ArgumentError].
  CraftPendulum({
    this.length = 140,
    this.gravity = 980,
    this.wind = Offset.zero,
    this.damping = 1.2,
    this.initialAngle = .5,
    this.initialAngularVelocity = 0,
    this.style = CraftPhysicsStyle.realistic,
  }) {
    if (!length.isFinite ||
        length < 16 ||
        length > 1024 ||
        !gravity.isFinite ||
        gravity < 0 ||
        gravity > 4000 ||
        !wind.dx.isFinite ||
        !wind.dy.isFinite ||
        !wind.distance.isFinite ||
        wind.distance > 2000 ||
        !damping.isFinite ||
        damping < 0 ||
        damping > 20 ||
        !initialAngle.isFinite ||
        initialAngle.abs() > math.pi ||
        !initialAngularVelocity.isFinite ||
        initialAngularVelocity.abs() > 8) {
      throw ArgumentError(
        'Invalid pendulum length, forces, damping or initial state',
      );
    }
  }

  /// Pivot-to-mass distance, in logical pixels.
  final double length;

  /// Downward acceleration in logical pixels/s².
  final double gravity;

  /// Additional screen-space acceleration in logical pixels/s².
  final Offset wind;

  /// Angular damping coefficient, in s⁻¹.
  final double damping;

  /// Initial clockwise angle from downward, in radians.
  final double initialAngle;

  /// Initial clockwise angular velocity, in radians/s.
  final double initialAngularVelocity;

  /// Direct or exaggerated force response.
  final CraftPhysicsStyle style;

  /// Samples supplied time, flooring to 1/120 second; accepts 0..30 seconds.
  CraftPendulumSample sample(Duration elapsed) {
    if (elapsed.isNegative || elapsed > const Duration(seconds: 30)) {
      throw ArgumentError('Expected pendulum elapsed time in 0..30 seconds');
    }
    final ticks =
        elapsed.inMicroseconds * 120 ~/ Duration.microsecondsPerSecond;
    const dt = 1 / 120;
    final cartoon = style == CraftPhysicsStyle.cartoon;
    final g = gravity * (cartoon ? .7 : 1);
    final w = wind * (cartoon ? 1.7 : 1);
    final drag = damping * (cartoon ? .65 : 1);
    var angle = initialAngle;
    var velocity = initialAngularVelocity;
    for (var i = 0; i < ticks; i++) {
      // Flutter's clockwise rotation takes the downward bob toward negative x.
      final acceleration =
          (-w.dx * math.cos(angle) - (g + w.dy) * math.sin(angle)) / length -
          drag * velocity;
      velocity += acceleration * dt;
      angle += velocity * dt;
    }
    return CraftPendulumSample._(angle, velocity, length, ticks);
  }
}

/// One immutable simulated pose; it does not schedule the next sample.
class CraftPendulumSample {
  const CraftPendulumSample._(
    this.angle,
    this.angularVelocity,
    this.length,
    this.ticks,
  );

  /// Clockwise rotation in radians from downward.
  final double angle;

  /// Clockwise angular velocity in radians/s.
  final double angularVelocity;

  /// Pivot-to-mass distance in logical pixels.
  final double length;

  /// Number of completed fixed steps since the initial state.
  final int ticks;

  /// Uses the existing native paint/input/anchor transform.
  PartPose get pose => PartPose(rotation: angle);

  /// Mass position relative to the pivot, in screen coordinates.
  Offset get bobOffset =>
      Offset(-math.sin(angle) * length, math.cos(angle) * length);
}
