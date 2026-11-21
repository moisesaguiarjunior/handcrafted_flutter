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

The timing window accepts actual engine FrameTiming callbacks, compares vsync
boundaries to reject the last pre-run frame even when its callback is delayed,
excludes twelve fresh warmup frames, and retains at most 120 samples. The first
eligible post-start vsync anchors an eight-second cutoff, so later unrelated
frames cannot enter a short or reduced-motion run. It reports UI and raster
p50/p95 separately. UI duration includes build,
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


## Owner-scoped shader reuse and opacity parity

The rendering review fixes keep one tile and at most one current-scale shader
per material in each `MaterialTextures` owner. Color/strength changes reuse that
shader; changing the scale replaces/disposes it, and owner disposal closes all
shaders before tiles. This does not introduce sharing across separate owners or
claim a phone frame-time improvement.

CanvasKit in both supported SDKs consumes the image handle supplied to its
ImageShader when disposing that shader. Its JavaScript path receives a private
cloned handle so a scale replacement cannot invalidate the owner's cached tile.
Native and Skwasm use the tile handle directly. This renderer policy is covered
by native/Chrome replacement, replay and disposal tests; Wasm execution remains
outside the tested matrix. See the upstream
[CanvasKit lifecycle](https://github.com/flutter/flutter/blob/3.35.7/engine/src/flutter/lib/web_ui/lib/src/engine/canvaskit/shader.dart#L295).
Cloning a handle retains the same backing pixels, not a separately rasterized tile.

The production partial-strength layer is retained. A 162-case comparison across
nine materials, three scales, three strengths, opaque/translucent fills, a hole
and a canvas transform found identical direct-alpha output in the local native
test renderer, but 59 changed cases (154 channels, maximum delta 28) in Chrome
CanvasKit. Direct alpha is therefore an experiment, not the shipped path.
`test/material_opacity_parity_test.dart` compares the shipped output pixel by
pixel with an independent legacy compositing recipe and reports the alternative.
Do not remove the layer based only on native parity or allocation counts.

These observations concern resource identity and rendering output, not measured
Android/iOS memory or frame timings. Existing profiling gates remain open.
