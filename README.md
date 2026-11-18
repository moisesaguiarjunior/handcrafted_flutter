# handcrafted_flutter

![A stitched cognac leather tag pressed with the word handcrafted, tied with a twisted cord](https://raw.githubusercontent.com/moisesaguiarjunior/handcrafted_flutter/main/docs/assets/leather-mark.png)

**Give your Flutter widgets a handmade surface.**

[![Checks](https://github.com/moisesaguiarjunior/handcrafted_flutter/actions/workflows/check.yml/badge.svg)](https://github.com/moisesaguiarjunior/handcrafted_flutter/actions/workflows/check.yml)
[![Library coverage](https://codecov.io/gh/moisesaguiarjunior/handcrafted_flutter/branch/main/graph/badge.svg)](https://codecov.io/gh/moisesaguiarjunior/handcrafted_flutter)

[Explore the live gallery](https://moisesaguiarjunior.github.io/handcrafted_flutter/) ·
[Run locally](https://github.com/moisesaguiarjunior/handcrafted_flutter/blob/main/docs/live-gallery.md) ·
[Building blocks](#building-blocks)

![Layered rose petals and a blue-green wash on textured paper](https://raw.githubusercontent.com/moisesaguiarjunior/handcrafted_flutter/main/doc/screenshots/watercolor-hero.png)

Seeded paper, linen, twill, felt, wood, cotton, velvety nap, leather and EVA
textures, six contour-following stitch families, organic contours, watercolor
pigment, relief, cord/ribbon bands and composable moving parts for Flutter.
The leather tag above is itself a composition of those parts: leather grain, a
contour seam with recessed punctures, a raised edge, a twisted cord and native
pressed lettering. [See how it is built](https://github.com/moisesaguiarjunior/handcrafted_flutter/blob/main/example/lib/brand_mark.dart).

**Text remains text.** Buttons, fields and choices keep native focus, actions,
semantics and text scaling; the material is painted around them.
[How accessibility is preserved](#accessible-by-construction).

Experimental, [MIT](https://github.com/moisesaguiarjunior/handcrafted_flutter/blob/main/LICENSE)-licensed and tested on Flutter 3.47.9 / Dart 3.13.7
([compatibility](https://github.com/moisesaguiarjunior/handcrafted_flutter/blob/main/docs/compatibility.md) · [installation](#installation)).

## Write a postcard you can send

[![An editable watercolor postcard with a stamp, postmark, contour stitching and native controls](https://raw.githubusercontent.com/moisesaguiarjunior/handcrafted_flutter/main/doc/screenshots/painted-note.png)](https://moisesaguiarjunior.github.io/handcrafted_flutter/?study=cover)

Write the message, change who it goes to, remove the stitched edge and send it
in the [live composition](https://moisesaguiarjunior.github.io/handcrafted_flutter/?study=cover).
The paper, coastal watercolor, stamp, postmark and pressed heading are
decoration; the fields, choice and action are real Flutter widgets. [See the runnable composition](https://github.com/moisesaguiarjunior/handcrafted_flutter/blob/main/example/lib/painted_note.dart).

## Stitched by hand

![Running, back, blanket, chain, cross and basting stitches, each on its own cloth](https://raw.githubusercontent.com/moisesaguiarjunior/handcrafted_flutter/main/docs/assets/stitch-families.png)

Choose a thread pattern while keeping the same seam, substrate and native controls.
`insetCraftPath` follows the real cut — concavities, holes and narrow necks
included — and `paintCraftStitch` lays running, back, blanket, chain, cross or
basting stitches along it with illustrative puncture shading. Running stitches
can be seeded slightly irregular, like work done by hand.
[Stitch geometry, clearance and playground](https://github.com/moisesaguiarjunior/handcrafted_flutter/blob/main/docs/stitch-families.md) ·
[Try the six stitch families](https://moisesaguiarjunior.github.io/handcrafted_flutter/?study=stitches).

![Satin-stitched leaves filling in, stitch by stitch, inside a wooden hoop](https://raw.githubusercontent.com/moisesaguiarjunior/handcrafted_flutter/main/docs/assets/embroidery-reveal.gif)

Drive any thread with explicit progress: a botanical sprig fills in stitch by
stitch, a missing stitch completes, or a loose strand passes above and beneath
the cloth. [Try the embroidery study](https://moisesaguiarjunior.github.io/handcrafted_flutter/?study=embroidery) ·
[Explicit-progress paint and thread recipes](https://github.com/moisesaguiarjunior/handcrafted_flutter/blob/main/docs/living-materials.md).

## Watercolor, on paper and in motion

![Overlapping pigment, a botanical painting and a paper cutout](https://raw.githubusercontent.com/moisesaguiarjunior/handcrafted_flutter/main/docs/assets/watercolor-atlas.png)

Layer puddles, blooms, drying lines and deposits inside your own closed shape.
Supply pigment, companion and paper colors; the silhouette and its holes remain
unchanged. `paintWatercolor` composes with the existing paper grain. This is a
seeded visual approximation of watercolor.

![A wet blue brush meets a dry or wet pink wash](https://raw.githubusercontent.com/moisesaguiarjunior/handcrafted_flutter/main/docs/assets/watercolor-reaction.gif)

Start at the first brush contact, follow a moving brush, or compare blue over a
pink base. The live study lets you pause, reverse by scrubbing and adjust the
base wetness. Pigment fronts advance unevenly instead of scaling a circular
wipe. [Try paint spreading](https://moisesaguiarjunior.github.io/handcrafted_flutter/?study=spreading).
These are bounded visual approximations, not a fluid or spectral pigment solver.

![A visible brush dragging a continuous blue watercolor stroke](https://raw.githubusercontent.com/moisesaguiarjunior/handcrafted_flutter/main/docs/assets/brush-drag.gif)

**First touch** grows from one contact. **Brush stroke** drags a continuous wash
along a curve; choose whether the brush is visible and lifts away at the end.

## Nine materials, pressed and raised

![Twill, linen, felt, paper, wood, leather, EVA foam, cotton and velvety nap swatches](https://raw.githubusercontent.com/moisesaguiarjunior/handcrafted_flutter/main/docs/assets/materials-atlas.png)

Every material takes an explicit color, grain scale and seed, and is rasterized
once into an owner-scoped tile. Pebbled leather, fine-pore EVA, compact cotton
and velvety nap join the classic paper, linen, twill, felt and wood.

![Cotton, velvety and felt pockets sewn with irregular running stitches, a chalk garden and a folded paper pinwheel](https://raw.githubusercontent.com/moisesaguiarjunior/handcrafted_flutter/main/docs/assets/soft-craft-materials.png)

Fine cotton and velvety cloth compose with optional irregular sewing and local
puncture gathering. Chalk can leave a denser broken mark; satin paper catches
light on folded shapes. [Soft craft recipes](https://github.com/moisesaguiarjunior/handcrafted_flutter/blob/main/docs/soft-craft-materials.md)
· [Try cloth, chalk & folds](https://moisesaguiarjunior.github.io/handcrafted_flutter/?study=softCraft).

![A whale, a house and a snail pressed into indigo twill, flax linen and clay felt](https://raw.githubusercontent.com/moisesaguiarjunior/handcrafted_flutter/main/docs/assets/impressions-atlas.png)

![A leather journal with a pressed ginkgo leaf, a raised balloon on twill and a letterpress thank-you card](https://raw.githubusercontent.com/moisesaguiarjunior/handcrafted_flutter/main/doc/screenshots/relief-objects.png)

Layered motifs press into or rise from the material: a tooled leather journal
with a stitched border, a raised balloon whose seams are pressed, and debossed
letterpress peaks. Each relief has its own shape and edge lighting. Substrate grain stays visible;
pressed lettering uses native `CraftReliefText`. These are shading approximations.
See the [implemented catalog](https://github.com/moisesaguiarjunior/handcrafted_flutter/blob/main/docs/materials-and-motion.md) for API/examples and
what remains planned.

![Cardstock, kraft, recycled, corrugated, watercolor and laid paper recipes](https://raw.githubusercontent.com/moisesaguiarjunior/handcrafted_flutter/main/docs/assets/paper-recipes.png)

Compose the existing paper grain with fiber, fluted, pitted or laid finishes,
then choose clean, torn, handmade or postage edges independently. These are
visual recipes; letterhead stays real text over a substrate. See
[paper recipes and controls](https://github.com/moisesaguiarjunior/handcrafted_flutter/blob/main/docs/paper-recipes.md).

## Cut EVA, different impressions

![Pebbled, mottled, grooved and crosshatched original foam cuts](https://raw.githubusercontent.com/moisesaguiarjunior/handcrafted_flutter/main/docs/assets/foam-finishes.png)

Keep the substrate, finish and layer lighting independent. Use fine-pore EVA
with seeded impressions, then compose raised cuts around native content.
The study also compares raised cream yarn with pressed ochre marks on layered
foam, using the same seam geometry.
[Foam recipes](https://github.com/moisesaguiarjunior/handcrafted_flutter/blob/main/docs/eva-foam.md) ·
[Try the finishes](https://moisesaguiarjunior.github.io/handcrafted_flutter/?study=foam).

## Cord, ribbon and embroidered lines

![A braided three-color cord, a ribbon and an embroidered border, each following its cut](https://raw.githubusercontent.com/moisesaguiarjunior/handcrafted_flutter/main/docs/assets/colored-cord.png)

Draw raised bands over textures or follow the actual cut with an optional edge gap.
Give a rope two to six strand colors: two twist, three or more braid, and each
yarn keeps its own volume and crossing depth.

![Two twisted strands, three braided strands and natural cotton tones](https://raw.githubusercontent.com/moisesaguiarjunior/handcrafted_flutter/main/docs/assets/braided-cord-detail.png)

[API and runnable playground](https://github.com/moisesaguiarjunior/handcrafted_flutter/blob/main/docs/cord-ribbon-embroidery.md).

## Curves, ink and completed paths

![Curved line playground with native controls](https://raw.githubusercontent.com/moisesaguiarjunior/handcrafted_flutter/main/docs/assets/stroke-playground.png)

Build a smooth route through waypoints, or supply your own Flutter `Path`. Choose
continuous, dashed or dotted ink independently of pen, broad marker or brush
treatment, or pencil, chalk and wax deposits. Explicit progress reveals the line by distance without creating a
clock. Paint a quiet track behind a solid prefix to show a completed route.

Run `flutter run -d chrome -t lib/main_strokes.dart` from `example/`.
See [drawing recipes and examples](https://github.com/moisesaguiarjunior/handcrafted_flutter/blob/main/docs/drawing-strokes.md).

## Body, tail and tether

![A quick paper kite gust settles while a watercolor balloon continues its slower drift](https://raw.githubusercontent.com/moisesaguiarjunior/handcrafted_flutter/main/docs/assets/motion-stage.gif)

Motion examples use original example-owned geometry and supplied progress.
The kite responds to quick gusts; the balloon rises and drifts more slowly,
with its own rotation and softer tether. The two share a timeline, not a rhythm.

Move the kite's parent part while its ribbon tail keeps its own progress. Hold
the body still to animate only the tail, or combine both. The balloon's string
follows its transformed knot. The original showcase also includes hanging
paper/felt pieces with native controls. These are finite authored examples;
the new clips stop at their final pose; use the live controls to replay.

## One set of controls, your material themes

![The same picnic invitation and reply form in paper and cloth themes](https://raw.githubusercontent.com/moisesaguiarjunior/handcrafted_flutter/main/doc/screenshots/material-vocabulary.png)

`CraftTheme` supplies host-owned material roles; `CraftPanel`, `CraftButton` and
`CraftChoice` keep text, focus, actions and selected state native. Switch the
material without replacing the form or its contents: the reply you are typing,
your choice and its focus survive the switch. Selected choices show a drawn
check mark, so selection never depends on color alone.
[Try both themes](https://moisesaguiarjunior.github.io/handcrafted_flutter/?study=vocabulary)
· [Use the components](https://github.com/moisesaguiarjunior/handcrafted_flutter/blob/main/docs/material-vocabulary.md).
`CraftHeading` adds themed raised/inset lettering with native heading semantics.

## Paper behind a real control

```dart
import 'package:flutter/material.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

CraftSurface(
  material: CraftMaterial.paper,
  color: const Color(0xFFFFFDF8),
  shape: const CraftOutline.pigment(seed: 23, broad: true),
  child: TextButton(
    onPressed: openCollection,
    child: const Text('Open collection'),
  ),
)
```

Give the surface normal Flutter constraints. An optional `outline` supplies one
cached silhouette for painting, clipping and child hit testing. Prefer a value
`shape` recipe to retain the cache across equivalent rebuilds. The host supplies
the content padding. `insetCraftPath` derives a bounded polygonal seam from a
closed silhouette, respecting concavities and holes. See [contour seams](https://github.com/moisesaguiarjunior/handcrafted_flutter/blob/main/docs/contour-seams.md).

## Accessible by construction

- **Native widgets stay native.** Materials paint behind or around real Flutter
  widgets; labels, fields, focus order and semantics are not baked into images.
- **Selection is not color alone.** `CraftChoice` draws a check mark beside the
  label, without depending on an icon font.
- **Form labels and content keep their size.** The example forms reflow at large
  text scales. Decorative artwork, including the wordmark, scales independently
  to fit its available space; it is not a substitute for readable UI text.
- **Motion is finite and respectful.** `SceneEntrance` settles immediately when
  the platform asks for reduced motion and pauses in the background.

An [experience-frame recipe](https://github.com/moisesaguiarjunior/handcrafted_flutter/blob/main/docs/experience-frame.md) combines imported crops,
a mapped 48px lid action, a native form and a pinned footer. Try narrow screens,
large text and the keyboard in the [live frame](https://moisesaguiarjunior.github.io/handcrafted_flutter/?study=experience).
It is an example-first composition, with application state left to the host.

## Run the examples

![A tooled leather journal, a watercolor card with a native button and an embroidered bookmark](https://raw.githubusercontent.com/moisesaguiarjunior/handcrafted_flutter/main/docs/assets/material-cover.png)

Every image in this README is captured from a runnable composition.

```sh
gh repo clone moisesaguiarjunior/handcrafted_flutter
cd handcrafted_flutter
flutter pub get --enforce-lockfile
cd example
flutter run -d chrome -t lib/main_gallery.dart
```

- [Living paint and embroidery](https://github.com/moisesaguiarjunior/handcrafted_flutter/blob/main/docs/living-materials.md): first touch, moving brush, pink/blue layers and an embroidered sprig.
- [Live gallery and deployment](https://github.com/moisesaguiarjunior/handcrafted_flutter/blob/main/docs/live-gallery.md): one navigation shell over existing studies; run `lib/main_gallery.dart`.
- [Cover and relief gallery](https://github.com/moisesaguiarjunior/handcrafted_flutter/blob/main/example/lib/main_cover.dart): the real compositions behind the README images.
- [Cord/ribbon playground](https://github.com/moisesaguiarjunior/handcrafted_flutter/blob/main/docs/cord-ribbon-embroidery.md): open paths and contour gaps; run `lib/main_trims.dart`.
- [Gravity/wind comparison](https://github.com/moisesaguiarjunior/handcrafted_flutter/blob/main/docs/bounded-physics.md): supplied time and realistic/cartoon response; run `lib/main_physics.dart`.
- [Material and motion atlas](https://github.com/moisesaguiarjunior/handcrafted_flutter/blob/main/example/lib/main_atlas.dart): four sections with live controls.
- [Original showcase](https://github.com/moisesaguiarjunior/handcrafted_flutter/blob/main/example/lib/main_showcase.dart): keepsake card, hanging pieces and kite.
- [Material playground](https://github.com/moisesaguiarjunior/handcrafted_flutter/blob/main/example/lib/main.dart): seed, scale, grain and lighting.
- [Shared compositions](https://github.com/moisesaguiarjunior/handcrafted_flutter/blob/main/example/lib/use_cases.dart): complete runnable widget code.
- [Bounded effects](https://github.com/moisesaguiarjunior/handcrafted_flutter/blob/main/docs/bounded-effects.md): a mapped pour, droplets and light; run `lib/main_effects.dart`.
- [Rotary recipe](https://github.com/moisesaguiarjunior/handcrafted_flutter/blob/main/docs/rotary-control.md): native stepping and retargetable wooden artwork; run `lib/main_dial.dart`.
- [Imported artwork recipe](https://github.com/moisesaguiarjunior/handcrafted_flutter/blob/main/docs/imported-layers.md): source crops, hinges and attached thread; run `lib/main_scenes.dart`.
- [Rendering budget](https://github.com/moisesaguiarjunior/handcrafted_flutter/blob/main/docs/rendering-budget.md): bounded stress scene and runtime UI/raster timing; run `lib/main_budget.dart` in profile mode.
- [Contour seam study](https://github.com/moisesaguiarjunior/handcrafted_flutter/blob/main/docs/contour-seams.md): holes, concavities and disappearing necks; run `lib/main_seams.dart`.
- [Paper recipes](https://github.com/moisesaguiarjunior/handcrafted_flutter/blob/main/docs/paper-recipes.md): stock, edge and finish controls plus native letterhead; run `lib/main_papers.dart`.

Use a local path dependency during development, or pin an immutable Git commit
in an application. Keep source-access credentials outside code and URLs.

## Building blocks

| API | Responsibility |
| --- | --- |
| `CraftMaterial`, `MaterialTextures` | Seeded material tiles and explicitly owned raster resources |
| `CraftSurface` | Material behind native Flutter widgets |
| `CraftTheme`, `CraftPanel`, `CraftButton`, `CraftChoice`, `CraftHeading` | Themed material roles around native panels, actions, choices and headings |
| `paintFoamFinish`, `FoamFinish` | Pebbled, mottled, grooved and crosshatched EVA impressions |
| `paintWatercolor`, `paintWatercolorSpread` | Layered pigment and an explicitly progressed organic wet front |
| `paintCraftRelief`, `CraftReliefText` | Directional motif shading and native raised/inset lettering |
| `pigmentOutline` | Reproducible organic contours |
| `CraftOutline` | Value-based rectangle, rounded rectangle and organic recipes |
| `craftCurveThrough`, `trimCraftPath` | Curved waypoints and explicit arc-length reveal |
| `CraftStrokeStyle`, `paintCraftStroke` | Continuous, dashed or dotted ink and pencil/chalk/wax deposits |
| `paintCraftFreehand` | Bounded solid-pen input by points/strokes, including long scribbles and taps |
| `craftStitchPath`, `paintCraftStitch`, `CraftStitchFrame` | Prepared thread, visible anchors, explicit progress and a travelling tip |
| `runningStitchPath`, `paintRunningStitch` | Arc-length stitches and illustrative puncture shading |
| `insetCraftPath` | Bounded winding-aware polygonal inset of a closed silhouette |
| `paperOutline`, `CraftOutline.paper` | Clean, torn, handmade and postage silhouettes |
| `paintPaperFinish`, `paintPaperEdgeFibers` | Clipped stock finish marks and independent fiber fringe |
| `PartPose`, `CraftPart` | Shared paint, input and attachment transforms |
| `CraftImagePart` | Image crop in an artboard rect, optional hinge/pose, native overlay and attachment mapping |
| `paintCraftTrim`, `contourTrimPath` | Cord/ribbon/embroidered bands and nominal edge clearance |
| `CraftPendulum` | Bounded gravity/wind samples with direct or cartoon response, no clock |
| `SceneEntrance` | Finite lifecycle-aware entrance progress |

`SceneEntrance.active` is supplied by the host's viewport or route policy.
Background/TickerMode suspension and reduced motion are handled by the clock.
Pivots use the actual constrained size; attachment mapping must use that same
size. Reserve parent space for moving touch targets.

Actor examples use authored motion. `CraftPendulum` separately models one rigid
suspended mass with constant gravity/wind; flexible cloth/rope, shared wind fields
and fluid dynamics remain future work. Punctures are shading; textures are cached
per surface. Insets approximate curves with polygons and have explicit work limits.
Glyph shading uses bounded offscreen layers;
phone performance remains unmeasured.

## Installation

Once a hosted version is available on [pub.dev](https://pub.dev/packages/handcrafted_flutter), add it with:

```sh
flutter pub add handcrafted_flutter
```

Git source baseline: [v0.2.0](https://github.com/moisesaguiarjunior/handcrafted_flutter/releases/tag/v0.2.0)
([release notes and migration](https://github.com/moisesaguiarjunior/handcrafted_flutter/blob/main/docs/releases/0.2.0.md)); the examples in this
README follow the current source branch (0.3.0). See
[publication status and process](https://github.com/moisesaguiarjunior/handcrafted_flutter/blob/main/docs/publishing.md).

For source distribution, use an immutable reviewed tag or SHA. The v0.2.0 tag
below is the previous source baseline; 0.3.0 additions require their reviewed
source until the hosted release is available.

### Use the tagged source

```yaml
dependencies:
  handcrafted_flutter:
    git:
      url: https://github.com/moisesaguiarjunior/handcrafted_flutter.git
      ref: v0.2.0
```

Keep your application's lockfile committed. Existing `v0.1.0` pins are unchanged;
review the [migration note](https://github.com/moisesaguiarjunior/handcrafted_flutter/blob/main/docs/releases/0.2.0.md#upgrading-from-010) before updating.

## Development

Clone the source repository for full guides, tests and capture tools. The hosted
archive retains the library, runnable example and selected screenshots.

```sh
bash tool/check.sh
python3 tool/check_publication.py
flutter test tool/capture_brand.dart
flutter test tool/capture_cover.dart
flutter test tool/capture_showcase.dart
bash tool/encode_showcase.sh
flutter test tool/capture_motion.dart
bash tool/encode_motion.sh
flutter test tool/capture_atlas.dart
bash tool/encode_atlas.sh
```

Captures are explicit and do not regenerate goldens. See the [capture recipe](https://github.com/moisesaguiarjunior/handcrafted_flutter/blob/main/docs/showcase.md),
[reuse map](https://github.com/moisesaguiarjunior/handcrafted_flutter/blob/main/docs/reuse.md), [contribution rules](https://github.com/moisesaguiarjunior/handcrafted_flutter/blob/main/CONTRIBUTING.md) and
[documentation index](https://github.com/moisesaguiarjunior/handcrafted_flutter/blob/main/docs/README.md).

Follow the [delivery tasklist](https://github.com/moisesaguiarjunior/handcrafted_flutter/blob/main/docs/tasklist.md) and
[independent review record](https://github.com/moisesaguiarjunior/handcrafted_flutter/blob/main/docs/reviews/local-review-record.md).

See the [material and movement roadmap](https://github.com/moisesaguiarjunior/handcrafted_flutter/blob/main/docs/roadmap.md) for current/planned
capabilities and [integration contracts](https://github.com/moisesaguiarjunior/handcrafted_flutter/blob/main/docs/integration.md) for Fluvie and
Social Studio adapter boundaries. The [executable consumer integration](https://github.com/moisesaguiarjunior/handcrafted_flutter/blob/main/docs/consumer-video-integration.md)
shows versioned material arguments, declared media and the existing video export path.

## License

Code and original documentation/media: [MIT](https://github.com/moisesaguiarjunior/handcrafted_flutter/blob/main/LICENSE). Clipper2 retains BSL-1.0.
Example-only Inter and
Caveat fonts retain their bundled SIL OFL 1.1 notices. See
[dependency notices](https://github.com/moisesaguiarjunior/handcrafted_flutter/blob/main/docs/dependencies.md) and [provenance](https://github.com/moisesaguiarjunior/handcrafted_flutter/blob/main/docs/provenance.md).
