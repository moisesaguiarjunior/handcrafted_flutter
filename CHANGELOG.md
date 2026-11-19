# Changelog

## Unreleased

- Add example-owned retained source-space paper/pigment, native soft alpha masks,
  directional fiber overlays and repeating cloth/paper prints. Include synthetic
  1×/3× clipping/phase counterexamples and separated recording/readback samples;
  no default painter or public API changes, unlimited worlds or phone claims.

- Adopt the official flutter_lints preset while retaining strict analysis and
  public API documentation rules. Keep narrow documented exceptions for tools
  composing actual example painters, and enforce the policy with synthetic
  violations in disposable snapshots. Lint dependencies are developer-only.

- Prepare 0.3.1 with a tested Flutter 3.35.7 / Dart 3.9.2 source floor and a
  two-SDK CI matrix alongside the existing locked release baseline. Use the
  shared boolean TickerMode accessor with a single documented deprecation
  suppression on newer SDKs; pause/resume semantics are unchanged.
- Use Flutter's semantic matchers across boolean/tristate SDK representations,
  preserving explicit selected/enabled-state checks. Target the native sharing
  action by its label instead of a framework-private button subclass.
- Published 0.3.0 and its immutable tag retain their original SDK constraints.

## 0.3.0

- Add an example-only light studio: a draggable shared lamp over clay-like
  rounded volume, EVA and paper, with height/distance, shape and rotation
  controls. Sample directional lighting at each piece center; no new light
  solver, clock or simulated clay API. Add a disposable Android smoke host.

- Add CraftPlacement.fit and CraftImagePart.placed: align declared visible bounds
  while retaining the full painting window, source hinge and native pose/input.
- Add conservative craftStrokeBounds sharing the actual dry-deposit primitives
  and native miter constant. Preserve earlier stroke pixels with frozen parity.
- Add independent opening/fold/front-height and paint-only seam-pressure controls
  to the pocket recipe. Keep default imagery and original image adapter topology.

- Add CraftNap: prepared short matte fiber finish with independent scale,
  density, direction and paint contrast, bounded to 8,192 candidates in four tonal
  paths. Existing cotton/suede tiles remain unchanged. Add real-size comparison
  and layered EVA with receiver-clipped shadow and localized pressed sewing.

- Add independently authored CraftBandWidth keys, profile-following edge rails
  and smooth closed bands with continuous joins. Cut, mesh and shadow use the
  same bounded stations. Shadow blur is independent of thickness and ground lift;
  constant-width open defaults remain unchanged. Add unstitched paper examples.

- Add prepared CraftLight/CraftVolume/CraftBand for bounded opaque-substrate volume, shared directional light and curved ribbon rails; original folded-pocket recipe and native insertion control. Existing relief defaults remain unchanged.

- Preserve stateful choice labels when selection changes and postcard editor
  focus/composition across responsive layouts. Bound decorative mark geometry
  before preparation, retaining both the visual refresh and pressed-foam study.

- Append CraftMaterial.leather: a pebbled hide grain with rounded, top-left lit
  cells, darker valleys, sparse pores and faint wrinkles in the same cached
  96px tile contract. Update exhaustive material switches.
- Harmonize the example palette (warm oat board, clay, ochre, cognac, sage and
  indigo) and recapture documentation media. Add an original leather-tag mark
  composed from public renderers, recompose the EVA studies as layered cuts,
  pair each stitch family with its own cloth/thread and show all nine materials.
  The watercolor flower painting is unchanged apart from its surrounding board.
- CraftChoice marks selection with a drawn check mark before its label instead
  of a stadium outline over the decorative cut; it needs no icon font.
- Recompose the examples around purposeful objects: a sendable postcard, a
  picnic RSVP in paper and cloth themes, a tooled leather journal, a raised
  balloon card and letterpress thank-you card, and pastel EVA cuts. Layered
  relief motifs are example-owned in relief_motifs.dart.

- Add optional inset relief to existing running/patterned/prepared stitch paint:
  narrow lips suggest pressed marks without raised yarn, holes or seam halos.
  Original layered EVA specimens reuse the foam page; raised defaults remain.

- Add cotton and velvety nap material tiles, satin paper sheen, optional seeded
  irregular running stitches and local puncture gathering. Add dry instrument
  coverage and a shared cloth/chalk/folded-card study; preserve legacy defaults.

