# Six stitch families, one seam

`craftStitchPath` prepares thread geometry; `paintCraftStitch` renders it using
the same thread/puncture painter as the original running stitch. Existing
`runningStitchPath` and `paintRunningStitch` retain their public contract and
pixels. No native text or action is replaced by the decorative stitch.

| Kind | Surface geometry |
| --- | --- |
| running | Short visible spans, 55% of nominal pitch |
| backstitch | Contiguous curved segments with boundary punctures |
| blanket | Edge rail and transverse spoke on the selected side |
| chain | Closed lens-shaped links meeting at seam stations |
| cross | Two crossing threads per cell |
| basting | Long visible spans, 80% of nominal pitch |

These are illustrative surface patterns. Behind-fabric thread, true over/under
intersections, needle penetration, tension and displaced weave are not simulated.
Compression is directional shading. Punctures appear at generated contour ends;
a closed chain link meets at its shared anchor.

```dart
final seam = insetCraftPath(outline, distance: 20, sampleSpacing: 1);
canvas.save();
canvas.clipPath(outline);
paintCraftStitch(canvas, seam,
  kind: CraftStitchKind.chain, thread: const Color(0xFF82526A),
  pitch: 14, depth: 8, width: 1.5, compression: .7);
canvas.restore();
```

## Geometry and clearance

Pitch is nominal spacing (4..48 logical pixels); depth is transverse reach
(1..32). Chain/cross are centered on the seam. Blanket `side: 1` uses the
clockwise screen-space normal `(-tangent.dy, tangent.dx)`; `side: -1` reverses it.
Winding determines which direction is inward. The API does not infer the
substrate or hole topology: prepare the seam from the same silhouette, choose
the intended side and clip final ink. Reserve depth + four thread widths.

Backstitch, blanket, chain and cross distribute cells evenly along each contour,
including the closing interval. Closed chain/cross seams always use at least
three cells, including on small holes; these cells count toward the preflight
budget. Running/basting use arc-length spans with a
possible shorter final span. Empty/zero-length contours paint nothing. Prepare
outside paint when the seam/parameters remain unchanged; callers own geometry.

## Work limits

Inputs retain 32 contours / 8192 arc length and finite coordinates within +/-8192.
The new family API additionally bounds 1024 cells, 3072 output contours and
32768 output arc length. A dense/deep recipe can exceed the output limit even
when its source fits: rejection is explicit, never silent truncation. Thread
width is 0.5..8; compression 0..1; light is finite/nonzero. All validation precedes
painting. Shaded punctures can require several fills each; the work limits are
not a demonstrated phone frame budget. No cache, image or clock is added.

## Playground and image

From example/, run `flutter run -d chrome -t lib/main_stitches.dart` for native
pitch/depth/width/compression controls. Plates share the actual substrate cut and
prepare their seam at the effective layout size. Capture with
`flutter test tool/capture_stitches.dart`; output is
`build/stitches/stitch-families.png`, copied explicitly to docs/assets/.
This is a new composition proposal, not a golden update or approval to change
existing consumer screens.
