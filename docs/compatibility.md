# Compatibility and evolution

## Tested baseline

Flutter 3.47.9 / Dart 3.13.7 is the current tested baseline and the declared
minimum. Higher versions may work but are not all certified by that constraint.
No lower SDK support is claimed without testing it.

| Environment or artifact | Evidence | Boundary |
| --- | --- | --- |
| Linux-hosted Flutter tests | CI format, strict analysis, package/example behavior tests | Not a Linux desktop shipping build or phone benchmark |
| Local Flutter test renderer | Real-font layout checks and deterministic PNG/frame captures | Not interactive browser or native-device approval |
| Web showcase release compilation | `flutter build web --release --no-web-resources-cdn -t lib/main_showcase.dart` | Browser runtime remains unverified; build emits a CupertinoIcons font warning |
| Android and iOS | No native/device result in this package | Not validated for release, performance or input latency |
| Windows/macOS/Linux desktop apps | No shipping desktop build matrix | Tests run on a desktop do not establish native app support |
| Wasm | Build's dry-run output only | No Wasm runtime compatibility claim |

## API policy before 1.0

Version 0.0.1 is unreleased and experimental; publish_to remains none. Source
consumers should pin an immutable reviewed Git SHA. We follow semantic versioning
when making releases: incompatible API changes advance the pre-1.0 minor version;
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

`authoredKiteTail` is a named artwork preset preserved for the original consumer,
not the basis of a general motion/physics API. General integration surfaces remain
Path, palette, pose/progress and normal Flutter widgets. External animation and
shape tooling can be evaluated without building a parallel general sequencer.
