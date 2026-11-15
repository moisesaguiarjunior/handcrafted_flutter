import 'package:handcrafted_flutter/handcrafted_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> mount(
    WidgetTester tester, {
    bool reduced = false,
    bool active = true,
    bool tickers = true,
    required void Function(double arrival, double parallax) observe,
  }) => tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(disableAnimations: reduced),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: TickerMode(
          enabled: tickers,
          child: SceneEntrance(
            active: active,
            builder: (_, arrival) {
              observe(arrival, 0);
              return const SizedBox(width: 390, height: 300);
            },
          ),
        ),
      ),
    ),
  );

  testWidgets('welcomes once, settles, and stops scheduling animation frames', (
    tester,
  ) async {
    var arrival = -1.0;
    await mount(tester, observe: (value, _) => arrival = value);
    expect(arrival, 0);
    await tester.pump(const Duration(milliseconds: 2100));
    expect(arrival, inExclusiveRange(0, 1));
    await tester.pump(const Duration(milliseconds: 4200));
    expect(arrival, 1);
    await tester.pump(const Duration(milliseconds: 20));
    expect(tester.binding.transientCallbackCount, 0);
    await tester.pump(const Duration(seconds: 30));
    expect(arrival, 1);
    expect(tester.binding.transientCallbackCount, 0);
  });

  testWidgets('reduced motion starts at rest without a ticker', (tester) async {
    var arrival = -1.0, parallax = -1.0;
    await mount(
      tester,
      reduced: true,
      observe: (a, p) {
        arrival = a;
        parallax = p;
      },
    );
    expect(arrival, 1);
    await tester.pump();
    expect(parallax, 0);
    expect(tester.binding.transientCallbackCount, 0);
  });

  testWidgets('turning reduced motion on settles an in-flight welcome', (
    tester,
  ) async {
    var arrival = -1.0;
    void observe(double a, double _) => arrival = a;
    await mount(tester, observe: observe);
    await tester.pump(const Duration(milliseconds: 500));
    expect(arrival, lessThan(1));
    await mount(tester, reduced: true, observe: observe);
    expect(arrival, 1);
    await tester.pump(const Duration(milliseconds: 20));
    expect(tester.binding.transientCallbackCount, 0);
  });

  testWidgets('an offscreen welcome pauses instead of running unseen', (
    tester,
  ) async {
    var arrival = -1.0;
    void observe(double a, double _) => arrival = a;
    await mount(tester, observe: observe);
    await tester.pump(const Duration(milliseconds: 800));
    final before = arrival;
    await mount(tester, active: false, observe: observe);
    await tester.pump(const Duration(seconds: 10));
    expect(arrival, before);
    expect(tester.binding.transientCallbackCount, 0);
    await mount(tester, observe: observe);
    await tester.pump(const Duration(milliseconds: 800));
    expect(arrival, greaterThan(before));
  });

  testWidgets('backgrounding pauses; resuming continues without restarting', (
    tester,
  ) async {
    var arrival = -1.0;
    await mount(tester, observe: (a, _) => arrival = a);
    await tester.pump(const Duration(milliseconds: 800));
    final before = arrival;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    addTearDown(
      () => tester.binding.handleAppLifecycleStateChanged(
        AppLifecycleState.resumed,
      ),
    );
    await tester.pump(const Duration(seconds: 5));
    expect(arrival, before);
    expect(tester.binding.transientCallbackCount, 0);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));
    expect(arrival, greaterThan(before));
  });

  testWidgets(
    'muting the route pauses elapsed time rather than skipping the welcome',
    (tester) async {
      var arrival = 0.0;
      void observe(double a, double _) => arrival = a;
      await mount(tester, observe: observe);
      await tester.pump(const Duration(milliseconds: 800));
      final before = arrival;
      await mount(tester, tickers: false, observe: observe);
      await tester.pump(const Duration(seconds: 10));
      await mount(tester, observe: observe);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));
      expect(arrival, greaterThan(before));
      expect(arrival, lessThan(1));
    },
  );
}
