# Delivery tasklist

This is the public technical queue. Consumer inventories, application designs and
private adoption assessments stay outside this repository. See the
[roadmap](roadmap.md) for the wider material inventory and the
[review record](reviews/local-review-record.md) for exact reviewed candidates.

Status advances separately through implementation, independent review, CI,
publication and consumer validation. A runnable recipe is not a public API;
a passing widget test is not a phone benchmark or visual approval.

| ID | Request | Current evidence / next gate |
| --- | --- | --- |
| HC-D01 | Contour-following seams, including holes | Shipped in PR #9; bounded polygonal approximation |
| HC-D02 | Paper stocks, independent edges and finishes | Shipped in PR #10; six stock recipes, four edge styles |
| HC-D03 | Explicit stroke joins | Shipped in PR #4; round/miter/bevel |
| HC-D04–07 | Imported layers, rotary action, pour/light, rendering-cost scene | Runnable recipes in PRs #5–8; cost measurement in actual consumers/phones pending |
| HC-R01 | Traceable independent reviews | Record added; retrospective audit approved at `7c7225a` |
| HC-R02 | Remove consumer-specific actor preset | Published in PR #12; final review at `87786ec` |
| HC-R03 | Dependency/license release audit | 22 license hashes verified; clipper2 0.0.3 BSL-1.0 attribution retained |
| HC-R05 | Hosted publication readiness | 0.3.0 published on pub.dev; archive/tag parity and fresh hosted consumption verified; API/score generation remains separate |
| HC-R04 | Immutable version/tag | `v0.1.0` and `v0.2.0` retained; immutable `v0.3.0` at `2e63fee`, matching the first hosted archive |
| HC-P01 | Public clock-free image crop/artboard placement | Shipped in PR #11 at `e420be8`; independent review and CI passed |
| HC-P02 | Long freehand paths | Source adapter `paintCraftFreehand`: 128 strokes/8192 points and native parity; consumer adoption pending |
| HC-P03 | Rope, ribbon and embroidery over textures or contours | Published in PR #13 at `086763e`; native/Chrome checks and original compositions |
| HC-P04 | Gravity/wind and realistic/cartoon response | Published in PR #14 at `46e1518`; numerical/native-action checks and CI passed |
| HC-P05 | Public rotary-control abstraction | Example only; promote after complete consumer flows demonstrate a stable contract |
| HC-P06 | Deeper fabrics, stitches, relief and embroidered fills | Six stitch families implemented with shared thread paint; more fabrics/filled embroidery remain backlog; see PR/check evidence |
| HC-P07 | Capillary edges, prepared geometry and shared caches | Conditional; require demonstrated need/profile before new ownership contracts |
| HC-I01 | Fluvie / Social Studio adapters | Published in PR #19, Social Studio #16 and Fluvie #5; actual diagnostic CLI export and deterministic capture; full-size throughput pending |
| HC-V01 | Material/motion imagery and interactive gallery | Cover/relief PR #15; motion atlas and twelve-study gallery PR #18; Pages deployment and hosted navigation verified |
| HC-M01 | Drawing instruments | Pencil/chalk/wax decorative recipes extend the existing ink playground; fountain pen and further brush recipes remain candidates; long freehand stays solid pen |

## Foundation priorities

The [foundation request](requests/material-foundation.md) specifies acceptance
boundaries. The material vocabulary now has an initial implementation; the remaining
foundation items are proposals, not shipped APIs.

| ID | Priority / request | Next gate |
| --- | --- | --- |
| HC-F01 | Material-themed sheet/tag/ribbon/card/tray/heading/button/choice vocabulary | Initial CraftTheme/Panel/Button/Choice slice; two host-owned themes and state/focus/semantics checks; native themed heading added in current source; finish/layout recipes still pending |
| HC-F02 | One accessible artboard experience frame | Example-first frame implemented: shared crop/pose, unscaled native form/actions, measured footer; review/publication and consumer adoption tracked separately |
| HC-F03 | One art extraction pipeline | Private caller audit first; reproducible synthetic/provenance fixtures |
| HC-F04 | Accessibility contracts and test helpers | Native labels from frame zero, selected state on action, targets/focus/text scaling |
| HC-F05 | Actual Android/iPhone workload evidence | Real device-class measurements; desktop profiling remains useful separately |
| HC-F06 | Isolated consumer baseline adoption | Inspect pin, separate PR/changelog/licenses and pixel parity |
| HC-F07 | New-experience recipe book | Canvas to native text, checks and owner approval |

## Current visual work

- Paint spreading: elongated brush contact and uneven front; dragging now lays
  one connected wet band, with independent brush visibility/end-fade options, plus
  pink/blue-layer experiments; visual approximations, not a fluid solver.
- Completing only the chosen missing stitches (1..8), faster bare-tip motion,
  optional loose thread/needle in the full reveal, and a scroll-progress recipe.
- Needle-free thread with nonperiodic waves between fixed entry/exit anchors;
  below-cloth connectors stay hidden. Ordered botanical embroidery reveal is a
  separate example; both reuse caller-owned finite progress.
