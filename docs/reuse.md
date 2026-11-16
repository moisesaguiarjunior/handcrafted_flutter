# Reuse map

| Need | Canonical implementation |
| --- | --- |
| Seeded perimeter | `pigmentOutline` |
| Value-based silhouette recipes | `CraftOutline`, `CraftSurface.shape` |
| Material tiles and owned resources | `MaterialTextures`, `CraftMaterial` |
| Bounded layered pigment with explicit palette | `paintWatercolor` |
| Directional motif rims and native lettering | `paintCraftRelief`, `CraftReliefText` |
| Raised cord/ribbon/embroidered bands and nominal edge gap | `paintCraftTrim`, `contourTrimPath` |
| Stitch spans and puncture shading | `runningStitchPath`, `paintRunningStitch` |
| Shared bounded arc-length geometry | `lib/src/path_geometry.dart` (internal) |
| Closed-silhouette polygonal insets | `insetCraftPath`, using pinned clipper2 union/offset |
| Paper finish and edge composition | `paintPaperFinish`, `paperOutline`, `paintPaperEdgeFibers`, `CraftOutline.paper` |
| Curved waypoints and explicit reveal | `craftCurveThrough`, `trimCraftPath` |
| Pen, marker and brush patterns | `CraftStrokeStyle`, `paintCraftStroke` |
| Paint, input and anchor transform | `PartPose`, `CraftPart` |
| Material behind native widgets | `CraftSurface` |
| Clock-free rigid gravity/wind response | `CraftPendulum`, `CraftPendulumSample` |
| Finite entrance clock | `SceneEntrance` |
| Runnable compositions and captures | `example/lib/use_cases.dart`, `tool/capture_showcase.dart` |
| Drawing playground and capture | `example/lib/main_strokes.dart`, `tool/capture_strokes.dart` |
| Shared specimen layouts and visual inventory | `example/lib/material_studies.dart`, `example/lib/main_atlas.dart` |
| Authored actor examples with independent progress | `example/lib/motion_studies.dart`, `example/lib/kite_art.dart` |
| Canonical example palette and typography | `example/lib/showcase_theme.dart` |
| Public imported crop, source hinge and placement | `CraftImagePart`; `example/lib/imported_layers.dart` shows the consumer composition |
| Shared example capture shell and PNG writer | `tool/capture_support.dart` |
| Format, analysis and behavior checks | `tool/check.sh` |

Search by name, behavior and type before introducing a parallel implementation.
Reuse the actual layout size for pivots and attachment mapping. Thread and holes
share span geometry. Native widgets retain actions, semantics, layout and focus.
Application policies, content and internal integration assessments stay with the
consumer, outside this repository.

For value silhouettes, searched `outline:`, `pigmentOutline`, `seam` and `RRect`
across library, examples, captures and tests. Reused the existing contour generator
and `_SurfaceGeometry` cache; did not add a parallel contour algorithm or an
approximate inset. Equivalent shape recipes preserve geometry, while changed
recipes or actual layout sizes invalidate it. Custom callbacks remain supported.

For curved drawing, searched `dash`, `stroke`, `brush`, `path` and `progress`
through the library and examples. Extracted the existing running-stitch metric
validation/span logic into one internal implementation; stitches keep their
existing public contract. New ink patterns reuse those intervals. The example
reuses `CraftSurface`, `SceneEntrance` and the licensed showcase theme/fonts.
Raster fixtures share `test/support/raster.dart`; no second tile renderer,
animation clock or independently maintained dashed-path algorithm was added.

For the material/motion atlas, searched `pigment`, `relief`, `imprint`,
`PartPose`, texture ownership and capture writers. Adapted
maintainer-owned pigment/glyph-shading logic into palette-explicit bounded APIs;
the native paragraph supplies lettering layout instead of duplicating inherited
text configuration. Cloth motifs use the canonical material/stitch primitives.
Extracted the existing kite artwork and example theme, preserving legacy entry
points through the use_cases export. Balloon attachments use PartPose.mapPoint.
New sampled captures reuse the existing shell/writer rather than a mock renderer.

For adoption guidance, searched authored paths, stroke spans, watercolor contour
handling, relief paragraph painting, cache ownership and finite entrance clocks.
[Adoption recipes](consumer-adoption.md) reuse these contracts and describe
conditional extensions; they add no second renderer or clock.

`CraftStrokeStyle.join` reuses Flutter's `StrokeJoin` for solid/dashed pen/marker
painting. The round default is preserved. Native-raster regression checks cover
miter, round and bevel; the existing style value contract includes the join.

For bounded effects, searched PartPose attachment mapping, seeded material
ownership and SceneEntrance. Reused those contracts; a fixed-size example-local
PourRecipe stores authored variations without a global particle list, image
cache, blur layer or second clock. Empty endpoints perform no effect painting.

