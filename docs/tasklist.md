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
| HC-R04 | Immutable version/tag | Published immutable source tag `v0.1.0` at `87786ec` |
| HC-P01 | Public clock-free image crop/artboard placement | Shipped in PR #11 at `e420be8`; independent review and CI passed |
| HC-P02 | Long freehand paths | Minimal solid-pen adapter implemented locally; 128 strokes/8192 points, native parity; independent review/publication pending |
| HC-P03 | Rope, ribbon and embroidery over textures or contours | Published in PR #13 at `086763e`; native/Chrome checks and original compositions |
| HC-P04 | Gravity/wind and realistic/cartoon response | Published in PR #14 at `46e1518`; numerical/native-action checks and CI passed |
| HC-P05 | Public rotary-control abstraction | Example only; promote after complete consumer flows demonstrate a stable contract |
| HC-P06 | Deeper fabrics, stitches, relief and embroidered fills | Backlog; original shapes, native text/actions, separate visual review |
| HC-P07 | Capillary edges, prepared geometry and shared caches | Conditional; require demonstrated need/profile before new ownership contracts |
| HC-I01 | Fluvie / Social Studio adapters | [Explicit parameters and supplied progress](integration.md); no second clock or application schema ownership |
| HC-V01 | Material/motion imagery and interactive gallery | New material cover and distinct relief studies prepared; review/publication pending. Replacement motion captures and hosted gallery remain pending |

## Next sequence

1. Review and publish the generic-art boundary correction, release evidence and
   immutable baseline without erasing retained work.
2. Implement composable rope/ribbon/embroidery with bounded work and examples.
3. Add bounded gravity/wind response with caller-supplied time and explicit styles.
4. Assess long freehand rendering separately from decorative arc-length budgets.
5. Profile actual consumer scenes, then devices; promote additional abstractions
   only when real callers require them.

Consumer migrations, pixel-parity checks, application visual approvals and phone
measurements have separate gates. This queue does not mark them completed by a
package merge. No full cloth, fluid or flexible-rope solver is claimed.
