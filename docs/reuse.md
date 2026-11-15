# Reuse map

| Need | Canonical implementation |
| --- | --- |
| Seeded perimeter | `pigmentOutline` |
| Material tiles and owned resources | `MaterialTextures`, `CraftMaterial` |
| Stitch spans and puncture shading | `runningStitchPath`, `paintRunningStitch` |
| Paint, input and anchor transform | `PartPose`, `CraftPart` |
| Material behind native widgets | `CraftSurface` |
| Finite entrance clock | `SceneEntrance` |
| Authored kite-tail preset | `authoredKiteTail` |
| Runnable compositions and captures | `example/lib/use_cases.dart`, `tool/capture_showcase.dart` |
| Format, analysis and behavior checks | `tool/check.sh` |

Search by name, behavior and type before introducing a parallel implementation.
Reuse the actual layout size for pivots and attachment mapping. Thread and holes
share span geometry. Native widgets retain actions, semantics, layout and focus.
Application policies, content and internal integration assessments stay with the
consumer, outside this repository.
