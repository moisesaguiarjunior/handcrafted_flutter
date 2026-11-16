import 'dart:math' as math;
import 'dart:ui' show FrameTiming, FramePhase;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

import 'imported_layers.dart';
import 'showcase_theme.dart';

final _tileOutline = Path()
  ..addRRect(
    RRect.fromRectAndRadius(
      const Rect.fromLTWH(0, 0, 150, 100),
      const Radius.circular(14),
    ),
  );
final _tileSeam = Path()
  ..addRRect(
    RRect.fromRectAndRadius(
      const Rect.fromLTWH(8, 8, 134, 84),
      const Radius.circular(10),
    ),
  );
final _tileWashes = [
  for (var i = 0; i < 2; i++)
    Path()..addOval(Rect.fromLTWH(14 + i * 24, 12 + i * 13, 72, 55)),
];

/// Explicit owner-scoped texture resources for a bounded stress scene.
class BudgetResources {
  /// Starts with a validated number of independent surface caches.
  BudgetResources({int count = 12, int seed = 23}) {
    configure(count: count, seed: seed);
  }
  final _owners = <MaterialTextures>[];
  final _requested = <Set<CraftMaterial>>[];
  int _seed = 23, _created = 0, _disposed = 0;
  int _revision = 0;
  bool _closed = false;

  /// Live cache owners, not measured GPU allocations.
  int get live => _owners.length;

  /// Total cache owners created by this scene.
  int get created => _created;

  /// Total cache owners disposed by this scene.
  int get disposed => _disposed;

  /// Invalidates paint when mutable owner configuration changes in place.
  int get revision => _revision;

  /// Distinct material kinds requested across live owners; not GPU memory.
  int get requestedKinds => _requested.fold(0, (n, kinds) => n + kinds.length);

  /// Equivalent configuration preserves resources; changed seeds replace them.
  void configure({required int count, required int seed}) {
    if (_closed) throw StateError('Budget resources are disposed');
    if (count < 1 || count > 24) {
      throw ArgumentError.value(count, 'count', 'Expected 1..24');
    }
    if (count == live && seed == _seed) return;
    _revision++;
    if (seed != _seed) {
      _releaseFrom(0);
      _seed = seed;
    }
    if (count < live) _releaseFrom(count);
    while (live < count) {
      _owners.add(MaterialTextures(seed: seed + live));
      _requested.add(<CraftMaterial>{});
      _created++;
    }
  }

  /// Paints using one retained owner and records its requested material family.
  void paint(int index, Canvas canvas, Path outline, CraftMaterial material) {
    if (_closed) throw StateError('Budget resources are disposed');
    _owners[index].paint(
      canvas,
      outline,
      material: material,
      color: material == CraftMaterial.felt
          ? DemoPalette.rose
          : DemoPalette.paper,
      strength: .65,
    );
    _requested[index].add(material);
  }

  void _releaseFrom(int index) {
    for (final owner in _owners.skip(index)) {
      owner.dispose();
      _disposed++;
    }
    _owners.removeRange(index, live);
    _requested.removeRange(index, _requested.length);
  }

  /// Releases only this scene's owners. Repeated disposal is safe.
  void dispose() {
    if (!_closed) {
      _releaseFrom(0);
      _closed = true;
    }
  }
}

/// Bounded UI/raster timing window; collecting never schedules a UI update.
class BudgetTimingWindow {
  final _samples = <({int ui, int raster})>[];
  int _warmup = 12;
  int _afterVsync = 0;
  int? _firstVsync;
  bool _active = false;

  /// Number of retained post-warmup engine samples, capped at 120.
  int get count => _samples.length;

  /// Whether callbacks are still accepted.
  bool get active => _active;

  /// Excludes the last pre-run vsync, then skips twelve fresh warmup frames.
  /// The first eligible vsync anchors an eight-second collection boundary.
  void start({int afterVsync = 0}) {
    _samples.clear();
    _warmup = 12;
    _afterVsync = afterVsync;
    _firstVsync = null;
    _active = true;
  }

