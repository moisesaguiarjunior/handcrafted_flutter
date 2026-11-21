# Hosted publication readiness

[Version 0.3.0 is published on pub.dev](https://pub.dev/packages/handcrafted_flutter),
following owner-authorized Google authentication on 2026-11-18. The hosted archive
matches the immutable v0.3.0 source tag. Previous tags remain unchanged. No
automatic publishing or domain-publisher transfer was configured.

Version 0.4.0 is a separate Git source release, with its
[own migration notes](releases/0.4.0.md); it is not a hosted upload. The original
0.3.0 archive and its tag remain unchanged. Publishing 0.4.0 to pub.dev requires
a separate owner-authorized upload and fresh hosted-consumer verification.

## Archive, screenshots and source

`.pubignore` is the publication contract. It repeats generated-file exclusions
because it overrides `.gitignore`, and explicitly excludes local checkpoints.
Git's local `info/exclude` is not a publication boundary: the original dry-run
included WORKTREE.local.md despite Git ignoring that file locally. Both the
shared .gitignore and .pubignore now exclude local notes; Pub uses its own
explicit exclusions even when source control ignores the same file.

Full guides, root/example capture tools and large visual atlases remain in the
source repository. `/example/tool/` capture entrypoints depend on the Git-only
root tools and example test helpers; run captures from a Git checkout, not the
hosted archive. The runnable gallery in `example/lib/` stays in the archive. Curated images live in `doc/screenshots/` and
are declared in pubspec metadata; no duplicate image bytes are maintained.
The library, core tests, runnable example and its licensed font/sprite assets
remain in the archive. Example-only fonts do not become runtime library assets.
The README uses absolute repository/media links so it also works on pub.dev.

The original dry-run produced an approximately 10 MB compressed archive with
two warnings: a fixed clipper2 version and the top-level docs directory. The
candidate uses ^0.0.3 with the same locked dependency, keeps docs Git-only and
produced an approximately 1 MB archive with no warnings at that earlier stage.
The 0.4.0 candidate currently reports a rounded 2 MB compressed payload with
zero warnings. These are historical/tool-reported rounded sizes, not byte-exact
measurements; actual size changes as source or screenshots evolve. See [dependency notices](dependencies.md).

## Reproduce the gates

```sh
bash tool/check.sh
python3 tool/check_publication.py
```

The publication check copies source into a disposable snapshot, without copying
real local notes. It adds synthetic root/nested local-checkpoint and generated
file probes, runs the real `dart pub publish --dry-run`, fails if a probe enters
the file list, and requires zero warnings. It also runs `dart doc --dry-run`
and requires zero documentation warnings/errors. The temporary snapshot is
removed. CI runs this after the existing behavior/analysis checks.

This is archive/documentation validation, not an upload gate tied to a publisher.
No credential, force-publish flag or upload command is executed by CI. Review the
exact candidate and file list again before an actual publication. A zero-warning
dry-run is not a guaranteed server score or a substitute for inspecting content.

For scoring, use the official [pana](https://github.com/dart-lang/pana) tool in a
separate snapshot: it can modify its input. A local score describes that tool,
SDK and source snapshot; pub.dev computes its own result after uploading.
Its repository check fetches the public default branch, so a local candidate
can still be scored against that branch's previous manifest. Recheck after the
reviewed candidate is integrated. Standard control-flow bracing is enforced
alongside the existing strict/API documentation rules; existing branches were
wrapped without changing their expressions or intended behavior.

## SDK, dependency and platform boundaries

Hosted 0.3.0 retains Flutter 3.47.9 / Dart 3.13.7. The 0.4.0 Git source declares
Flutter >=3.35.7 / Dart >=3.9.2, backed by the two-SDK CI matrix.
See [SDK evidence](sdk-compatibility.md); source compatibility is not inferred
from lower constraints alone.
The clipper2 range is ^0.0.3; locked hosted versions and license hashes remain
unchanged. Metadata adds a gallery homepage, documentation, issue tracker,
relevant topics and curated screenshots. Platform compatibility detected
from imports is distinct from physical-device behavior/performance evidence.

## First hosted release

1. Confirm the package name remains available and select the accountable Google
   account. A domain-verified publisher can be created if desired; the documented
   first-upload flow starts with a Google account, then transfers the package.
2. Review the exact 0.3.0 release source, CI, license inventory and publication
   file list. Preserve previous tags, create the matching reviewed source tag and
   include the migration/compatibility notes in the release.
3. Authenticate the selected account and perform the interactive `dart pub publish`
   only when the owner explicitly requests the upload. The first published
   version determines the initial uploader; published versions cannot be edited.
4. Confirm the hosted package/version/API documentation and score, then update
   the README from source-only installation to the actual hosted dependency.
   Add automated publishing only as a separate reviewed change after ownership
   is established; the current workflow intentionally only validates.

References: [Dart publishing guide](https://dart.dev/tools/pub/publishing),
[pubspec metadata](https://dart.dev/tools/pub/pubspec),
[package pages](https://dart.dev/tools/pub/writing-package-pages) and
[pub points](https://pub.dev/help/scoring).

## First hosted publication receipt

The exact v0.3.0 source was uploaded after the publication checker again passed
with a 2 MB compressed archive, zero publication warnings and zero Dartdoc
warnings/errors. The server accepted version 0.3.0. A fresh consumer resolved it
from `https://pub.dev`, without Git/path overrides, and exercised a native action
inside the published EVA surface. The downloaded archive hash was verified and all 139 archived files matched
the tagged source byte for byte. No credential or private product asset was
added to source or evidence.

The server generates hosted API documentation and package analysis asynchronously.
Their processing status is separate from successful upload, archive verification
and consumer installation; local scores are not advertised as hosted scores.

For subsequent releases, prepare and independently review a new immutable source
version, repeat these gates, then perform the authorized upload. Published version
bytes cannot be edited; documentation changes on main do not replace the hosted
0.3.0 archive. A verified publisher or trusted publishing can be a separate change.

The Android debug smoke remains reproducible with `tool/check_android.py`; it
does not measure phone performance. The interactive hosted-browser visit remains
incomplete after the browser-control connection failed; successful builds, HTTP
and Chrome widget tests do not replace that visit.
