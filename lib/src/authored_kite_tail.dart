import 'dart:math' as math;

import 'package:flutter/painting.dart';

/// The existing original application kite-tail artwork and its bounded entrance wave.
///
/// Local coordinates preserve the authored reference: attachment (-2,31),
/// two cubic segments and a maximum 11-unit lateral wave before host transforms.
/// [arrival] must be finite and is clamped to 0..1. At both ends it is at rest.
/// No ticker, wind force, rope constraints or aerodynamic simulation is implied.
Path authoredKiteTail(double arrival) {
  if (!arrival.isFinite)
    throw ArgumentError.value(arrival, 'arrival', 'Must be finite');
  final progress = arrival.clamp(0.0, 1.0);
  final envelope = math.pow(math.sin(math.pi * progress), 2).toDouble();
  double wave(double distance) =>
      11 *
      envelope *
      distance *
      math.sin(progress * math.pi * 6 - distance * math.pi * 2.2);
  return Path()
    ..moveTo(-2, 31)
    ..cubicTo(-22 + wave(0.2), 69, 13 + wave(0.4), 96, -24 + wave(0.6), 124)
    ..cubicTo(-40 + wave(0.75), 139, -66 + wave(0.9), 150, -100 + wave(1), 147);
}