- Paint-led gallery discovery, native history/share links, varied material cuts
  and distinct kite/balloon rhythms. Broad README catalog retained; thread imagery
  lives in dedicated studies rather than dominating the README.

Additional fabrics, filled embroidery generalization, fountain pen/brush recipes,
and actor/physics extensions remain follow-up work. The consolidated 0.2.0 source
release is described in [release notes](releases/0.2.0.md).

Consumer migrations, pixel-parity checks, application visual approvals and phone
measurements have separate gates. This queue does not mark them completed by a
package merge. No full cloth, fluid or flexible-rope solver is claimed.

## Composed welcome candidate

The next welcome/README candidate adds an editable watercolor note using the
existing public material components. Desktop study actions precede the art;
paint starts at first contact and wetness controls sit before the preview.
Sharing has a visible Copy link label. Flower and material atlases remain.
The flower stays first in the README and pub.dev images by owner preference.
The note capture requires owner visual approval before public promotion. Browser
URL canonicalization, phone profiling and consumer adoption remain separate.

## Foam and colored cord candidate

Optional twisted color strands retain open/contour paths and nominal gaps. EVA
grain, four finishes and existing raised-layer lighting are independent. Public
examples use original procedural cuts; no application atlas is extracted.
Owner accepted the exact synthetic previews. Independent technical review and
CI precede promotion; physical-device evidence remains separate.

## Colored cord refinement

Owner accepted foam but found the first colored cord too stripe-like. A local
candidate replaces palette bands with interlaced yarn geometry and volume.
A new crossing-order raster regression requires cyclic over/under ownership;
transparent palette and open backing gaps are protected. Owner accepted the revised close-up preview. Independent technical review
and CI are required before promoting these images.
Foam, the flower cover and deferred Codecov setup are unchanged.

## Soft cloth, chalk and folded card candidate

Original pocket/flag, chalk garden and curled-blade specimens compose cotton,
velvety nap, felt, irregular running stitches, local puncture gathering and satin
paper. More body for chalk reuses the dry renderer through explicit coverage.
Legacy defaults remain; exact independent review and owner visual acceptance
precede public promotion. These are geometry/light recipes, not cloth physics.
[Recipes and limits](soft-craft-materials.md).

## Pressed foam marks

