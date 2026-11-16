# A material vocabulary for new experiences

This is the prioritized foundation request. The initial theme/panel/button/choice
slice is described in [material vocabulary](../material-vocabulary.md); the other
items below are not claims of shipped components. Applications retain identity, content, illustrations, navigation,
authorization and persistence. Private consumer inventories stay with consumers.

## 1. Vocabulary in the package, identity in the application

Define configurable sheet, tag, ribbon, card, tray, relief heading, sewn button
and accessible choice recipes. A material theme configures substrate, contour,
finish, depth, thread and interaction presentation. Colors and typography are
supplied by the application; the package bundles no product brand or artwork.
Reuse CraftSurface, CraftOutline, existing relief/thread painters and Flutter
ThemeExtension/native controls before adding new ownership abstractions.

Acceptance: demonstrate two independently supplied material themes over the same
native controls. Changing themes must not recreate application state, change
labels, restart unrelated motion or replace focus/selected semantics.

## 2. One experience frame

Reuse CraftImagePart/PartPose for artboard coordinates, supplied image crops,
hinges and hit transforms. The frame must accommodate imported layers, native
text/actions, narrow screens and enlarged text, with a fixed footer on short
screens. Scale artwork independently; never shrink text to fit the artboard.
Keep keyboard insets, SafeArea and native focus behavior intact.

Acceptance: one synthetic composition across wide, narrow and short viewports,
text scaling and keyboard visibility. Verify pixels, hit regions and semantics.
This is an example/consumer frame first; it is not an application router.

## 3. One art-extraction tool

Audit existing consumer pipelines privately before consolidating them. Establish
one reproducible conversion path retaining source dimensions, crops, pivots and
provenance. Use synthetic/licensed fixtures and compare generated images. Avoid
a general scene manifest or procedural recreation of authored art without a
validated need; the runtime crop adapter remains clock-free.

## 4. Accessibility as a component contract

Decorative layers stay outside the semantics tree and pointer handling. Native
labels exist from the first frame even if a visual reveal has not completed.
Minimum hit targets, focus, enlarged text and selected state belong to the
component, not an invisible consumer convention. Prefer native Flutter test
guidelines and helpers over another accessibility framework. Verify selected
state on the actionable button itself and never visually shrink the label.

## 5. Actual device evidence

The rendering-cost harness exists. Measure watercolor and animation workloads
on a mid-range Android and an iPhone, retaining only device classes and relevant
software versions in public evidence. Record workload, viewport, frame timing,
memory, settling and offscreen behavior. Desktop tests or counted draw calls do
not satisfy this gate. Profile desktop/real consumer scenes while devices are
unavailable; do not introduce shared cache ownership without measured need.

## 6. Isolated consumer adoption

Inspect the current consumer pin first. Adopt a reviewed/tagged baseline in its
own PR, with changelog, license notices and pixel parity, separately from visual
redesign. v0.1.0 exists but predates later APIs; do not silently downgrade an
already newer pin or claim later APIs are included in that tag.

## 7. A new-experience recipe book

Use one original synthetic example through design canvas, extraction, imported
layers, experience frame, native text, behavioral/accessibility/visual checks and
owner approval. Distinguish runnable existing APIs from proposed vocabulary.

## Shared animation contract

- Caller-supplied progress 0..1 supports pause, seek and reverse sampling.
- Finite sequences; no infinite playback or internal wall clock in painters.
- Reduced motion settles automatic playback at the final pose.
- The host explicitly supplies activity/visibility; offscreen routes dispose or
  pause the clock. Background and TickerMode are handled by SceneEntrance.
- Same recipe/seed/input on the same renderer is deterministic and bounded.
- Revealed text retains its native accessible label from the first frame.
- Travelling thread distinguishes above-cloth drawing and hidden return phases.
- Start with Flutter Interval for delays/sequencing on the existing progress;
  do not add a second timeline clock or custom choreography framework.

## Repository shape

Keep a cohesive repository and main Flutter package while geometry, substrates,
native composition and explicit progress share small contracts. Examples, capture
assets and development tools do not become runtime dependencies. Avoid splitting
repositories by effect or application use case. If dependency weight, platforms
or version lifecycles genuinely diverge, first consider separate packages within
the same repository. Consumer orchestration and identity remain outside it.
