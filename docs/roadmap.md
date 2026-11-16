# Material-focused roadmap

This is a backlog, not a list of shipped features. Keep the package focused on
composable materials and artwork around native widgets. Content, navigation,
identity, themes and editorial decisions belong to the application.

## Current implementation

- Five seeded textures: paper, linen, twill, felt and wood.
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

## Delivery order

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
