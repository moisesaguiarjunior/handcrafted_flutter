# Reproducible rendering-cost harness

Run from `example/` with a profile-capable target:

```sh
flutter run --profile -t lib/main_budget.dart
```

Select 6, 12 or 24 surfaces, choose animated poses or static rebuilds, then run
for eight seconds. Stop and report produces a copyable anonymous summary. Use
the same logical viewport, scale, package/Flutter revision, seed and workload
for comparisons. Record software versions and a generic device class; do not
publish personal paths, device identifiers or machine details.

The scene combines independent owner-scoped material caches, partially opaque
grain, two overlapping seeded washes per surface, compressed running stitches,
native inset lettering and three imported lid/attachment poses. Outline, seam
and wash geometry is retained; animation translates the fixed wash geometry.
The normal public rendering APIs perform the work. No shared cache or prepared
stroke API is introduced by this harness.

Resource bookkeeping reports owners created/disposed/live and material kinds
requested across live owners. These are precise example-owned counts, not
instrumented GPU image allocations or memory usage. Equivalent configuration
retains owners; count reductions dispose removed owners; seed replacement
disposes the old scope and invalidates paint. Disposing one scene leaves another
scene's resources intact. The three imported sprites also use Flutter's image
cache; its resources are not counted as texture owners.

The timing window accepts actual engine FrameTiming callbacks, rejects batches
from before the run, excludes twelve warmup frames, and retains at most 120
samples. It reports UI and raster p50/p95 separately. UI duration includes build,
layout and paint recording; use DevTools' timeline to attribute those stages
separately. Collecting a timing never schedules another UI update. If the target
does not provide engine timings, the report says so instead of inventing a
zero-cost result. Debug runs are explicitly labelled as non-performance evidence.

Static mode deliberately rebuilds the same pose each frame; it is not an idle
measurement. Animated mode changes wash and imported-part poses. Both runs use
the same finite SceneEntrance and stop ticking at completion. Reduced motion
settles automatic movement. Stopping/configuration changes stop collection.
Viewport scrolling still requires the host's visibility policy. Keep viewport
and scroll position fixed when comparing: culling and visible layers affect
raster work. Frame export speed is not a frame-budget measurement.

Tests establish bookkeeping, invalidation, independent ownership, bounded timing
windows, late-batch/warmup filtering, finite playback, no fabricated widget-test
timings and 320px controls through 250% real-font text. They do not establish
heap/retained-image measurements, native-device frame time or acceptable phone
performance. Collect those results before introducing shared resources or
claiming a material budget. This delivery is the reproducible harness, not a
published performance result.