  /// Stops collecting without discarding the current window.
  void stop() => _active = false;

  /// Receives engine timings; no frame export duration is substituted.
  void record(List<FrameTiming> timings) {
    for (final frame in timings) {
      if (!_active) break;
      final vsync = frame.timestampInMicroseconds(FramePhase.vsyncStart);
      if (vsync <= _afterVsync) continue;
      _firstVsync ??= vsync;
      if (vsync - _firstVsync! > const Duration(seconds: 8).inMicroseconds) {
        _active = false;
        break;
      }
      if (_warmup > 0) {
        _warmup--;
        continue;
      }
      _samples.add((
        ui: frame.buildDuration.inMicroseconds,
        raster: frame.rasterDuration.inMicroseconds,
      ));
      if (count == 120) _active = false;
    }
  }

  /// Plain, anonymous evidence suitable for copying into a local measurement log.
  String report() {
    if (count == 0) {
      return 'No post-warmup engine timings collected. '
          'Use a profile-capable runtime; widget tests and frame export are not benchmarks.';
    }
    double percentile(List<int> values, double p) {
      values.sort();
      return values[(p * (values.length - 1)).ceil()] / 1000;
    }

    final ui = _samples.map((s) => s.ui).toList(),
        raster = _samples.map((s) => s.raster).toList();
    return 'Engine samples: $count (12 warmup frames excluded)\n'
        'UI p50/p95: ${percentile(ui, .5).toStringAsFixed(2)} / ${percentile(ui, .95).toStringAsFixed(2)} ms\n'
        'Raster p50/p95: ${percentile(raster, .5).toStringAsFixed(2)} / ${percentile(raster, .95).toStringAsFixed(2)} ms';
  }
}

/// Same bounded workload at explicit poses; the caller owns its resources.
class RenderingBudgetScene extends StatelessWidget {
  /// Creates a workload without a clock or implicit resource allocation.
  const RenderingBudgetScene({
    super.key,
    required this.resources,
    required this.progress,
  });

  /// Caller-owned caches; dispose only after this scene is unmounted.
  final BudgetResources resources;

