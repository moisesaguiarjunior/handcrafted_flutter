import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

List<Offset> samples(Path path) {
  final metric = path.computeMetrics().single;
  return List.generate(
    20,
    (i) => metric.getTangentForOffset(metric.length * i / 20)!.position,
  );
}

void main() {
  test('seed is stable across unrelated calls and changes the contour', () {
    const rect = Rect.fromLTWH(20, 30, 180, 90);
    final first = samples(pigmentOutline(rect, seed: 4));
    pigmentOutline(rect, seed: 99);
    expect(samples(pigmentOutline(rect, seed: 4)), first);
    expect(samples(pigmentOutline(rect, seed: 5)), isNot(first));
  });
  test('closed outlines fit narrow and broad requested bounds', () {
    for (final broad in [false, true]) {
      for (final rect in [
        const Rect.fromLTWH(10, 20, 2, 150),
        const Rect.fromLTWH(-20, -30, 200, 80),
      ]) {
        final path = pigmentOutline(rect, seed: 7, broad: broad);
        expect(path.computeMetrics().single.isClosed, isTrue);
        final bounds = path.getBounds();
        expect(bounds.left, closeTo(rect.left, .0001));
        expect(bounds.top, closeTo(rect.top, .0001));
        expect(bounds.right, closeTo(rect.right, .0001));
        expect(bounds.bottom, closeTo(rect.bottom, .0001));
      }
    }
  });
  test('empty bounds are empty and invalid bounds fail explicitly', () {
    expect(pigmentOutline(Rect.zero, seed: 1).computeMetrics(), isEmpty);
    expect(
      () => pigmentOutline(
        const Rect.fromLTWH(0, 0, double.infinity, 10),
        seed: 1,
      ),
      throwsArgumentError,
    );
  });
}
