# Adoption recipes and evidence-driven extensions

Status: integration guidance and proposed work, not additional shipped APIs.
The adoption baseline is 0664174; explicit stroke joins are now available. Keep
application identities, artwork and internal reviews in their consumer repositories.

## Start with one rendering responsibility

For existing authored paths, reuse `paintCraftStroke` with explicit width, dash,
gap, color and progress. Set `CraftStrokeStyle.join` explicitly when matching
a legacy corner treatment; its default remains `StrokeJoin.round`. Keep the
supplied paths: `craftCurveThrough` is useful when a caller has waypoints, but
replacing an authored cubic with interpolated waypoints changes the drawing.
Use selective imports or a namespace when a
consumer already has primitives with names such as `pigmentOutline`.

Pin an immutable Git revision in the consumer and commit its resolved lockfile.
Compare the real painter against its previous revision on the same engine at
narrow, ordinary and expanded-content sizes. Check both material palettes. A
same-renderer RGBA comparison can establish migration equivalence without
creating or regenerating golden references. Deliberately change one stroke
parameter and confirm that the comparison fails.

This only establishes the tested rendering boundary. It is not phone performance
evidence, an approval of an entire screen, or a promise of cross-engine pixels.

## Useful next work, ordered by evidence

| Priority | Need | Reuse first | Evidence required before adding an API |
| --- | --- | --- | --- |
| First | Repeatable rendering-cost measurements | Existing material/motion atlas and explicit progress | Profile static and animating repeated washes, strokes and relief; separate layout, paint and raster time; record bounded scene sizes and disposal behavior |
| Next, if profiling warrants it | Reuse prepared stroke geometry | Internal validated metrics/spans and immutable `CraftStrokeStyle` | Compare allocations and paint time across repeated progress values; define ownership, invalidation and limits before exposing a prepared-path object |
| Next | Readable decorated headings and actions at large text | Native layout, `CraftSurface`, `CraftPart`, existing atlas controls | A narrow example with 100%, 150%, 200% and 250% text; decoration moves to a separate slot when text grows; complete action labels, no scaling down, all targets reachable |
| Next | Explicit contour treatment for watercolor | `paintWatercolor` preserves supplied closed silhouettes and holes | A separate opt-in capillary-edge transform, if needed, with bounded displacement and tests for holes, concavities and narrow regions; never silently distort the supplied path |
| Next, if profiling warrants it | Reduce repeated inset-glyph work | Native paragraph configuration in `CraftReliefText` | Measure repaint work before caching; invalidate for text, locale, direction, scale, constraints and style; preserve semantics and dispose raster/text resources |
| Later | Reusable ambient motion with explicit style | `PartPose`, anchor mapping and externally supplied time | Shared wind/tether/settling contracts, deterministic stepping, bounded iteration and a stable reduced-motion pose; distinguish authored cartoon exaggeration from a physical simulation |

The responsive heading item is initially an example recipe, not a universal
layout framework. Prepared geometry and shared caches are conditional proposals,
not reasons to add global mutable caches without a measurement.

## Material migration boundaries

`paintWatercolor` clips to the exact supplied closed path. An older painter may
first distort that path, choose a theme-specific companion color, or use a
different opacity. Match those choices explicitly; substituting default arguments
is not a visual-equivalence migration.

`CraftReliefText` keeps native text layout, but its directional lighting differs
from arbitrary legacy shadows. Compare the actual book/label composition,
including long text, localization, direction and system scaling. Do not approve
new visual references solely because the behavior tests pass.

Animation adoption should also preserve the existing host's clock and visibility
policy. An application that already supplies progress does not need a second
`SceneEntrance`. Physics, gravity and a realistic/cartoon parameter remain planned
work; the current kite and balloon examples are authored motion.

## First implemented extension: stroke joins

A same-renderer migration comparison found a small pixel difference when an
existing painter used Flutter's default miter joins but `paintCraftStroke` fixed
round joins. `CraftStrokeStyle.join` now makes this choice explicit for pen/marker
stroked paths, preserving the previous round default. Brush polygons and dotted
dabs remain unaffected. Native raster comparisons cover all three join types;
forcing round joins makes the regression fail. No reference image is regenerated.
