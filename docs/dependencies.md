# Dependencies

Direct dependencies are Flutter (BSD-3-Clause SDK) and clipper2 ^0.0.3
(locked at 0.0.3, BSL-1.0);
flutter_test is a developer SDK dependency. flutter_lints ^6.0.0 and its
transitive lints package are developer-only BSD-3-Clause analysis dependencies;
they do not become runtime dependencies. The lockfiles record resolved transitive
dependencies. The locked hosted package LICENSE inventory is recorded in
[dependency-license-audit.md](dependency-license-audit.md); future lockfile changes
require rechecking it.
Clipper2 supplies polygon union/offset geometry; its Boost license remains
separate from this project's MIT license. Its source is resolved by pub rather
than vendored. See https://pub.dev/packages/clipper2 and the locked license hash.
No third-party material, animation or physics package has been added.

## Example-only assets and developer tools

- Inter: SIL OFL 1.1, copyright 2020 The Inter Project Authors. Original license
  bundled at example/assets/fonts/OFL-Inter.txt.
- Caveat: SIL OFL 1.1, copyright 2014 The Caveat Project Authors. Original license
  bundled at example/assets/fonts/OFL-Caveat.txt.
- FFmpeg: optional external developer executable for GIF encoding, not a bundled
  dependency. Its build/license is chosen by the developer; no FFmpeg code is
  distributed by this package. The images contain only synthetic Flutter content.
