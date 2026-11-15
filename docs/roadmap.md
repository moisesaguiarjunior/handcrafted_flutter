# Material-focused roadmap

This is a backlog, not a list of shipped features. Keep the package focused on
composable materials and artwork around native widgets. Content, navigation,
identity, themes and editorial decisions belong to the application.

## Current implementation

- Five seeded textures: paper, linen, twill, felt and wood.
- Organic contours; value-based rectangle, rounded rectangle and pigment recipes.
- Running stitches with illustrative puncture shading.
- Curves through waypoints, continuous/dashed/dotted ink, pen/marker/brush
  treatments and arc-length reveal with an interactive drawing playground.
- Clipped surfaces, shared paint/input/anchor transforms, finite entrance motion.
- One authored kite-tail preset and runnable synthetic compositions.
- Layered watercolor washes and directional motif/native-text relief, with a
  visual atlas and independently controlled body/tail/tether motion examples.

There is no general path inset, physical cloth, shared wind, water solver or
shared texture cache. Pigment and relief are visual approximations; fabrics are
not physically displaced and wet paint is not simulated over time.

## Delivery order

| Priority | Delivery | Acceptance boundary |
| --- | --- | --- |
| 1 | Contour-following seams and corrected showcase | Insets handle concavities, holes and collapsed narrow regions; thread and relief stay inside the substrate |
| 2 | Refine watercolor and inset lettering | Bounded visual implementations now exist; preserve semantics/scaling while validating their quality and phone performance |
| 3 | Material/edge/mark recipes and playground | Parameters have visible effects, deterministic seeds, bounded work and small runnable examples |
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
| Marks | Basic pen, translucent broad marker and illustrative brush exist; fountain pen, pencil, chalk, wax crayon and wet pigment remain candidates | Width/pressure, coverage, edge bleed, granulation, taper and seed |
| Stitches | Existing running stitch; backstitch, blanket/buttonhole, chain, cross and basting | Shared seam, spacing, thread thickness and puncture shading |
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
