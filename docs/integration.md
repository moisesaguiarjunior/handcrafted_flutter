# Composition and external timelines

The core package has no dependency on a video renderer or application schema.
Use Flutter widgets and explicit material, color, seed, geometry and pose values
as the integration boundary. `CraftSurface` owns texture resources; `CraftPart`
shares its transform between paint, input and attachment mapping.

## Live widgets

```dart
CraftSurface(
  material: CraftMaterial.paper,
  color: const Color(0xFFFFFDF8),
  seed: 23,
  shape: CraftOutline.pigment(seed: 23, broad: true, padding: 5),
  child: TextButton(onPressed: openCollection, child: const Text('Open')),
)
```

Equivalent `CraftOutline` values retain cached geometry on rebuild. A custom
`outline` callback remains supported; keep its identity stable and supply only
one of `shape` and `outline`. Recipe `padding` changes the construction rectangle;
it does not compute a constant-distance seam inside an arbitrary path.

For a live finite entrance, use `SceneEntrance` and supply viewport/route
visibility through `active`. Respect the effective constrained size when mapping
anchors, and reserve parent space for translated/rotated touch targets.

## Fluvie

Let the frame timeline supply progress. Do not mount a second `SceneEntrance`
clock in captured artwork. The following adapter pattern uses Fluvie's
experimental `FrameBuilder` API; it belongs in a consumer that depends on both
packages, not in the core package. The snippet is analyzed against Fluvie 0.3.1;
its experimental-use warning is acknowledged at the call site. The
[consumer integration](consumer-video-integration.md) verifies media discovery
and a diagnostic CLI export; this snippet alone is not a complete video job.

```dart
import 'package:fluvie/fluvie.dart';
import 'package:flutter/widgets.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

// Place inside the video/scene's resolved time scope.
// ignore: experimental_member_use
FrameBuilder((frame) {
  final p = frame.progress;
  return CraftPart(
    key: const ValueKey('keepsake-piece'),
    size: const Size(320, 180),
    pose: PartPose(translation: Offset(0, (1 - p) * 24)),
    child: const CraftSurface(
      material: CraftMaterial.linen,
      color: Color(0xFF80A99A),
      seed: 23,
      shape: CraftOutline.pigment(seed: 23, broad: true),
      child: Center(child: Text('A small keepsake')),
    ),
  );
})
```

Pin and validate the Fluvie version in the adapter. Seek/repeated frame requests
must reproduce the same pose; do not read wall-clock time or start tickers in the
artwork. Preserve source dimensions and check raster work limits before a 4K
export. Current texture painting supports bounds up to 2048 logical pixels.

## Social Studio

The consumer now has a versioned crafted desktop template, story-craft-v1 in
job format 2. Its original format 1 remains strict and rejects additional fields.
The schema belongs to Social Studio; this core package does not parse jobs or
serialize arbitrary callbacks/types. The consumer retains content authorization,
media paths, captions, timing, export profiles and network policy.

| Field | Meaning |
| --- | --- |
| material | Allowlisted substrate identifier |
| color | Consumer color convention, #RRGGBB or #AARRGGBB |
| seed | Explicit texture/shape seed |
| grainScale, grainStrength | Validated texture scale and strength |
| frameInset | Authoring fraction of the shorter canvas side |
| edge, stitch | Allowlisted cut and thread treatments |

See [the executable consumer integration](consumer-video-integration.md) for
JSON, CLI commands, immutable dependency pins and the public Fluvie
CollectibleChildren contract. Structural media discovery happens before frame
capture: wrappers expose declared media rather than hiding it in build callbacks.
The first template reuses the consumer's photo motion and existing export
transaction. Phone performance and full-size throughput remain unmeasured.
