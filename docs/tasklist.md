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
| HC-R04 | Immutable version/tag | `v0.1.0` at `87786ec` retained; consolidated `v0.2.0` release candidate prepared; exact review/CI/tag tracked by PR/release |
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
| HC-F01 | Material-themed sheet/tag/ribbon/card/tray/heading/button/choice vocabulary | Initial CraftTheme/Panel/Button/Choice slice; two host-owned themes and state/focus/semantics checks; heading/finish/layout recipes still pending |
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
