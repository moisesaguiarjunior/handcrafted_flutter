# Material-focused roadmap

This is a backlog, not a list of shipped features. Keep the package focused on
composable materials and artwork around native widgets. Content, navigation,
identity, themes and editorial decisions belong to the application.

## Current implementation

- Nine seeded textures: paper, linen, twill, felt, wood, EVA, cotton, velvety
  nap and pebbled leather.
- Organic contours; value-based rectangle, rounded rectangle and pigment recipes.
- Six stitch families with illustrative puncture shading: running, backstitch,
  blanket, chain, cross and basting.
- Bounded polygonal contour insets respecting holes, concavities and exhausted
  narrow regions, with a shared-contour showcase and interactive seam study.
- Six visual paper-stock recipes from existing base grain and bounded fiber,
  fluted, cold-pressed and laid overlays; cut/torn/deckle/postage silhouettes and
  independent fiber fringe. Native letterhead remains composition.
- Curves through waypoints, continuous/dashed/dotted ink, pen/marker/brush
  treatments, dry pencil/chalk/wax deposits and arc-length reveal in the same
  interactive drawing playground. Long freehand input remains solid pen only.
- Clipped surfaces, shared paint/input/anchor transforms, finite entrance motion.
- Generic progress/pose primitives and example-owned synthetic compositions.
- Layered watercolor washes and directional motif/native-text relief, with a
  visual atlas and independently controlled body/tail/tether motion examples.
- Imported crop/hinge/attachment, native rotary-control and bounded pour/light
  recipes, plus a rendering-cost harness with owner-scoped resource bookkeeping.
  Native-device performance results remain pending.
- Public CraftImagePart for a source crop placed in an artboard rectangle with
  optional hinge/pose, shared native hit transform and no new animation clock.

The twelve-study web gallery and generic motion atlas are published. The first
Social Studio crafted template exports through Fluvie with declared media and
explicit recipe arguments; no extra clock or core job parser was added.

A bounded clock-free rigid pendulum now samples constant gravity/wind with
realistic/cartoon response; flexible and coupled bodies remain unimplemented.

There is no exact Bezier inset, physical cloth, shared wind field, water solver or
shared texture cache. Pigment and relief are visual approximations; fabrics are
not physically displaced and wet paint is not simulated over time.

## Foundation first

The [material vocabulary/frame/accessibility request](requests/material-foundation.md)
is the priority order for becoming a reusable experience foundation. Brand,
content and policy remain consumer-owned. The first [material vocabulary](material-vocabulary.md)
slice adds themed panels and native buttons/choices. It is not the full proposed
vocabulary. A [responsive frame recipe](experience-frame.md) now exists in the
example; package promotion and consumer adoption are separate gates.

## Material evolution inventory

| Priority | Delivery | Acceptance boundary |
| --- | --- | --- |
| 1 | Refine contour-following seams | Bounded polygonal implementation and corrected showcase exist; preserve clearance and topology within documented approximation/work limits |
| 2 | Refine watercolor and inset lettering | Bounded visual implementations now exist; preserve semantics/scaling while validating their quality and phone performance |
| 3 | Expand material/edge/mark recipes | Paper/edge recipes and playground now exist; additional fabrics, marks and edge structures remain candidates with explicit seeds/work limits |
| 4 | Layered artwork manifest | Imported SVG layers retain supplied silhouettes, pivots and hit regions; no procedural redrawing requirement |
| 5 | Responsive and accessible compositions | Native actions, keyboard focus, reduced motion and enlarged text remain usable |
| 6 | Reproducible performance scene | Measure repeated surfaces, transparency and dense stitches before changing cache ownership |
| 7 | External timeline and template adapters | Explicit values/progress; no second clock during frame capture; versioned consumer-owned schemas |
| 8 | Ambient movement and bounded physics | Distinguish authored poses from simulations; bound settling, iteration count and reduced-motion behavior |
| 9 | Web gallery and visual regression protection | Interactive examples, reviewed captures and material-specific performance budgets |

## Material inventory to explore

