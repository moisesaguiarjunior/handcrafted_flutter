# One lamp, three materials

[Open the light studio](https://moisesaguiarjunior.github.io/handcrafted_flutter/?study=light).
Drag the lamp in the board plane; use the height slider to bring it closer to
or farther from the pieces. Choose clay, EVA or paper, change its silhouette and
turn it. The lamp stays in scene space.

The recipe lives in `example/lib/spatial_light_study.dart`. It uses existing
CraftLight, CraftVolume and MaterialTextures; no new library API is required.
Clay is a rounded volume with subdued grain, EVA a matte thin sheet and paper a
thinner sheet with paper grain. These are visual recipes, not measured materials.

StudioLamp computes a direction from the same scene-space source to each piece
center, then applies bounded distance falloff and `inLocalSpace(rotation)` to
both shading and shadow. All coordinates use the same artboard units. This is
per-piece directional sampling, not per-pixel point lighting. There are no mutual
shadows, perspective transforms or physically calibrated light units. Prepared
normals and tiles survive lamp/pose changes; shape selection reuses prepared cuts.

The drag handle has a 48px target. Named native sliders provide XY, height and
rotation without requiring a drag gesture. Native choices expose selection. All
movement follows input; no timer, looping motion or additional clock is created.

## Android smoke

Start an Android emulator, obtain its selector with `flutter devices`, then run:

```sh
python3 tool/check_android.py --device <android-selector>
```

The script generates a disposable Android host from Flutter's template, copies
the actual example and licensed assets, and runs light/paint/thread checks with
the integration_test SDK. It does not launch or stop an emulator. Temporary host
files are removed on exit. Android build tools and accepted SDK licenses must
already be installed. This smoke does not establish phone performance or physical
screen-reader behavior. Keep device selectors and personal paths out of reports.
