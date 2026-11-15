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
  test('value recipe preserves canonical geometry and returns owned paths', () {
    const recipe = CraftOutline.pigment(seed: 23, broad: true, padding: 5);
    final first = recipe.pathFor(const Size(100, 80));
    final expected = samples(
      pigmentOutline(const Rect.fromLTWH(5, 5, 90, 70), seed: 23, broad: true),
    );
    expect(samples(first), expected);
    first.reset();
    expect(samples(recipe.pathFor(const Size(100, 80))), expected);
    expect(recipe, CraftOutline.pigment(seed: 23, broad: true, padding: 5));
    expect({
      recipe,
      CraftOutline.pigment(seed: 23, broad: true, padding: 5),
    }, hasLength(1));
    expect(recipe, isNot(const CraftOutline.pigment(seed: 24, broad: true)));
  });

  test('value recipe rejects invalid inputs and handles exhausted bounds', () {
    for (final recipe in [
      const CraftOutline.rectangle(padding: -1),
      const CraftOutline.pigment(seed: 1, padding: double.nan),
      const CraftOutline.roundedRectangle(radius: double.infinity),
      const CraftOutline.roundedRectangle(radius: -1),
    ]) {
      expect(() => recipe.pathFor(const Size(80, 60)), throwsArgumentError);
    }
    for (final size in [
      const Size(-1, 10),
      const Size(10, double.nan),
      const Size(double.infinity, 10),
    ]) {
      expect(
        () => const CraftOutline.rectangle().pathFor(size),
        throwsArgumentError,
      );
    }
    for (final recipe in [
      const CraftOutline.rectangle(padding: 50),
      const CraftOutline.roundedRectangle(padding: 50),
      const CraftOutline.pigment(seed: 1, padding: 50),
    ]) {
      expect(recipe.pathFor(const Size(100, 80)).computeMetrics(), isEmpty);
    }
  });

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
