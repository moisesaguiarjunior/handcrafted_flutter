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
| HC-P02 | Long freehand paths | Source adapter `paintCraftFreehand`: 128 strokes/8192 points and native parity; consumer adoption pending |
| HC-P03 | Rope, ribbon and embroidery over textures or contours | Published in PR #13 at `086763e`; native/Chrome checks and original compositions |
| HC-P04 | Gravity/wind and realistic/cartoon response | Published in PR #14 at `46e1518`; numerical/native-action checks and CI passed |
| HC-P05 | Public rotary-control abstraction | Example only; promote after complete consumer flows demonstrate a stable contract |
| HC-P06 | Deeper fabrics, stitches, relief and embroidered fills | Six stitch families implemented with shared thread paint; more fabrics/filled embroidery remain backlog; see PR/check evidence |
| HC-P07 | Capillary edges, prepared geometry and shared caches | Conditional; require demonstrated need/profile before new ownership contracts |
| HC-I01 | Fluvie / Social Studio adapters | [Versioned consumer template and declared media](consumer-video-integration.md); actual capture/export exercised in consumer; review/publication tracked separately |
| HC-V01 | Material/motion imagery and interactive gallery | Material cover/relief in PR #15; generic motion captures and hosted gallery workflow implemented; deployment verified separately |

## Next sequence

1. Review/publish six stitch families and preserve legacy running pixels.
2. Restore generic motion captures and host the live gallery with bounded demos.
3. Validate external-timeline adapters without adding a second clock or adopting
   application-owned schemas into the core package.
4. Expand fabrics/instruments in bounded recipes with actual visual examples.
5. Profile actual consumer scenes, then devices; promote shared caches only when
   demonstrated by measured workloads.

Consumer migrations, pixel-parity checks, application visual approvals and phone
measurements have separate gates. This queue does not mark them completed by a
package merge. No full cloth, fluid or flexible-rope solver is claimed.
