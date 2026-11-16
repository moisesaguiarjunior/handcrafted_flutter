# Compatibility and evolution

## Tested baseline

Flutter 3.47.9 / Dart 3.13.7 is the current tested baseline and the declared
minimum. Higher versions may work but are not all certified by that constraint.
No lower SDK support is claimed without testing it.

| Environment or artifact | Evidence | Boundary |
| --- | --- | --- |
| Linux-hosted Flutter tests | CI format, strict analysis, package/example behavior tests | Not a Linux desktop shipping build or phone benchmark |
| Local Flutter test renderer | Real-font layout checks and deterministic PNG/frame captures | Not interactive browser or native-device approval |
| Web gallery | Release build/Pages deployment and focused Chrome widget tests | Automated browser behavior is covered; no full manual browser or phone certification; build emits a CupertinoIcons font warning |
| Android and iOS | No native/device result in this package | Not validated for release, performance or input latency |
| Windows/macOS/Linux desktop apps | No shipping desktop build matrix | Tests run on a desktop do not establish native app support |
| Wasm | Build's dry-run output only | No Wasm runtime compatibility claim |

## API policy before 1.0

Version 0.2.0 is an experimental source release; publish_to remains none. Source
consumers should pin a reviewed immutable Git tag/SHA and commit their lockfile.
We follow semantic versioning when making releases: incompatible API changes advance the pre-1.0 minor version;
patches document bug fixes, invalid-input handling and corrected layout behavior.
Avoid silently changing units, seeds, motion semantics or ownership contracts.
Document deprecations and migration examples before replacing an established API.
This policy does not promise an unannounced support lifetime or release schedule.

## Rendering and behavior guarantees

- A fixed recipe/seed/input is reproducible within the same package, Flutter
  engine, fonts, viewport, pixel ratio and rendering configuration. No cross-engine
  or cross-platform pixel identity is promised.
- Requested artwork size obeys Flutter constraints. Transform pivots and inverse
  hit testing use actual layout size. Host attachment mapping uses that same
  size; ancestor offsets and minimum targets remain host responsibilities.
- Text, actions, focus, semantics and accessibility remain native widgets.
  Viewport visibility must be supplied through active; background/TickerMode and
  reduced-motion handling remain the finite clock's own contract.
- Visual recipe changes require reviewed captures and a migration note. Golden
  updates are never a substitute for approval of a composition.

Version 0.1.0 removes the application-specific `authoredKiteTail` export. Keep
artwork in the consumer and pass progress from `SceneEntrance` to its painter.
Generic integration surfaces remain Path, palette, pose/progress and native
widgets. The example kite now builds its own simple waypoint curve; it is not an
exported preset or a physics API. This removal is an explicit pre-1.0 breaking
change; existing immutable pins continue to resolve their original source.

Pencil, chalk and wax extend CraftStrokeTool in v0.2.0. Update exhaustive
switches when adopting this version. Native solid-pen freehand and the original
pen/marker/brush branches retain their previous contracts. The v0.1.0 tag is
unchanged. See [0.2.0 migration](releases/0.2.0.md#upgrading-from-010).