For the rotary recipe, searched native Slider, PartPose, CraftPart, SceneEntrance
and keyed interaction ownership. The native slider owns focus/semantics; the
existing finite clock times only decorative artwork. CraftSurface owns its wood
texture. Angle mapping/retarget policy stay example-local, without a second
clock implementation or public dial abstraction.

For imported artwork, searched crop, pivot, matrixFor, mapPoint, clipping and
native focus through the package and examples. Reused CraftPart/PartPose and
the capture/font helpers. SourceLayer initially remained example-local; its supplied
PNG, crop and hit shape are original synthetic artwork. No second transform,
alpha-testing engine, clock or general manifest was added.

For the budget scene, searched texture disposal, watercolor, stitches, relief,
imported layers and finite clocks. Reused all actual painters and the imported
adapter; fixed geometry remains prepared in the example. Explicit per-consumer
owners retain resources across equal rebuilds. Engine FrameTiming callbacks feed
a bounded local window without scheduling UI work or adding a global cache.

For contour-following seams, searched inset, seam, outline, Path.combine and
existing geometry dependencies. Reused checkedPathMetrics, running stitches and
native surface clipping. Clipper2 supplies winding-aware polygon union/offset
instead of a new offset engine. The bounded adapter samples Flutter paths;
example-local PreparedSeamGeometry is shared by the seam study, card and material
playground. Equivalent recipes retain the pair; effective size changes replace
it. Shape, thread, native content and texture ownership remain independent.

For public image placement, searched SourceLayer, CroppedArtwork, FittedBox,
Positioned, CraftPart and PartPose. Extracted one CraftImagePart widget and removed
the duplicate example adapter. Reused CraftPart's native paint/input transform
and PartPose mapping instead of maintaining a second matrix or hit-test engine.
Source-crop conversion is explicit; attachments already include the artboard rect
origin. Native overlay layout is independent of the imported image pixels, and
normal ImageProvider owns decoding/cache lifetime. No manifest or clock is added.

For paper recipes, searched grain, fiber, corrugation, contours, shape value
equality and existing specimen controls. Retained MaterialTextures.paper as the
base algorithm and added bounded overlay finishes, without a parallel texture
cache. Paper edge geometry is separate from fiber fringe and native printing.
Extracted PreparedOutlineGeometry from the example's seam cache for both studies;
offset preparation stays lazy when enlarged content omits decorative sewing.

For the public boundary correction, searched exported actor presets, example
callers, tests and documentation media. Removed the consumer-specific tail from
`lib/` and its dedicated test. The example now composes its own waypoint curve
with `craftCurveThrough`; generic clock/pose tests stay in place. No replacement
actor preset is exported. See the 0.1.0 migration in compatibility.md.

Bounded freehand capture has a [consumer request](requests/freehand-capture.md).
The illustrative path arc limit remains intact; paintCraftFreehand separately
bounds solid input by points/strokes and reuses native stroke paint.

For delivery tracking, searched the roadmap, request records, PR descriptions and
retained local review reports. The tasklist links existing contracts rather than
duplicating consumer inventories; the review index distinguishes local agent
review from GitHub/human approval. No new runtime implementation is introduced.

For cord/ribbon/embroidery, searched rope, ribbon, embroidery, running stitches,
path metrics and contour offsets in library/examples. Reused checkedPathMetrics,
insetCraftPath and CraftSurface. Created only band shading/texture and a nominal
gap helper; existing running stitches keep their own puncture contract. Example
plates share the actual substrate silhouette and existing capture/theme helpers.
No second texture engine, transform, clock or copied application art is added.

For gravity/wind, searched pendulum, gravity, authored sway, PartPose, mapped
attachments and SceneEntrance. Reused pose/input mapping and the trim renderer
for the example tether. Authored sway is not a force integrator; created one
bounded fixed-step point-mass recipe sampled from caller time, without a second
clock, framework, flexible-rope solver or global simulation owner.

For the README cover, searched existing atlas/showcase capture shells, specimen
layout, textures, native lettering, watercolor, contour trims and PartPose.
Reused those renderers and fonts; created distinct shell/feather/crescent motifs
and one shared live/capture composition. No marketing mockup renderer, animation
clock, new dependency or golden-baseline replacement is introduced.

For long freehand, searched captured-point budgets, CraftStrokeStyle, pen/marker
paint setup, decorative arc guards and native drawPath/drawPoints. Reused style
validation and extracted one shared native paint factory. Created only a bounded
solid-pen rendering adapter, not a capture controller/export service. Ordered
input, native joins and taps are retained; decorative safeguards are unchanged.