Optional `CraftReliefKind.inset` paints existing stitch geometry as pressed marks,
separate from raised yarn and cloth gathering. Original layered foam specimens
reuse the existing page, native controls and capture helpers. Shared geometry,
legacy defaults and explicit progress remain; this is light, not displacement.
[API and sample](eva-foam.md#raised-yarn-and-pressed-marks). Exact independent
review and CI precede public promotion; device measurements remain separate.

## Local volume and shared directional light

Example-only controlled comparison: existing rims, a thin EVA-like sheet and a
rounded clay-like profile use the same original cut, color and grain. A second
composition rotates thin and rounded pieces under one source. Direction, elevation,
softness, warmth and ambient light are explicit; contact/projection are separate
and overlap shadows clip to the receiver. Prepared geometry survives relighting.
[Recipe and limitations](local-volume.md). Exact independent review and CI precede
promotion. This does not complete a general scene-light API, realistic clay,
folded cloth/pocket geometry, full shadow interaction or device measurements.

## Lit fabric and curved bands

CraftLight/CraftVolume extract the reviewed proof for consumers; CraftBand adds
curved sheet lighting, copy-safe rails and distance attachments. A pocket recipe
shows layered opening/occlusion, soft folds and pale recessed irregular sewing.
Native controls provide finite insertion progress. Generic source and synthetic
media only. Exact review/CI precede publication; consumer adoption and Android /
iPhone measurement remain separately reported. Stop before physical-device
measurement for this delivery.

## Shaped band follow-up

See [material fidelity and placement](requests/material-placement-fidelity.md)
for acceptance boundaries and existing contracts.

- Profiled paper bands: independent arc-length edge distances, common cut/mesh/
  shadow geometry, continuous smooth closed joins and separate thickness/lift/
  shadow-softness parameters. Synthetic ribbon/loop/lift study; exact review,
  checks and publication are recorded separately.
- Visible-contour placement and conservative decorative stroke envelopes now
  have CraftPlacement.fit/CraftImagePart.placed and craftStrokeBounds candidates.
  Independent pocket controls remain an example recipe. [Proofs and limits](visible-fit-and-stroke-bounds.md);
  exact review/CI/publication remain separate from implementation and adoption.
- Android/iPhone measurement remains an external evidence gate.
- Short matte nap and layered EVA: CraftNap finish and 40..100px synthetic
  comparison now implemented, with independent fiber controls and receiver-clipped
  layer shadows. [Recipe, scope and limits](short-nap.md); exact review, CI,
  publication and consumer fidelity remain separate gates.

## Launch and spatial-light studio

- Implement one original scene for rounded clay-like volume, EVA and paper with
  a draggable XY lamp and independent height/distance response.
- Keep light fixed while changing a shape or rotating a piece; reuse prepared
  profiles, directional shading and resource ownership. No new package API.
- Validate native adjustable controls, narrow/enlarged layouts and Android
  emulator execution separately from physical-device performance.
- Consolidate 0.3.0 changes and tag the independently reviewed source; verify
  hosted gallery and retain pub.dev upload as an explicit owner action.

## Hosted publication completed

Version 0.3.0 uploaded to pub.dev on 2026-11-18 after explicit owner authorization.
The hosted archive matches v0.3.0; fresh hosted dependency resolution and a native
button inside EVA passed without Git/path overrides. No publisher transfer or
automated upload was configured. Hosted API/score generation is asynchronous;
interactive hosted-browser approval and phone performance remain separate.

## Adoption hardening after 0.3.0

[Acceptance criteria and delivery order](requests/adoption-hardening.md).

| ID | Work | Boundary |
| --- | --- | --- |
| HC-A01 | Current docs and focused reuse map | Shipped in PR #45; extraction history and links retained |
| HC-A02 | Tested SDK floor and CI matrix | 0.4.0 source release: Flutter 3.35.7 and 3.47.9; fresh-resolution matrix plus locked baseline; see sdk-compatibility.md |
| HC-A03 | Standard lint preset | Shipped in PR #47; narrow capture exceptions and effective strict/project-rule inheritance guards; see lint-policy.md |
| HC-A04 | Rendering/preparation baselines | Reuse the workload harness; report cold/warm preparation separately from frame timings |
| HC-A05 | Grain opacity experiment | Completed: direct alpha changes Chrome pixels; retain saveLayer and protect the legacy composition |
| HC-A06 | Scoped texture sharing | Conditional on evidence; explicit borrowed/owned lifecycle, seed and disposal semantics |
| HC-A07 | Physical-device evidence | Android/iOS profile validation remains a later owner-controlled gate |


## Continuous-surface and pattern proofs

| ID | Work | Boundary |
| --- | --- | --- |
| HC-S01 | Fixed source domain and clipped viewports | Synthetic 960×1728 recipe and 1×/3× counterexamples; clip rounding is measured, not pixel equivalence |
| HC-S02 | Quiet wash with soft alpha | Native mask recipe; separate core/feather/curve/outline; no default painter change |
| HC-S03 | Directional fibers and repeating print | Bounded example geometry on existing substrates; direction/length/density/strength and print phase remain explicit |
| HC-S04 | Beyond 2048 and cross-engine acceptance | Open; bounded proof does not implement arbitrary-size documents |
| HC-S05 | Consumer visual adoption | Open; no private art/data copied and no reference fidelity claimed |

See [request](requests/continuous-materials.md) and [proof/limits](surface-continuity.md).
Phone measurements remain deferred; broader performance baselines (HC-A04) are
not completed by exploratory raster/readback samples.


## Stuffed shapes and fabric selection

| ID | Work | Boundary |
| --- | --- | --- |
| HC-C01 | Research cloth for small stuffed silhouettes | Primary-source fabric/nap/stretch distinctions; generic visual recipes, not copied product assets |
| HC-C02 | Star, crescent and sun with configurable filling | Example-owned original cuts; existing bounded volume, no new package API or simulation |
| HC-C03 | Independent fabric, filling, thread and light | Cotton/felt/matte short-pile comparison; unchanged pattern and native controls |
| HC-C04 | Convincing minky/fleece/velour and soft deformation | Open: silhouette fuzz, directional sheen, stretch, low-fill folds and pressure response are not implemented |
| HC-C05 | Optional deeper stuffed-shape projection | Example-owned rounded side envelope, occluded mid-seam and shared raking light; original relief stays the default and its capture remains unchanged |

See [research, recipe and limits](stuffed-shapes.md). The first proof is a
visual height/bevel approximation, not measured fiberfill volume or fabric
elasticity. Independent review/CI and consumer visual acceptance stay separate.


## 0.4.0 source release

Consolidates the post-0.3.0 reviewed changes and supersedes the unshipped SDK-only
0.3.1 patch plan. Padded enum migration is explicit. Release checks use the
existing publishing/CI lanes; Git source delivery is separate from a pub.dev
upload. [Release notes](releases/0.4.0.md).


## Contact and articulated textile investigations

- Synthetic paper handoff: shared sheet/hand transform, explicit support overlap,
  print-safe fingers and out-of-order sampling proof implemented in examples.
- Two textile cuts: pinned shoulder, mapped elbow, delayed free end and fixed
  material-space marks implemented. This is a rigid-link baseline; a continuous
  flexible fold and cloth memory remain unproven.
- [Recipe and boundaries](contact-and-cloth.md). Exact independent review, CI,
  visual acceptance and publication remain separate gates. No new package API.

- Opt-in continuous textile: one cached material/sewing source, 48 shared-edge
  triangles and the existing band contour/light/shadow; two-cut raster and image
  ownership proofs. This is planar deformation; physical folding remains open.
