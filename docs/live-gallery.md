# Live material gallery

The gallery uses the same widgets as the standalone examples and documentation
captures. Open a study from the native navigation drawer: materials/relief, paper,
stitch families, cord/ribbon, watercolor, independent motion, gravity/wind, ink,
imported artwork, rotary control or pour/light. Only the selected study is
mounted; leaving a page disposes its textures and finite decorative clock.
This does not add automatic viewport detection to SceneEntrance.

Run locally from example/:

```sh
flutter run -d chrome -t lib/main_gallery.dart
```

The hosted path is
https://moisesaguiarjunior.github.io/handcrafted_flutter/ .
Use `?study=stitches`, `?study=motion` or another GalleryStudy enum name to choose
an initial study. Unknown names open the cover. The drawer changes local study
state; it is not an application router or a serialized project/job schema.

## Build and deployment

```sh
flutter build web --release --no-web-resources-cdn \
  --base-href /handcrafted_flutter/ -t lib/main_gallery.dart
```

`.github/workflows/gallery.yml` builds pull requests without deployment access.
Reviewed main pushes (or a manual workflow dispatch on main) upload the web
artifact and deploy through GitHub Pages. Deployment receives pages/id-token
permissions only in its own job; build retains contents-read. Configure the
repository Pages source as GitHub Actions. No credentials belong in the app.
CI format/analysis/behavior checks remain a separate workflow and manual merge
gate. A successful build does not prove successful publication: check the Pages
job and actual hosted URL after integration.

The build bundles the example's existing licensed fonts and original synthetic
cabinet artwork. `--no-web-resources-cdn` keeps Flutter web resources local to
the deployed bundle. Compilation may emit the existing unused CupertinoIcons
font warning. Browser runtime, accessibility and device performance must be
reported separately from compilation; sampled PNG/GIF export is not profiling.

## Motion media

`flutter test tool/capture_motion.dart` captures 49 supplied progress values from
0 to 1 plus a static pose using MotionAtlas. The atlas compares moving the kite
body, moving only its tail, combining both and moving a balloon with an attached
tether. All actor geometry belongs to the example; no consumer art preset is
exported by the package. No clock is started during capture.

`bash tool/encode_motion.sh` writes docs/assets/motion-atlas.png and .gif from
those frames. GIF encoding is 12 fps, 128 colors; its repeating loop replays a
finite authored interval rather than simulating wind or continuous motion.
The dedicated command does not overwrite material or relief captures.
The complete atlas capture reuses the same motion capture function.
