# Reuse extraction history

Historical implementation notes retained from the reuse guide at `01fbb52`.
They explain earlier extractions and decisions; use the current
[reuse map](../reuse.md) to find canonical contracts and the
[tasklist](../tasklist.md) for delivery status.

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
[Adoption recipes](../consumer-adoption.md) reuse these contracts and describe
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

Bounded freehand capture has a [consumer request](../requests/freehand-capture.md).
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

For stitch families, searched runningStitchPath, path metrics, blanket/chain/cross
patterns and trim shading in library/examples. Reused arc validation, native seam
extraction, contour insets and the existing thread painter (extracted unchanged).
Created only bounded family geometry; the legacy running painter remains pixel
identical against an isolated old-source raster probe. The six-plate example uses
actual layout-size cuts, existing materials, native sliders and capture helpers.

For the hosted gallery, searched standalone main entrypoints, study widgets,
clock activity/disposal, capture loops and web workflows. Reused all existing
public study widgets behind one native drawer, mounting only the selected page.
Extracted the existing motion-atlas capture into one shared function, used by
both dedicated and full-atlas commands. No duplicate renderer, clock, texture
cache, application router or video-job schema is introduced.

For bilateral video integration, searched the actual Fluvie media walk,
CollectibleChildren/FrameBuilder and Social Studio's validated jobs, frozen
snapshots, frame pump and encoder. Existing core primitives were sufficient;
the consumer adapter declares media and owns its versioned schema. Documented
that contract rather than adding a JSON parser, peer dependency, media collector
or second clock to this package. Actual consumer capture/export tests protect it.

For dry instruments, searched CraftStrokeTool, pathSpans, brush sampling, native
ink paint and paintCraftFreehand across source, tests and gallery. Reused checked
path metrics, validation, patterns, progress and the existing study/capture shell.
Added only seeded deposit paint in a private part, without another path sampler,
clock, raster cache, substrate eraser or freehand capture contract. No decisions
directory exists; the drawing guide records the additive enum migration and work
bound. Reconciled shipped gallery/stitch/integration items in the public queue.

For living materials, searched watercolor preflight/pigment fields, stitch output
budgets, shared thread shading, SceneEntrance, native Router/Interval, galleries
and captures. Reused existing palettes/material ownership and defaults. Added
only bounded front geometry and owned thread-frame sampling; existing static
endpoints retain their pixels. Browser history uses Flutter Router instead of a
parallel JavaScript history layer. Example wet mixing/hidden thread returns stay authored
recipes. New foundation requests reuse existing native contracts before extraction.

For enlarged gallery navigation, searched native dropdown/popup intrinsic layout,
text selection boxes and the existing licensed-font test loader. Reused the native
popup menu with a wrapping label instead of fixing its selected-field height.
Browser tests read the canonical font files through the test asset server, with
a relative symlink instead of duplicated font bytes; runtime assets are unchanged.

For oversized native letterhead, searched the existing paper/texture 2048-axis
budgets, SeamedSurface and native layout. The example measures decoration with
a positioned LayoutBuilder behind the unchanged native content; oversized
content receives a plain background instead of allocating an oversized texture
or relaxing package guards. No text measurement or second layout engine is added.

For finishing stitches, searched thread stations, CraftStitchFrame, generated
stitch contours, SceneEntrance, finite progress and reveal-tip artwork. Reused
all three existing contracts: kept loose-wave and full-sprig modes, added an
example-only missing-stitch recipe and optional reveal props. Native controls
configure count; scroll can supply progress without a second clock. No public
thread physics or application-owned scroll policy is introduced.

For material vocabulary, searched ThemeExtension, native button/focus/semantics,
PreparedSeamGeometry, value outlines and bounded letterhead fallback. Composed
CraftSurface, insetCraftPath, craftStitchPath and owned snapshots; no parallel
texture, inset, thread or interaction renderer. The new panel contract keeps
native content outside decorative clipping, unlike the existing clipped example
surface. Its per-owner geometry cache is prepared outside paint. ThemeExtension,
TextButton/Material/InkWell and native padding/theme interpolation remain canonical.
No private consumer palette, application state, persistence, font or clock added.

