# Stuffed shapes: cloth and filling

[Try Stuffed shapes](https://moisesaguiarjunior.github.io/handcrafted_flutter/?study=pillows).
This first recipe composes the existing `CraftVolume`, `MaterialTextures`,
`CraftNap`, contour inset and prepared thread on original star, crescent and sun
cuts. It adds no new package export, textile enum, clock or cloth solver.

![Same cotton star with different filling, the same moon in three fabrics, and three original stuffed silhouettes](assets/stuffed-shapes.png)

## Research before naming a material

Sources were checked on 2026-11-20. They inform qualitative visual differences,
not fitted simulation constants. No photographs, sewing patterns, branding or
proprietary textile assets are copied into the renderer.

| Fabric | Evidence and visual direction | First recipe |
| --- | --- | --- |
| Woven cotton | A visible weave; relatively restrained stretch and a tauter stuffed face. A cotton quilting fabric is a useful baseline. | Existing cotton tile, pale seam and prepared rounded volume |
| Felt | Pressed/matted fiber rather than an interlaced weave; useful for small cut forms and visible hand sewing. | Existing felt tile, independently of the same filling profile |
| Short-pile plush / minky | A knit base with directional nap; pile and stretch influence the soft rounded result. Manufacturer examples span different pile heights/stretch. | **Matte short-pile study**, using existing CraftNap; not a claim to reproduce minky |
| Fleece | A brushed knit worth comparing for a more uniformly soft surface. | Candidate; not relabelled felt or minky |
| Velour / velvet-like pile | Directional pile and sheen would require a separate visual proof. | Deferred: current CraftNap is matte and supplies no specular finish |
| Linen | Existing woven texture is available for a drier decorative cushion. | Optional future composition; not one of the first three comparisons |

Primary references:

- [Choly Knight, Plush Sewing Basics](https://cholyknight.com/wp-content/uploads/2018/04/plush-sewing-basics-ebook.pdf), choosing fabrics and fabric anatomy: woven/knit/nonwoven distinctions and the effect of stretch on stuffed form.
- [Shannon Fabrics, Cuddle family](https://www.shannonfabrics.com/cuddle) and [low-pile technical tip sheet](https://www.shannonfabrics.com/download_patterns/Quilting-Cuddle-Tip-Sheet.pdf): different plush constructions should not be represented by one unqualified texture name.
- [Robert Kaufman, Kona cotton](https://www.robertkaufman.com/print/fabrics/kona_cotton/?rk_cleanup_done=1): a plain cotton quilting reference.
- [National Nonwovens, Arts & Education](https://www.nationalnonwovens.com/markets/arts-education/): felt as a distinct craft textile family.
- [Fairfield, fillers](https://www.fairfieldworld.com/shop-fillers/): soft-object filling includes multiple fiber and bead constructions. This proof does not infer a physical material from one slider.

The choice to start with cotton, felt and matte short pile is our implementation
judgment. It is not a manufacturer endorsement or physical textile certification.

## Filling is separate from fabric

`StuffedShapeGeometry` takes a caller-supplied closed path and `filling: 0..1`.
The value controls the existing rounded profile's nominal height (.6..18 source
pixels) and edge roll (3..14 pixels). Zero retains a thin sewn shell; it does not
make the fabric transparent. The same cut, inset, seed and sewing geometry remain.
The percentage displayed by the study is **visual fullness**, not fill mass,
density, pressure or a measured percentage of physical internal volume.

The narrower roll avoids using an overly broad distance field on star arms,
which produced angular ridges in an earlier local comparison. This is still an
approximate height field; complex narrow forms can show ridges. It is a starting
proof, not a solved soft-body surface. Low-fill wrinkling, fabric stretch, seam
tension, compression, rebounds and silhouette deformation are not implemented.

Fabric, color, thread visibility/pressure and light are paint-only choices over
the prepared geometry. Filling or cut changes prepare a new field outside paint.
Relighting does not rebuild it. Cotton and felt use existing grain; short pile
uses four prepared fiber paths with tinted, low-contrast highlights. The latter
has no fuzzy silhouette, long fur, anisotropic sheen or fabric displacement.

Sewing uses the actual contour inset, including the moon's concavity. Thread is
pale and gently irregular; compression controls existing puncture shading and
is not a physical stitch depth. This visible topstitch is decoration: real
turned-seam cotton/plush can hide the joining thread. The recipe does not claim
one visible seam style is the construction of every real textile.

## Geometry, ownership and use

The three presets live in the example; applications can supply another closed
cut under **all** existing volume/nap/inset/stitch limits. The source artboard is
112px, displayed independently of native labels/controls. Sharp or thin details
may lose an inset region; caller cuts must leave room for their chosen sewing.
The example keeps the existing 320-segment volume cap and 8192-candidate nap cap.

```dart
final geometry = StuffedShapeGeometry(myClosedCut, filling: .65);
final textures = MaterialTextures(seed: 71); // retained by the widget owner
geometry.paint(canvas, textures, sceneLight,
  fabric: PillowFabric.cotton, color: myOpaqueColor);
// When the owning scene ends:
textures.dispose();
```

`StuffedShapeGeometry`, `PillowFabric` and the silhouettes are example-owned,
not imports from `package:handcrafted_flutter/handcrafted_flutter.dart`.
Shading assumes an opaque substrate on a board; this does not export a transparent
sprite. Existing native image/mesh disposal and owner-scoped textures remain;
there is no global cache or animation controller. Decorative paint ignores
pointers and semantics; the dropdown, slider and switch are native widgets.

From the example directory:

```sh
flutter run -d chrome -t lib/main_gallery.dart
# Select Stuffed shapes, or open ?study=pillows on the hosted gallery.
flutter test test/stuffed_shapes_test.dart
flutter test tool/capture_pillows.dart
```

Captures use the actual study painter. Comparisons isolate filling on the same
cotton star and fabric on the same moon/color/filling/light. No existing golden
is regenerated. This demonstrates a runnable recipe; visual acceptance for an
application and performance on Android/iPhone remain separate gates. Do not
introduce fabric-specific physics or promote a pillow API before that evidence.
