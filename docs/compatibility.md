# Compatibility and evolution

## Tested baseline

The unreleased 0.3.1 source candidate is tested on Flutter 3.35.7 / Dart 3.9.2
and Flutter 3.47.9 / Dart 3.13.7. Its declared floor is the older tested pair;
intermediate/newer versions are not individually certified by that constraint.
[Matrix and reproducible commands](sdk-compatibility.md).

Published 0.3.0 and tag v0.3.0 retain Flutter >=3.47.9 / Dart >=3.13.7.
The wider floor requires the reviewed 0.3.1 source until a new hosted release is
explicitly published. No old tag or hosted archive is rewritten.

| Environment or artifact | Evidence | Boundary |
| --- | --- | --- |
| Linux-hosted Flutter tests | CI format, strict analysis, package/example behavior tests | Not a Linux desktop shipping build or phone benchmark |
| Local Flutter test renderer | Real-font layout checks and deterministic PNG/frame captures | Not interactive browser or native-device approval |
| Web gallery | Release build/Pages deployment and focused Chrome widget tests | Automated browser behavior is covered; no full manual browser or phone certification; build emits a CupertinoIcons font warning |
| Android emulator | Debug integration smoke of light/paint/thread gallery, generated native host | Not a physical-device benchmark, release-mode validation or input-latency measurement |
| iOS | No native/device result in this package | Not validated for release, performance or input latency |
| Windows/macOS/Linux desktop apps | No shipping desktop build matrix | Tests run on a desktop do not establish native app support |
| Wasm | Build's dry-run output only | No Wasm runtime compatibility claim |

## API policy before 1.0

Version 0.3.0 was published to pub.dev on 2026-11-18 and verified in a fresh
hosted consumer. Its archive matches the immutable v0.3.0 source tag; older tags
remain unchanged. Commit the application lockfile; Git consumers should retain
immutable tags or SHAs.
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

Version 0.3.0 adds CraftMaterial.eva, cotton, suede and leather. Exhaustive
material switches need the corresponding cases; previous material indices and
seeded output stay stable. Rope strandColors is optional and single-color behavior is unchanged.


The unreleased whole-face padding study appends `CraftVolumeProfile.padded`.
Exhaustive profile switches need this case, so it is reserved for a future minor
release rather than the SDK-only patch candidate. Earlier enum indices, profiles,
seeds and immutable hosted tags remain unchanged.