  /// Explicit animation pose in 0..1.
  final double progress;
  @override
  Widget build(BuildContext context) {
    if (!progress.isFinite || progress < 0 || progress > 1) {
      throw ArgumentError.value(progress, 'progress');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 16,
          children: [
            for (var i = 0; i < resources.live; i++)
              SizedBox(
                width: 150,
                child: Column(
                  children: [
                    SizedBox(
                      height: 100,
                      width: 150,
                      child: CustomPaint(
                        key: ValueKey('budget-material-$i'),
                        painter: _BudgetTile(resources, i, progress),
                      ),
                    ),
                    CraftReliefText(
                      'Field ${i + 1}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        color: DemoPalette.ink,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        Wrap(
          spacing: 12,
          children: [
            for (var i = 0; i < 3; i++)
              SizedBox(
                width: 160,
                child: ExcludeSemantics(
                  child: IgnorePointer(
                    child: ImportedComposition(
                      progress: i == 1 ? 1 - progress : progress,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _BudgetTile extends CustomPainter {
  _BudgetTile(this.resources, this.index, this.progress)
    : revision = resources.revision;
  final BudgetResources resources;
  final int index;
  final double progress;
  final int revision;
  @override
  void paint(Canvas canvas, Size size) {
    resources.paint(
      index,
      canvas,
      _tileOutline,
      CraftMaterial.values[index % 5],
    );
    final shift = math.sin(math.pi * progress) * 18;
    for (var wash = 0; wash < 2; wash++) {
      canvas.save();
      canvas.translate(shift, 0);
      paintWatercolor(
        canvas,
        _tileWashes[wash],
        pigment: wash == 0 ? DemoPalette.sage : DemoPalette.rose,
        paper: DemoPalette.paper,
        seed: index + wash,
        opacity: .45,
        granulation: .6,
      );
      canvas.restore();
    }
    paintRunningStitch(
      canvas,
      _tileSeam,
      thread: DemoPalette.thread,
      dash: 4,
      gap: 2,
      width: 1,
      compression: .3,
    );
  }

  @override
  bool shouldRepaint(_BudgetTile old) =>
      resources != old.resources ||
      revision != old.revision ||
      index != old.index ||
      progress != old.progress;
}

/// Manual profile harness; runtime timings never trigger a measurement loop.
class RenderingBudgetPage extends StatefulWidget {
  /// Creates the bounded stress scene and resource ledger.
  const RenderingBudgetPage({super.key});
  @override
  State<RenderingBudgetPage> createState() => _RenderingBudgetPageState();
}

class _RenderingBudgetPageState extends State<RenderingBudgetPage> {
  final _resources = BudgetResources();
  final _timings = BudgetTimingWindow();
  int _count = 12, _seed = 23, _run = 0;
  bool _running = false, _motion = true;
  String _report = 'No measurement requested.';
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addTimingsCallback(_timings.record);
  }

  @override
  void dispose() {
    SchedulerBinding.instance.removeTimingsCallback(_timings.record);
    _resources.dispose();
    super.dispose();
  }

  void _configure(int count, int seed) => setState(() {
    _running = false;
    _timings.stop();
    _count = count;
    _seed = seed;
    _resources.configure(count: count, seed: seed);
  });
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'A measurable cabinet',
              style: TextStyle(fontFamily: 'Caveat', fontSize: 42),
            ),
            const Text(
              'Profile a fixed workload before changing cache ownership.',
            ),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                for (final count in [6, 12, 24])
                  ChoiceChip(
                    label: Text('$count surfaces'),
                    selected: _count == count,
                    onSelected: (_) => _configure(count, _seed),
                  ),
                FilterChip(
                  label: const Text('Animated poses'),
                  selected: _motion,
                  onSelected: (v) {
                    _configure(_count, _seed);
                    setState(() => _motion = v);
                  },
                ),
              ],
            ),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                TextButton(
                  onPressed: () => setState(() {
                    _timings.start(
                      afterVsync: SchedulerBinding
                          .instance
                          .currentSystemFrameTimeStamp
                          .inMicroseconds,
                    );
                    _running = true;
                    _run++;
                  }),
                  child: const Text('Run 8 seconds'),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    _timings.stop();
                    _running = false;
                    _report =
                        'Mode: ${kProfileMode
                            ? 'profile'
                            : kReleaseMode
                            ? 'release'
                            : 'debug (not performance evidence)'}\n'
                        'Viewport: ${MediaQuery.sizeOf(context).width.toStringAsFixed(0)} × ${MediaQuery.sizeOf(context).height.toStringAsFixed(0)} logical px\n'
                        'Surfaces: $_count · seed $_seed · ${_motion ? 'animated' : 'static rebuilds'}\n'
                        'Owners created/disposed/live: ${_resources.created}/${_resources.disposed}/${_resources.live}\n'
                        'Live requested material kinds: ${_resources.requestedKinds} (not GPU memory)\n${_timings.report()}';
                  }),
                  child: const Text('Stop and report'),
                ),
                TextButton(
                  onPressed: () => _configure(_count, _seed + 1),
                  child: const Text('Replace seed'),
                ),
              ],
            ),
            SelectableText(_report),
            const SizedBox(height: 16),
            SceneEntrance(
              key: ValueKey(_run),
              active: _running,
              startSettled: !_running,
              duration: const Duration(seconds: 8),
              builder: (context, p) => RenderingBudgetScene(
                resources: _resources,
                progress: _motion ? p : 0,
              ),
            ),
            const Text(
              'UI includes framework build/layout/paint recording. Raster is reported separately by the engine. '
              'Static mode rebuilds the same pose; stopping ends the clock. '
              'Use DevTools to attribute layout and paint. No phone result is bundled.',
            ),
          ],
        ),
      ),
    ),
  );
}