For the dragged brush, searched the contact/stamp recipe, curve metrics, seeded
watercolor, stroke reveal, prop paint and the finite gallery clock. Reused one
prepared curve and the existing watercolor renderer, clipped to a bounded swept
ribbon; removed the per-deposit round washes from the drag only. First-touch
spreading and pink/blue contact keep their existing pigment recipe. Shared native
widget pixel reading is extracted from the vocabulary test rather than copied.
No fluid engine, extra clock, mutable global cache or application art is added.

For the experience frame, searched keyboard/SafeArea/footer/FittedBox layouts,
source crops/hinges and native form identity. Reused CraftImagePart/PartPose,
applyBoxFit, the synthetic sprite, themed native controls and capture helpers.
Extracted example-only lid/base factories shared with ImportedComposition rather
than copying source geometry. Native layout measures the footer; Wrap topology
keeps fields stable. No text layout engine, scene clock, manifest or consumer art.

For the 0.2.0 source release, searched the version manifest, lockfiles, Git tags,
public exports, changelog, compatibility policy and dependency/license inventory.
Reused the existing release/check/review flow; no parallel publishing tool or
runtime API is added. Release notes separate package APIs from example recipes.

For material headings, searched CraftReliefText, native heading semantics,
ThemeExtension/copyWith/lerp, vocabulary forms and capture/pixel helpers. Reused
the exact glyph renderer/validation and native headlineMedium/Text layout.
CraftHeading adds semantic heading and theme resolution only; CraftReliefStyle
stores host lighting without palette/fonts/content. Depth interpolates while
kind/light switch discretely, avoiding invalid opposing-vector interpolation.

For pub.dev readiness, searched pubspec/lockfiles, .gitignore versus Pub's actual
file list, existing screenshots/capture targets, README links, CI and dartdoc.
Reused existing image bytes and runtime/example code. The publication checker
uses Pub's real dry-run in a disposable Git-source snapshot, seeded only with
synthetic local/generated probes; it does not implement a second archive engine.
Full guides/tools stay Git-only; selected images move to the conventional doc
folder without duplication. No runtime dependency or publisher credential added.
Standard control-flow bracing reuses the analyzer rule and Dart's own targeted
fixer; existing conditions/expressions remain unchanged. No custom style fixer
or parallel linter is maintained. The archive probe is a real failure control,
not a parser pretending to reproduce Pub's inclusion rules.

For the wide vocabulary study, searched the gallery's 1100px layout, the panel's
1024px decoration guard, existing form identity tests and native ConstrainedBox.
Constrained only this example to 800px; no painter budget or fallback changed.
A test exercises the actual gallery at common desktop widths in both themes,
scoping the primary card's own CraftSurface instead of matching button surfaces.

For the composed welcome, searched GalleryWelcome, MaterialVocabularyStudy,
CraftPanel/Theme/Heading/Choice/Button, watercolor, contour seams, gallery routes
and capture helpers. PaintedNote composes those APIs around one native form;
it adds no public component, dependency, texture engine or clock. The README
capture uses the same widget as the live welcome. Desktop actions precede art;
paint wetness precedes its preview, and first contact starts at zero. Native
router behavior remains unchanged; URL canonicalization is separate work.

For coverage, searched the existing check script, test suites, CI and archive
rules. Reused the root Flutter test invocation with --coverage, retaining the
example gate. A separate OIDC job uploads the actual explicit LCOV artifact;
no parallel test suite, upload token or source exclusion was introduced.

For multicolor cord and EVA, searched craft_trim, contourTrimPath, texture cache
ownership, paper finishes, path validation, relief and SpecimenRow/captures.
Reused validated centerlines, normal/tangent samples, seeded tile ownership and
raised relief. Added only optional front-facing strand colors and a fine-pore
material with independent bounded finishes. Existing material enum indices and
single-color rendering are preserved. The examples use original procedural cuts,
not application assets, manifests or a new clock. Root Flutter pub get already
resolves/enforces the example; setup now runs it once, backed by a missing-lock
negative control in an isolated snapshot.

Foam adjustment labels and units merge into the native adjustable node using
Flutter MergeSemantics/Semantics; the gallery regression inspects the actual
action-bearing node after real drags, rather than an unlabeled outer container.

