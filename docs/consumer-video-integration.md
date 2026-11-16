# Materials in an actual video pipeline

The integration keeps three owners: handcrafted_flutter supplies material/shape/
thread primitives, Fluvie resolves media and frame timing, and Social Studio owns
its language-neutral job schema, authorization boundary and export transaction.
Neither the material package nor the renderer chooses what content may be shared.

## Pass a recipe through the consumer

Social Studio's crafted desktop template uses job version 2 and template id
story-craft-v1. Its required craft object is validated by the consumer schema:

```json
"version": 2,
"template": "story-craft-v1",
"craft": {
  "material": "linen",
  "color": "#F3EADC",
  "seed": 23,
  "grainScale": 1,
  "grainStrength": 0.7,
  "frameInset": 0.08,
  "edge": "torn",
  "stitch": "chain"
}
```

The complete job still supplies local photo/audio references, duration, captions
and cover time. These are consumer fields, not a JSON API parsed by this package.
Version 1 remains strict and rejects craft. Grain scale is distinct from photo
zoom; frameInset is an authoring fraction of the shorter canvas side, not a
platform safe zone. No callback, remote texture URL or timer is accepted.

Run the consumer's synthetic fixture from its repository root:

```sh
python3 probes/phase1/tool/generate_story_assets.py
cd flutter/social_studio
flutter pub get --enforce-lockfile
dart run bin/social_studio.dart validate example/craft.json
dart run bin/social_studio.dart render example/craft.json out/crafted-story
```

The consumer pins this package by immutable Git revision. The initial integration
uses hosted Fluvie 0.3.1; it does not assume that the maintained fork and consumer
advance together. See the [consumer guide](https://github.com/moisesaguiarjunior/social-studio/blob/main/docs/crafted-story.md)
for the supported recipe/canvas envelope and full commands.

## Declare media before frame capture

A material widget may be opaque to a renderer's structural media walk. Fluvie's
existing public CollectibleChildren interface lets a consumer wrapper expose its
declared child without coupling this core package to Fluvie:

```dart
import 'package:flutter/widgets.dart';
import 'package:fluvie/fluvie.dart' show CollectibleChildren;
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

class DeclaredMaterial extends StatelessWidget implements CollectibleChildren {
  const DeclaredMaterial({super.key, required this.child});
  final Widget child;

  @override
  Iterable<Widget> get collectibleChildren => [child];

  @override
  Widget build(BuildContext context) => CraftSurface(
    material: CraftMaterial.linen,
    color: const Color(0xFFD8C9A7),
    seed: 23,
    child: child,
  );
}
```

Declare the Fluvie image/clip in that constructor subtree. A hidden media source
created only inside build or a FrameBuilder callback cannot be discovered before
mounting. The consumer adapter combines its crop/layout/border with this same
public interface; there is no second media collector or decoder. See the
[fork's wrapper contract](https://github.com/moisesaguiarjunior/fluvie/blob/main/docs/external-materials.md).

## Keep one frame clock

For a frame-dependent decoration, consume FrameBuilder's resolved progress/frame
and feed explicit values to PartPose or a bounded CraftPendulum sample. Keep
media children declared separately. Do not mount SceneEntrance in an externally
timed capture. Seed/palette stay constant across repeated frame requests.

The consumer's first crafted template retains its existing photo motion, caption
timing, frame pump, offline boundary, snapshot integrity, metadata stripping and
FFmpeg encode path. It exports the same video/cover/SRT/review/result artifacts.
Tests exercise real media discovery, deterministic raw frames and an actual CLI
export on a diagnostic canvas. This is not phone performance evidence or a
full-size throughput claim, and it is not adoption of private application art.
