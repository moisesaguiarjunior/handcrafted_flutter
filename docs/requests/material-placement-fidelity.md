# Material fidelity and placement

Use synthetic shapes and compare at 320, 390 and 428 logical pixels. Consumer
artwork, coordinates and private designs must not become package fixtures.

## Shaped bands: implemented candidate

`CraftBandWidth` supplies independent distances on either side of one smooth
centerline, by normalized arc length. `CraftBand.edge` follows the actual border;
the substrate cut, shaded mesh and shadow use one prepared geometry. Smooth
closed curves join without end caps and preserve their interior hole. Thickness,
ground lift and shadow softness are independent. No embroidery is implicit.
See [the recipe and limits](../local-volume.md#independently-shaped-paper-bands).

Input knots allow deterministic irregularity; the caller supplies those values.
Two arbitrary separately authored edge paths, automatic welding of separate band
objects, cusp repair and self-intersection resolution are not implemented.

## Contour-aware placement: implemented candidate

Available: `CraftImagePart` already accepts a source crop, artboard destination
and optional `PartPose`, sharing the paint/input transform. `CraftBand.outline`
and `CraftVolume.bounds` expose the actual procedural cut in local coordinates.

CraftPlacement.fit now aligns declared visible bounds independently of the full
source painting window; CraftImagePart.placed reuses the existing adapter.
Synthetic padded raster/procedural tests retain outside paint and share native
anchors/actions at intermediate rotations in all three viewports. See
[placement, footprint and recipe controls](../visible-fit-and-stroke-bounds.md).
No runtime alpha scanning, second pose matrix or artwork manifest is added.

## Pocket composition: keep a recipe until a second caller proves the contract

Available: the original `PocketGeometry` example separates back, mouth/cavity,
note, front, folded lip, small folds and prepared inset thread. The face occludes
the note; the host supplies insertion progress. Existing band `at`/edge paths
supply attachment positions without owning a clothesline layout.

Independent mouth opening, fold depth, front height and paint-only pressure
are now configurable in the example; insertion remains host-owned. Note placement
and attachment layout stay consumer decisions. Before promotion, demonstrate them with
synthetic cuts, depth ordering and partial insertion, without turning one drawing
into a public preset. Retain native content/actions outside decorative paint.

## Dry-mark visual bounds: implemented candidate

Available: `CraftStrokeStyle` owns width and dry-pigment coverage. Stroke docs
already distinguish centerline bounds from visible coverage and native miter
extension; layout padding is caller-owned.

craftStrokeBounds now includes the instrument's maximum pigment dispersion,
cap/join and variation using the actual sampler primitives. Tests require every
painted pixel inside the conservative rectangle; the native-raster clip itself
may change subpixel quantization. Output-pixel clearance remains caller-owned
under downscaling. No second decorative path or shrinking native text is added.

Physical-device performance evidence remains separate from these geometric and
raster checks. None of these requests authorizes a new animation clock or cache.

## Short nap and layered foam: implemented comparison candidate

Compare woven cotton, short irregular matte fibers and thin EVA on synthetic
40..100px cuts. Nap scale, density, direction and contrast should be independent;
avoid a visible grid. Existing cotton/velvety material tiles remain available,
and the prepared CraftNap finish now supplies independent fiber geometry and
paint contrast. See [comparison and limits](../short-nap.md). Small-size specimens
are a visual proof, not calibrated physical-fabric fidelity.

For EVA over EVA, reuse separate CraftVolume cuts and one CraftLight. Clip the
upper piece's shadow to the lower receiver; keep their bevels/heights independent.
Compare diffuse pigment variation plus fine pores and localized sewing, without
turning the whole surface into a dotted finish. The original layered badge demonstrates this order with existing foam/volume
APIs. The new API is a fiber finish; no new foam/cotton enum or badge preset is
exported. Independent review/CI/publication are recorded separately.