- Correct colored rope to interlaced yarns with local crossing depth, individual
  volume and longitudinal filaments. Remove flat backing/cross-band hatching in
  palette mode; keep legacy single-color, ribbon and embroidered output.
  Add live/capture close-ups for two/three strands and natural cotton tones.
  Shared-edge yarn geometry preserves fractional alpha across sampling densities.

- Add optional 2..6 color twisted rope strands over existing paths and nominal
  contour gaps; omit the palette to retain legacy rendering. Colored work has
  an explicit 8192-sample cap, independent of the grain strength.
- Append CraftMaterial.eva; update exhaustive material switches. Add seeded
  pebbled/mottled/grooved/crosshatched FoamFinish overlays and a layered-cut
  gallery using the existing raised relief, without imported application art.

- Compose the welcome and README cover around a real editable watercolor note,
  with native choice/action and optional contour stitching. Keep the flower and
  atlases; put study actions before art, label sharing, and show paint wetness
  before the preview. First touch starts at zero with explicit playback.

- Keep the vocabulary demo inside the existing material budget on wide desktop
  viewports; native text/actions remain unchanged and the package fallback stays.
  Add a regression through the actual gallery in paper and cloth themes.
- Clarify paint/thread mode guidance, link directly to the six stitch families,
  and document the experience frame's space-saving drawer navigation.

- Prepare first pub.dev distribution: curated screenshots/metadata, portable
  README links, archive exclusions and dry-run/documentation validation in CI.
  Hosted publication is a separate action; prior Git tags remain unchanged.
- Enforce standard flow-control bracing; wrap existing branches without changing
  their conditions, expressions or intended rendering/interaction behavior.
- Allow the compatible clipper2 ^0.0.3 range; the resolved version and license
  inventory are unchanged.

- Add native CraftHeading with host-themed CraftReliefStyle over the existing
  glyph renderer. Typography stays in the native theme; heading semantics,
  wrapping/scaling and plain-text fallback remain native. Material themes can
  switch pressed/raised lettering, with bounded depth and discrete light changes.
  These APIs are current-source additions after v0.2.0.

## 0.2.0

- Migration: `CraftStrokeTool` adds pencil, chalk and wax. Update exhaustive
  switches when upgrading from 0.1.0. This pre-1.0 minor release remains an
  experimental Git source dependency, not a pub.dev publication.

- Example-first responsive experience frame: independently fitted art, mapped
  native targets, stable form/focus across reflow, actual-size pinned footer and
  keyboard/SafeArea handling. Reuse shared synthetic crop factories; no new
  package API or art clock. Add deterministic real-font captures.

- Replace separate moving-brush dabs with one continuous swept watercolor wash.
  Add independent brush visibility/end-fade options, clearer mode starts and an
  actual-widget drag capture; first-touch and layered contact are preserved.

- Host-owned material ThemeExtension and role-based panels/native buttons/choices.
  Native input, focus, selected semantics and minimum targets survive material
  changes; bounded decoration falls back without clipping or shrinking content.
  Add a two-theme live form and actual-widget capture.

- Retain loose-wave and full-embroidery studies while adding faster completion
  of an adjustable number of missing stitches. Full reveal has independent
  loose-thread/needle props; document scroll-owned progress without another clock.

- Explicit watercolor spreading and owned thread-frame progress with actual
  punctures and a travelling tip. Default static painting remains unchanged.
- Paint-led gallery with persistent desktop navigation, mobile study selection,
  native history/share links and finite play/pause/seek studies. Refresh actual
  material/motion captures with varied cuts and distinct kite/balloon rhythms.
- Record material vocabulary, experience frame, extraction, accessibility,
  device evidence, isolated adoption and recipe-book priorities as proposed work.

- Pencil, chalk and wax decorate existing paths with seeded bounded deposits.
  Adds three enum members; exhaustive consumer switches need updating. Patterns,
  reveal and the existing gallery are reused; long freehand remains solid pen.
- Reconcile shipped stitches, hosted gallery and bilateral integration in the
  roadmap; retain candidate fabrics, filled embroidery and movement work.

- Document the executable consumer video integration: versioned material
  arguments, structural media discovery and the existing Fluvie export path,
  without adding a peer dependency or job parser to this core package.

- Unified web gallery reuses standalone studies, mounts only the visible page
  and deploys reviewed main through GitHub Pages. Restores generic independent
  body/tail/tether captures without exporting consumer actor art.

- Six thread families share bounded seam geometry and the original puncture
  painter: running, backstitch, blanket, chain, cross and basting. Adds a native
  parameter playground and actual-contour image without changing legacy pixels.

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