| Family | Candidates | Separate controls |
| --- | --- | --- |
| Paper | Drawing paper, cardstock, kraft, corrugated cardboard, letterhead, recycled, handmade, watercolor, tracing and tissue | Fiber, tooth, opacity, thickness, grain scale; letterhead is composition over a substrate |
| Fabric | Existing linen/twill/felt; cotton, canvas, denim, burlap, knit and satin | Weave, fiber, nap and directional sheen |
| Edges | Clean cut, scissor cut, torn white fibers, serrated, postage perforations and deckle | Silhouette geometry, edge shading and fiber detail remain separate |
| Relief | Raised/inset motifs and native lettering exist; foil/gilding and physical displacement remain candidates | Depth approximation, light, contact shadow and highlight; preserve native text |
| Marks | Basic pen, translucent broad marker and illustrative brush exist; pencil, chalk and wax deposits now exist; fountain pen and wet pigment remain candidates | Width/pressure, coverage, edge bleed, granulation, taper and seed |
| Stitches | Running, backstitch, blanket, chain, cross and basting surface geometry now implemented; physical thread intersections remain future work | Shared seam, spacing, thread thickness and puncture shading |
| Layers | Contact plus cast shadow, lifted corners and stacked cut paper | Elevation, light direction and clipping; avoid inaccessible transformed targets |
| Fasteners | Peg, sewn button, eyelet, wax seal and V-cut ribbon | Wrap native controls; do not paint away focus or semantics |

Do not ship every candidate at once. Start with representative paper, fabric and
mark recipes, then validate them in independent consumer applications.

## Movement inventory

| Subject | Available now | Planned |
| --- | --- | --- |
| Kite | Authored tail deformation plus independent parent sway examples | Shared wind, tether and physically coupled pieces |
| Bird | Generic part transforms | Wing/body pose presets, attachment and trajectory |
| Water | No dedicated effect | Surface/ripple recipes and bounded time-driven motion |
| Crib mobile | Independently pivoting example parts | Chain pendulums, constraints and settling |
| Balloon | Authored body/tether example with a transformed attachment | Buoyancy and physical tether constraints |
| Clothesline | Generic parts and authored strings | Catenary and attached labels that sway |
| Dreamlike light | No dedicated effect | Window light and dust with an explicit reduced-motion pose |

Parameters should compose: changing paper must not replace a control or restart
an unrelated motion clock. Shape presets and authored actors must not dictate a
general physics architecture. See [integration contracts](integration.md).

## Concrete composition requests

[Imported-layer, rotary-control and bounded-effect recipes](requests/authored-scene-composition.md)
refine items 4, 5, 6 and 8 above. They are proposals with acceptance boundaries,
not shipped APIs. Start by composing existing parts and clocks in examples;
avoid a manifest, shared cache or physics framework without validated callers.

## Adoption feedback

See [adoption recipes](consumer-adoption.md) for a first stroke migration and
prioritized evidence gates: measure repeated painting before adding prepared
geometry/cache APIs; demonstrate accessible decorated layouts as examples; keep
optional capillary edges separate from silhouette-preserving watercolor.

The imported-layer example now demonstrates crops, pivots and anchors using
existing parts, without creating a manifest API. A repeatable rendering-cost scene exists; the next evidence
task is measuring actual consumer scenes and full-size exports. These complement the delivery order;
neither shared caches nor prepared-geometry APIs are justified without profiling.

- [Bounded solid freehand](requests/freehand-capture.md) now has a minimal
  point/stroke-budget renderer; independent review/publication tracked separately.
  Decorative arc limits stay intact; consumer capture adoption is not automatic.

## Launch preparation

The light studio (`?study=light`) composes clay-like rounded volume, EVA and
paper under a draggable scene lamp. Position and height are independent;
shape/rotation retain the world source and prepared geometry. Lighting is sampled
at piece centers, without per-pixel point lighting or mutual occlusion.

The 0.3.0 source release has consolidated changes, an immutable reviewed tag,
Android-emulator smoke and publication gates. Its first pub.dev upload completed
on 2026-11-18; hosted resolution and a native-action smoke passed in a fresh
consumer. The interactive browser visit remains incomplete after a connection
failure. Physical Android/iPhone performance
measurements and assistive-technology sessions are still pending.

## Adoption hardening after 0.3.0

The [external-review follow-up](requests/adoption-hardening.md) prioritizes current
release documentation, a tested wider SDK floor, and a standard lint preset.
Rendering changes follow reproducible preparation/paint measurements and pixel
parity. Scoped sharing is conditional; no global cache or new ownership API is
promised. Physical Android/iPhone profiling remains a separate later gate.