For the cord correction, searched paintCraftTrim, contourTrimPath, path metrics,
strand palettes and capture/live callers. Reused their validation and nominal
placement contract. Replaced only palette rendering with locally depth-ordered
individual yarn segments and strand-aligned filaments; the single-color/ribbon/
embroidery branches remain unchanged. One private sampling plan enforces the
existing 8192-sample ceiling before paint. Close-ups reuse the actual painter,
not an image mockup or a second clock. Foam is unchanged.

The first stroke-segment prototype accumulated fractional alpha. Colored yarns
now reuse that sampling plan as shared-edge strips in one temporary Flutter
Vertices mesh; color, edge light and fiber variation are vertex colors, not
repeated alpha coats. Native vertices are disposed after recording, with no image,
layer or global cache. A regression keeps one alpha-64 yarn at alpha 64 across
three sampling pitches and rejects the overlapping-stroke prototype.

For soft-cloth studies, searched material tiles, felt/linen/twill grain, chalk
and dry deposits, inset seams, running spans, thread punctures and prepared
frames. Reused cache ownership, geometry limits, native gradients, capture shell
and actual gallery specimens. Added cotton/velvety nap tiles to the existing
cache; satin sheen to the paper finish; optional seeded irregular running spans
and gathering to shared puncture paint; dry coverage to the existing dry stroke
renderer. Zero defaults preserve earlier behavior. One original example composes
these contracts; no parallel texture/drawing engine, object preset, clock or
consumer artwork is introduced. See [soft craft recipes](../soft-craft-materials.md).

For the leather material and project mark, searched `CraftMaterial`, suede, EVA,
pebbled `FoamFinish`, relief, trims, running stitches and capture helpers. The
pebbled foam finish is an overlay for EVA, not a hide grain, so leather is a new
tile in the existing `MaterialTextures` cache rather than a parallel renderer.
The mark reuses `insetCraftPath`, `paintRunningStitch`, `paintCraftRelief`,
`paintCraftTrim`, `CraftReliefText` and `captureExample`; only the tag outline,
eyelet and fiber ends are example-local. The palette stays example-owned.

For pressed foam marks, searched the thread painter, running/patterned geometry,
prepared stitch frames, CraftReliefKind and foam studies/captures. Reused the
existing relief enum, path preparation/limits, progress, contour insets, resource
owner and actual gallery/capture shell. Added only optional inset stroke lighting
to canonical thread paint; raised defaults remain intact. Original foam layers
and leaf motifs compare narrow pressed lips with raised cream yarn inside the
existing foam study, not a new renderer, scene preset, cache or clock.

For visual-refresh integration, searched native button child slots, keyed editor
identity, postcard breakpoints, mark geometry budgets and existing capture/tests.
Retained the check renderer while keeping the stateful label in one stable row
slot. Host-owned keyed editor locations preserve the same native editing state
across the postcard's two layouts. A bounded mark artboard scales as decorative
art before path preparation; ordinary form content remains unscaled. Original
leather/README commits and the pressed-foam study are both retained, without a
parallel material, UI-state engine, clock or decorative inset implementation.

For the example-only local-volume proof, searched material grain, relief, path
metrics/insets, mesh ownership, specimen layout and capture helpers. Reused
MaterialTextures, trimCraftPath, paintCraftRelief, SpecimenRow and the shared
capture shell. New bounded height/normal preparation stays outside paint; native
light controls and inverse planar light conversion use no new clock, dependency,
public material or renderer API. Actual receiver clipping protects overlap/holes.
See [recipe and limits](../local-volume.md).

Package tests retain `test/support/raster.dart` as a forwarding import; the shared
fixture lives in unexported `lib/src/testing/raster_fixture.dart` so both test
packages can resolve its package URI without escaping a browser-served root. It
is imported only by tests and creates no production painter dependency. There
is one raster implementation, responsible for exception-safe recorder, picture
and image disposal.

For lit fabric and curved bands, reused the reviewed local-volume field, inverse
light transform and exception-safe mesh lifecycle. Promoted them to CraftLight /
CraftVolume, with private buffers, copied paths and independent height/bevel.
CraftBand shares the shader and shadows, using bounded arc-length stations and
nine cross-section vertices; its rails feed existing stitches. The pocket recipe
uses existing cotton/felt/paper, inset thread and native progress controls. No
parallel lighting engine, texture cache, clock or private artwork was added. Core
proof tests moved to package tests instead of being duplicated in the example.

