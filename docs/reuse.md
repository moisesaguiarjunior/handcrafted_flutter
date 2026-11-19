# Reuse map

| Need | Canonical implementation |
| --- | --- |
| Fine-pore EVA and independent bounded impressions | `CraftMaterial.eva`, `paintFoamFinish` |
| Seeded perimeter | `pigmentOutline` |
| Value-based silhouette recipes | `CraftOutline`, `CraftSurface.shape` |
| Material tiles and owned resources | `MaterialTextures`, `CraftMaterial` |
| Bounded layered pigment with explicit palette | `paintWatercolor` |
| Directional motif rims and native lettering | `paintCraftRelief`, `CraftReliefText` |
| Native themed headings | `CraftHeading`, `CraftReliefStyle`, `CraftTheme.heading` |
| Raised cord/ribbon/embroidered bands and nominal edge gap | `paintCraftTrim`, `contourTrimPath` |
| Patterned thread geometry and shared puncture paint | `craftStitchPath`, `paintCraftStitch`, internal `thread_paint.dart` |
| Stitch spans and puncture shading | `runningStitchPath`, `paintRunningStitch` |
| Shared bounded arc-length geometry | `lib/src/path_geometry.dart` (internal) |
| Closed-silhouette polygonal insets | `insetCraftPath`, using pinned clipper2 union/offset |
| Paper finish and edge composition | `paintPaperFinish`, `paperOutline`, `paintPaperEdgeFibers`, `CraftOutline.paper` |
| Curved waypoints and explicit reveal | `craftCurveThrough`, `trimCraftPath` |
| Pen, marker, brush and dry instrument patterns | `CraftStrokeStyle`, `paintCraftStroke` |
| Paint, input and anchor transform | `PartPose`, `CraftPart` |
| Material behind native widgets | `CraftSurface` |
| Host-themed material roles and native actions | `CraftTheme`, `CraftPanel`, `CraftButton`, `CraftChoice` |
| Clock-free rigid gravity/wind response | `CraftPendulum`, `CraftPendulumSample` |
| Finite entrance clock | `SceneEntrance` |
| Runnable compositions and captures | `example/lib/use_cases.dart`, `tool/capture_showcase.dart` |
| Drawing playground and capture | `example/lib/main_strokes.dart`, `tool/capture_strokes.dart` |
| Shared specimen layouts and visual inventory | `example/lib/material_studies.dart`, `example/lib/main_atlas.dart` |
| Authored actor examples with independent progress | `example/lib/motion_studies.dart`, `example/lib/kite_art.dart` |
| Canonical example palette and typography | `example/lib/showcase_theme.dart` |
| Project mark composition and capture | `example/lib/brand_mark.dart`, `tool/capture_brand.dart` |
| Public imported crop, source hinge and placement | `CraftImagePart`; `example/lib/imported_layers.dart` shows the consumer composition |
| Shared example capture shell and PNG writer | `tool/capture_support.dart` |
| Prepared material height/normal fields and scene light | `CraftVolume`, `CraftLight` |
| Curved bands with independent rails and shadows | `CraftBand`, `CraftBandWidth` |
| Independent prepared short fibers | `CraftNap` |
| Visible-contour fit retaining the full paint window | `CraftPlacement.fit`, `CraftImagePart.placed` |
| Conservative local decorative stroke envelopes | `craftStrokeBounds` |
| Cross-SDK validation and resolution lanes | `tool/check_compatibility.sh`, `docs/sdk-compatibility.md` |
| Standard analysis and scoped capture exceptions | `analysis_options.yaml`, `tool/analysis_options.yaml`, `tool/check_lint_policy.py` |
| Format, analysis and behavior checks | `tool/check.sh` |

Search by name, behavior and type before introducing a parallel implementation.
Reuse the actual layout size for pivots and attachment mapping. Thread and holes
share span geometry. Native widgets retain actions, semantics, layout and focus.
Application policies, content and internal integration assessments stay with the
consumer, outside this repository.

## Before creating another implementation

1. Search by name, behavior and type, including actual callers in the examples.
2. Record **Reuse** (existing contracts) and **Create** (the missing contract and
   why the existing one does not fit).
3. Preserve ownership, seeds, explicit progress, effective layout/input transforms
   and native semantics. Measure before introducing shared caches or prepared APIs.
4. Update this map when a canonical contract is added, moved or removed.

[Extraction history](history/reuse-extractions.md) preserves the earlier notes,
including searches and rejected parallel implementations. History is evidence,
not a second current-status list. Dedicated example entrypoints and immutable
source refs are not removed merely to reduce file or branch counts.
