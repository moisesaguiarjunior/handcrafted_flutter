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
packages, not in the core package. It has been checked against source signatures,
but an end-to-end video export has not yet been validated here.

```dart
import 'package:fluvie/fluvie.dart';
import 'package:flutter/widgets.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

// Place inside the video/scene's resolved time scope.
FrameBuilder((frame) {
  final p = frame.progress;
  return CraftPart(
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

Use a consumer-owned, versioned template contract. The current desktop-story
`story-photo-v1` job schema rejects additional properties, so attaching arbitrary
material arguments to that job is not a supported integration.

A future template can validate an allowlisted material recipe before compiling
it into `CraftSurface` and an explicit pose. Proposed parameters, not a shipped
JSON API:

| Field | Meaning |
| --- | --- |
| `material` | Stable allowlisted substrate identifier |
| `color` | Explicit color convention; use the consumer's RGB/ARGB parser |
| `seed` | Integer controlling reproducible texture |
| `scale`, `strength` | Validated texture units and grain range |
| `shape` | Allowlisted value recipe and its bounded parameters |
| `pose` | Translation, rotation and scale in explicit units |
| `progress` | Supplied by the resolved frame scope, not a new animation clock |

The consumer retains content authorization, captions, timing, export profiles and
network policy. A layered artwork manifest should carry asset references, pivots
and hit regions separately from substrate recipes. Do not serialize arbitrary
callbacks, Dart types or executable code. Preserve one validated contract across
preview and export rather than maintaining two renderers.