Complete seams in the folded-pocket example are prepared once with the band/cut,
then reused across colors, relighting and insertion. This keeps static thread
sampling outside paint, matching the prepared geometry ownership contract.

For independently shaped paper bands, searched CraftBand rails, prepared volume
meshes, shadow lift, contour insets and original ribbon callers. Reused one
bounded centerline and the shared shader/shadow painter. Arc-length width keys
now feed the same cut, border rails, mesh and shadow, including smooth closed
joins. Thickness, ground lift and shadow blur stay separate. No second outline,
lighting engine, stitch path, random source or clock was added. Synthetic examples
and small-screen captures do not contain consumer shapes or artwork.
The placement follow-up distinguishes current crop/pose, pocket-layer and stroke
contracts from proposed extraction; see [fidelity requests](../requests/material-placement-fidelity.md).

For short matte nap, searched MaterialTextures cotton/suede/felt tiles, foam finish,
shared path validation, volume normals, receiver clipping and existing capture /
control recipes. Fixed tiles cannot independently vary nap density/direction.
CraftNap is therefore a prepared finish, with bounded local candidate geometry
batched into four tonal paths. It reuses path validation and ordinary clipped
Flutter paint; the existing material enum/cache are unchanged. Layered foam
reuses mottled finish, grain, CraftVolume/CraftLight and prepared inset sewing.
All comparison cuts are original synthetic geometry; no consumer art is included.

For visible-contour placement and decorative footprint measurement, searched
CraftImagePart source crop/hinge, CraftPart/PartPose matrices, brush/dry deposit
sampling, stroke joins, and pocket paint/caches. Extracted one CraftPlacement
from the existing image geometry; its fit keeps full paint and declared visible
windows separate. Existing image placement/touch and native overlay topology
remain shared. craftStrokeBounds uses the same extracted dry step/offset/width/
length helpers and native miter constant as painting, without another sampler.
The pocket's independent controls stay in its original example recipe, with
paint-only changes retaining prepared geometry. Synthetic authoring/capture and
frozen-renderer parity use existing native resource/font ownership. No private
art, second matrix, hit-test engine, clock or global cache was introduced.

For the spatial-light launch scene, searched CraftLight normalization, local-space
conversion, CraftVolume profiles/shadows, MixedVolumeStudy, gallery routes and
capture ownership. Reused all prepared rendering and material resources. The
example samples a bounded point lamp once per piece, including distance falloff,
then converts that directional sample to the piece frame. Native sliders/chips
provide keyboard and assistive access alongside the drag handle. No point-light
API, physics solver, global cache or extra clock is exported. The Android smoke
uses a temporary generated host and copies the actual example unchanged.

For first hosted publication, reused the reviewed v0.3.0 source, real Pub archive
validator, native surface/action contract and immutable tag. Compared hosted
archive files with Git objects and installed the hosted version in a disposable
consumer without overrides. Only publication status and installation guidance
change in main; no runtime implementation, credential or publisher automation.

For SDK compatibility, searched TickerMode enabled/notifier access, actual clock
pause/resume callers, boolean/tristate semantic flags, framework button subclasses,
SDK pins and both existing test suites. Reused the common boolean accessor and
Flutter's containsSemantics matcher rather than reflection or a second clock.
Only its compatibility deprecation is suppressed, on one documented line. CI
separates exact release locks from fresh per-SDK resolution and builds the actual
gallery. No rendering, seed, texture ownership or published tag changes.

For the standard lint preset, searched analyzer scopes, package imports, capture
entrypoints, example dependency graphs and existing checks. Reused flutter_lints
and the source snapshot helper rather than inventing another linter/validator.
Library and example retain the full preset/strict/API rules. The cross-package
capture tool scope allows only relative-lib imports; one root integration probe
has the same documented file-level exception. Snapshot-based synthetic violations
prove preset and inherited rule enforcement without mutating the working tree.
No runtime dependency, renderer, clock, cache or capture command is replaced.
