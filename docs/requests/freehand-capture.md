# Bounded freehand capture — consumer request

Status: minimal solid-pen renderer implemented in the current source candidate.
Independent review/publication is tracked in the tasklist. Rendering-only scope;
capture storage and consent belong to the consumer.

## Reuse / Create

Searched `paintCraftStroke`, `CraftStrokeStyle`, `checkedPathMetrics`,
`trimCraftPath`, the drawing playground and imported-layer requests. Reuse
existing colors/styles and native Canvas when possible. Create no parallel
animation clock, image cache, capture controller or persistence service.

The current stroke renderer intentionally bounds geometry to 32 contours and
8,192 logical pixels. That suits authored illustrative paths and bounds brush
sampling. A consumer freehand pad instead bounds input to 8,192 finite points
across at most 128 strokes on a 346 by 380 logical canvas. A valid long scribble
can exceed the arc-length bound with far fewer input points. A direct replacement
would reject a previously accepted drawing. Single-point taps also need a dot.

## Minimal reproducible case

Construct one polyline alternating between (8, 8) and (338, 372), fifty points.
All input points fit the consumer canvas and its point budget. The centerline
exceeds 8,192 logical pixels, so `paintCraftStroke` rejects it. This is the
existing documented safety contract, not a claimed library bug.

## Requested assessment

Evaluate a bounded, solid freehand composition/renderer that can share the
existing instrument style without requiring illustrative arc-length traversal.
Prefer a documented adapter when that is sufficient; a separate public API
requires a justified contract and review. Do not remove or globally raise the
existing arc/contour safeguards, especially for dashed or brush sampling.

Acceptance for any proposed adoption:

- Explicit finite point/stroke/coordinate budgets and defined empty/tap handling.
- Preserve ordered input, joins, dots and existing solid-pen pixels on the same
  renderer; never silently smooth, truncate or replace the recorded drawing.
- Same deterministic painter for display and PNG export at multiple scales;
  caller retains image/resource ownership. No timer, IO or global cache.
- Valid long scribbles complete with work bounded by accepted point count.
  Over-budget/non-finite input fails explicitly before expensive rendering.
- Keep editable controls, accessibility, identity, storage and publish semantics
  outside the package. No reuse of consumer art or private documents.

`paintCraftFreehand` now validates point/stroke/coordinate budgets and delegates
solid pen to native drawPath/drawPoints with the existing stroke style. It accepts
up to 128 strokes / 8192 points, independent of arc length. Unsupported tools and
patterns fail explicitly. Input bounds validate centerlines rather than clipping
ink. Consumer capture should remain unchanged until its own pixel-parity and
export checks pass; native `Canvas.drawPath` remains valid for that consumer.
See [current stroke contracts](../drawing-strokes.md) and
[consumer adoption](../consumer-adoption.md).

## Verification of the request

On the documented Flutter 3.47.9 baseline, an isolated experiment measured
24,075 logical pixels for that fifty-point polyline. Native solid drawPath
accepted it; paintCraftStroke rejected it through the documented arc guard.
The experiment is not a phone performance measurement. Repository checks passed
(50 library tests and 66 example tests at `10af430`); this change adds
documentation only.

## Minimal rendering adapter

```dart
paintCraftFreehand(canvas, recordedStrokes,
  bounds: const Rect.fromLTWH(0, 0, 346, 380),
  color: ink,
  style: const CraftStrokeStyle(width: 3, join: StrokeJoin.miter),
);
```

Points are copied into native paths in their original order; no curves, smoothing
or truncation are inferred. A single-point tap uses native round drawPoints.
Bounds may be at most 2048 logical pixels per axis; all coordinates are finite
within +/-8192 and input bounds (inclusive edges). Stroke width remains 0.5..32.
Empty strokes paint nothing. All validation completes before the first draw, so
an invalid later stroke cannot partially paint the input. There is no renderer
resource owner or separate export implementation: apply the consumer's Canvas
scale/clip and use this same function for display/export.

The adapter deliberately accepts only solid pen. Marker opacity, brush sampling,
dash/reveal and dotted patterns continue to use the decorative renderer's
separate limits. A consumer should not substitute a captured drawing's validity
with those limits or silently choose another tool for an unsupported request.