The reuse guide is now a current contract index; its full extraction notes remain
in [history](history/reuse-extractions.md). Old tags/branches and useful standalone
example entrypoints are preserved. Test coverage is evidence of exercised code,
not certification of performance, accessibility or platform compatibility.

The compatibility follow-up is included in the 0.4.0 source release, with a
Flutter 3.35.7 / Dart 3.9.2 floor, endpoint analysis/tests/web builds and separate
fresh-resolution/locked-baseline CI lanes. [Evidence and limits](sdk-compatibility.md).
The hosted 0.3.0 archive and tag keep their original requirements; release upload
is a separate action. Standard-lint adoption shipped in PR #47 with strict inheritance counterexamples.


## Bounded continuous-surface proofs

The [synthetic continuity/fidelity request](requests/continuous-materials.md)
now has an [example-owned source-space recipe](surface-continuity.md): retained
paper/pigment above 1024px, a native soft alpha mask, configurable directional
fibers and check/diamond prints on existing substrates. This is not automatic
consumer adoption or reference-art equivalence. Strip raster differences are
measured, not hidden. Arbitrary-size worlds, cross-engine visual acceptance and
physical-device performance remain open; no new material/cache API is implied.


## Stuffed silhouette study

The next material experiment uses original star, crescent and sun cuts as small
stuffed shapes. [Fabric research and first recipe](stuffed-shapes.md) distinguish
woven cotton, felt and a matte short-pile study, with independent visual filling,
sewing and existing scene light. It composes prepared volume/nap/thread without
adding a public pillow preset or another geometry/shading implementation.
Stretch, fuzzy silhouettes, long fur, calibrated fabric compliance and physical
stuffing are future work; performance/opacity evidence priorities remain intact.


An opt-in [rounded depth projection](stuffed-shapes.md#optional-rounded-depth)
now complements that original relief study. It reuses existing height/normal
shading on a bounded projected envelope, with tapered tips and visible mid-sewing.
Original relief stays default; this is 2.5D, not a new 3D engine or cloth solver.
The depth UI commits filling on release; broader performance evidence remains open.


## Whole-face plush proof

A new opt-in comparison in the stuffed-shape study explores short plush and
curled sherpa on the same padded star. The canonical volume prepares a bounded
whole-face profile; textile paths remain example-owned. Old relief/depth studies
and approved PNGs stay unchanged. Visual refinement/owner acceptance and physical
Android/iPhone profiling remain open. The added enum case is included in the
0.4.0 source release; a hosted upload remains separate.
See [contracts and limits](stuffed-shapes.md#whole-face-padding-short-plush-and-curled-sherpa).


## Fluffy finish across substrates

CraftNap now has opt-in length, curl and contour fringe with explicit paint
bounds and candidate caps. The same finish composes over all nine materials
and padded stars, moons and suns. Defaults and previous images remain unchanged.
[Recipe and limits](fluffy-finishes.md). Owner visual review and physical-device
profiling remain separate; no hosted release is performed by this addition.


## 0.4.0 source release

The reviewed source gathers padded profiles, independent fluffy finishes,
continuous-surface proofs, the wider tested SDK floor and rendering fixes.
See [migration and boundaries](releases/0.4.0.md). The old 0.3.1 patch plan is
superseded by this minor release because exhaustive profile switches change.
Hosted publication, consumer adoption, scoped sharing and physical-device
profiling remain separate.


## Contacts before character abstractions

A [synthetic contact study](contact-and-cloth.md) composes existing poses, parts,
material and sewing. Paper support changes hands without losing attachment.
Two textile geometries establish a rigid-link baseline with stable local marks;
continuous flexible folding remains an investigation. Soft articulated figures,
authored shared wind responses and two-sided folded paper are subsequent proofs,
not promised character/physics APIs. Exact review and publication remain separate.


The contact study now has an opt-in [continuous printed strip](contact-and-cloth.md#continuous-printed-strip),
reusing CraftBand shading with bounded affine image transport. It removes the
rigid-link seam while retaining the original baseline. Planar stretch is visible;
out-of-plane reverse faces, fabric physics and self-shadowing remain open.
No public warp or character API is introduced. Exact review/CI precede publication.
