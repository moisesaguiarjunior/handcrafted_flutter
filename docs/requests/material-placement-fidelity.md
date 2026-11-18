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

## Contour-aware placement: evaluate before extracting

Available: `CraftImagePart` already accepts a source crop, artboard destination
and optional `PartPose`, sharing the paint/input transform. `CraftBand.outline`
and `CraftVolume.bounds` expose the actual procedural cut in local coordinates.

A future visible-contour fit helper should map a declared source visible bounds
to a destination independently of transparent file padding. It must retain the
same hinge, attachments and hit transform at intermediate rotations. Test one
synthetic padded raster and a procedural replacement at the three viewports.
Do not add runtime alpha scanning, another matrix or an artwork manifest.

## Pocket composition: keep a recipe until a second caller proves the contract

Available: the original `PocketGeometry` example separates back, mouth/cavity,
note, front, folded lip, small folds and prepared inset thread. The face occludes
the note; the host supplies insertion progress. Existing band `at`/edge paths
supply attachment positions without owning a clothesline layout.

Independent mouth opening, fold depth, note placement and attachment controls
are still example/consumer decisions. Before promotion, demonstrate them with
synthetic cuts, depth ordering and partial insertion, without turning one drawing
into a public preset. Retain native content/actions outside decorative paint.

## Dry-mark visual bounds: a conservative contract is still needed

Available: `CraftStrokeStyle` owns width and dry-pigment coverage. Stroke docs
already distinguish centerline bounds from visible coverage and native miter
extension; layout padding is caller-owned.

A future helper must include the instrument's maximum pigment dispersion,
cap/join and pressure variation, with a conservative guarantee, not tight raster
alpha bounds. Compare unclipped/clipped chalk at narrow sizes and ensure every
painted pixel is inside the declared rectangle. Reuse the actual stroke sampler;
do not maintain a second decorative path or shrink native text to fit.

Physical-device performance evidence remains separate from these geometric and
raster checks. None of these requests authorizes a new animation clock or cache.
