# Authored scene composition requests

Status: consumer-driven recipes, originally assessed against `0664174` on
2026-11-15. A, B and C now have runnable examples; D has a measurement harness,
with native-device results still pending. General manifest, dial, particle and
shared-cache APIs remain proposals, not release commitments. Examples
must use original synthetic artwork and generic labels; application scenes,
product inventories, permissions and private design references stay outside this
repository. Prefer composition recipes before adding public APIs.

## Reuse first

Searched `CraftPart`, `PartPose`, `SceneEntrance`, `authoredKiteTail`, `paintWatercolor`,
`paintCraftRelief`, `paintCraftStroke`, attachment mapping and resource ownership
across library, tests and examples. The following needs already have foundations:

| Need | Reuse now | Still owned by the consumer |
| --- | --- | --- |
| Imported rigid part and pivot | CraftPart and PartPose; preserve supplied pixels | Asset crops, source coordinates, layer order, hit regions and safe layout |
| Independent body and detail motion | Nested parts and explicit progress, kite example | Artwork selection, local deformation geometry and interaction meaning |
| Warm paper or fabric around native controls | CraftSurface and existing focus/actions | Brand palette, contrast on real scenes, text and access policy |
| Curved/dashed thread or completed prefix | craftCurveThrough, trimCraftPath and paintCraftStroke | Authored waypoints and the meaning of progress |
| Finite entrance or exported pose | SceneEntrance for live entry; explicit values for capture | Route/viewport activity and the application reduced-motion preference |
| Watercolor and relief | paintWatercolor, paintCraftRelief and CraftReliefText | Approved illustrations and font/license provenance |

Do not replace imported reference art with approximate procedural drawings merely
to demonstrate package reuse. The package should enrich supplied art, retain real
text and controls, and avoid adding an animation clock to externally timed scenes.

## A. Imported layers, pivots and anchors (first priority)

The [imported-layer example](../imported-layers.md) now demonstrates this recipe.
CraftImagePart now provides the minimal public image adapter; a general manifest
remains proposed. Route/content/occlusion policy stays with the consumer.

Start with a runnable example and documented adapter: full source size, crop
rectangle, pivot in source coordinates, logical scale and explicit pose. The
adapter can compose existing CraftPart/PartPose; a general manifest needs a
separate versioned contract only after a second consumer validates it.

Acceptance:

- Crop-relative pivot converts exactly once; imported asymmetric art rotates
  about its authored hinge, including at two viewport scales.
- The same pose maps a labelled attachment, painted pixels and pointer input.
- A transformed lid occludes the content beneath it; hidden controls also leave
  focus and the attached semantics tree. Transparent corners need an explicit
  supplied hit shape, not a claim of pixel-perfect alpha hit testing.
- Actual parent constraints determine pivots. Targets reserve accessible space;
  no assumption that Flutter receives taps outside an ancestor's bounds.
- Open, partial, reversed and settled poses work without tickers when progress
  is supplied externally. Native controls remain usable at enlarged text.

## B. Small rotary control around a native action

The [rotary example](../rotary-control.md) now demonstrates this recipe without
adding a public dial abstraction.

A dial/reel recipe should reuse PartPose for its rotating illustration while a
native accessible control owns stepping, focus and semantics. Do not make core
geometry depend on application dates, recording state or device audio.

Acceptance: retarget from the current pose, preserve a stable control identity,
allow keyboard and semantics increment/decrement, avoid wrap discontinuities,
and use a finite/static reduced-motion pose. Turning the dial must not imply
that real recording or saving occurred. Prefer an example over a universal dial
API until callers agree on interaction and snapping.

## C. Bounded pour, droplets and light

The [bounded-effects example](../bounded-effects.md) now demonstrates this recipe.
It remains authored motion, without a general particle or fluid API.

A recipe for a short pour can accept emitter and destination anchors mapped by
PartPose plus explicit progress and seed. A light/dust recipe can share that
external progress, with fixed particle/work limits. These are authored effects,
not fluid dynamics or a general particle engine.

Acceptance: no allocation growth across repeated actions; stable seed; no work
at rest; deterministic first/final poses; no external frame clock; static reduced
motion; every emitter remains attached under parent transforms. Drawing beyond
the reserved content area must be explicit. Measure raster work before adding
blur/layers or any shared cache.

## D. Reproducible motion/material budget

The [rendering harness](../rendering-budget.md) now makes the workload runnable.
Native-device timing and memory measurements remain pending; the harness is not
a demonstrated performance budget.

Before a larger cache or physics abstraction, add a repeatable stress scene:
repeated textured surfaces, overlapping washes, relief lettering, stitched
curves and a few independently moving imported parts. Report UI/raster timings,
resource counts and disposal behavior separately from frame export speed.

Equivalent rebuilds should retain immutable geometry/resources; disposing a
consumer must release only its own resources. Test incompatible recipe changes
and disposal while another surface stays mounted. A global unbounded image cache
is not an acceptable substitute for an ownership contract.

## Out of scope

Application schemas, chronology, media capture, persistence, navigation and
authorization are not package responsibilities. Water, wind and cloth simulation
remain research. These requests must not block consumer features implemented
with ordinary Flutter composition and existing artwork.
