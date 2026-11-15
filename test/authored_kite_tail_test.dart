import 'package:flutter_test/flutter_test.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

void main() {
  test('kite tail deforms locally, stays attached and settles', () {
    Offset sample(double progress, double fraction) {
      final metric = authoredKiteTail(progress).computeMetrics().first;
      return metric.getTangentForOffset(metric.length * fraction)!.position;
    }

    final settledTip = sample(1, 1);
    final tips = <Offset>[];
    for (var frame = 0; frame <= 84; frame++) {
      final progress = frame / 84;
      expect(
        (sample(progress, 0) - const Offset(-2, 31)).distance,
        lessThan(0.001),
      );
      tips.add(sample(progress, 1));
      expect((tips.last - settledTip).distance, lessThanOrEqualTo(11.01));
    }
    // With the parent transform removed the ribbon still changes shape.
    expect((sample(0.35, 0.65) - sample(0.55, 0.65)).distance, greaterThan(1));
    expect(tips.any((tip) => tip.dx > settledTip.dx + 1), isTrue);
    expect(tips.any((tip) => tip.dx < settledTip.dx - 1), isTrue);
    expect((tips.first - settledTip).distance, lessThan(0.001));
    expect((sample(0.99, 1) - settledTip).distance, lessThan(0.02));
  });
}
