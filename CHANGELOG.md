# Changelog

## Unreleased

- Bounded solid-pen freehand renderer preserves native ordered paths, joins and
  taps with point/stroke budgets, independently of decorative arc-length guards.
  Capturing, consent, persistence and export policy remain consumer-owned.

- Clock-free bounded pendulum sampling with gravity, wind, damping and explicit
  realistic/cartoon response. Reuses native pose/input mapping; adds a manual
  time/force playground, not flexible cloth/rope or an indefinite simulator.

- Composable cord/ribbon/embroidered bands over open or closed paths, with bounded
  texture stations, directional shading and nominal contour-gap preparation.
  Adds original material compositions and an accessible parameter playground.

## 0.1.0

- Breaking: removes the application-specific `authoredKiteTail` export. Keep actor
  artwork in consumers; the example uses its own generic waypoint curve.
  Existing immutable source pins are unaffected. See docs/compatibility.md.
- Adds a public delivery tasklist and a local independent review record.

## 0.0.1 (experimental source baseline)

- Public CraftImagePart extracts source crop/hinge/artboard placement from the
  imported-layer example, retaining native paint/input transforms and image cache
  ownership without a manifest, supplied artwork or additional clock.
- Composable paper finishes and cut/torn/deckle/postage edge recipes, including
  value-based CraftOutline.paper and separate fiber fringe. Adds six visual stock
  specimens, edge comparison images and native letterhead at enlarged text.
- Bounded contour insets via pinned clipper2, respecting fill rules, holes and
  collapsed narrow regions. Adds a seam study and corrects the card/material
  showcases to follow the actual cut rather than scaled or unrelated contours.
- Reproducible rendering-cost harness with bounded engine UI/raster samples,
  explicit resource/disposal counts and repeated mixed material workloads.
- Bounded authored pour/light example with mapped emitter, seeded fixed storage,
  explicit progress, quiet endpoints and finite reduced-motion-aware playback.
- Native rotary-control example with bounded stepping, stable control identity,
  current-pose retargeting and finite, activity-aware decorative movement.
- Imported-artwork example with source crops, authored hinges, mapped thread,
  supplied hit shapes and native content actions that leave focus when covered.
- Explicit pen/marker stroke joins, preserving the round default and allowing
  authored miter/bevel corners. Adds adoption guidance and proposed imported-layer,
  rotary-control and bounded-effect recipes with acceptance criteria.
- Bounded palette-explicit watercolor, directional motif relief and native
  raised/inset lettering. Adds material/impression/pigment image sheets and
  independently controlled kite body/tail, balloon/tether and hanging examples.
  Shared capture helpers and legacy kite artwork/theme avoid parallel renderers.
- Curved waypoint paths, arc-length reveal and composable continuous/dashed/dotted
  pen, translucent marker and illustrative brush strokes. Adds a native-control
  drawing playground and explicit synthetic capture, sharing stitch span logic.
- Value-based `CraftOutline` recipes through `CraftSurface.shape`; custom
  `outline` callbacks remain compatible. Recipe padding is not a seam inset.
- Seeded materials, running stitches and organic contours.
- Native-widget surfaces, constrained part transforms and finite entrances.
- Runnable showcase, licensed example fonts and explicit captures.
- Experimental MIT source with documented compatibility limits.
