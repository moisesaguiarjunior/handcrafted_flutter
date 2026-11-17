# Hosted publication readiness

The 0.3.0 manifest is a **publication candidate**, not an uploaded pub.dev
release. The v0.1.0 and v0.2.0 Git tags remain unchanged. Account/publisher
ownership and the first upload are separate decisions; this preparation does
not authenticate an account or configure automatic uploads.

## Archive, screenshots and source

`.pubignore` is the publication contract. It repeats generated-file exclusions
because it overrides `.gitignore`, and explicitly excludes local checkpoints.
Git's local `info/exclude` is not a publication boundary: the original dry-run
included WORKTREE.local.md despite Git ignoring that file locally. Both the
shared .gitignore and .pubignore now exclude local notes; Pub uses its own
explicit exclusions even when source control ignores the same file.

Full guides, capture tools and large visual atlases remain in the source
repository. Curated images live in `doc/screenshots/` and
are declared in pubspec metadata; no duplicate image bytes are maintained.
The library, core tests, runnable example and its licensed font/sprite assets
remain in the archive. Example-only fonts do not become runtime library assets.
The README uses absolute repository/media links so it also works on pub.dev.

The original dry-run produced an approximately 10 MB compressed archive with
two warnings: a fixed clipper2 version and the top-level docs directory. The
candidate uses ^0.0.3 with the same locked dependency, keeps docs Git-only and
produces an approximately 1 MB archive with no warnings. Actual size may change
as source or screenshots evolve. See [dependency notices](dependencies.md).

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

Flutter 3.47.9 / Dart 3.13.7 remains the declared/tested minimum. Broader SDK
support requires an actual compatibility matrix, not only lower constraints.
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

## Remaining owner steps for the first upload

The package lookup returned HTTP 404 on 2026-11-16; this is not a reservation of
`handcrafted_flutter`. Check again immediately before the first upload. There
is no application form or manual popularity threshold: the documented flow is
a validated package upload authenticated by its responsible Google account.

1. Approve the secondary composed screenshot against the runnable note. The
   flower stays first in the README and screenshot metadata by owner preference. The
   earlier Pana 160/160 result describes the reviewed source at that time; rerun
   archive/API checks on the final reviewed candidate. It is not a hosted score.
2. Choose the Google account that will own the first upload. A verified domain
   publisher is optional. If used, publish initially through the Google account,
   then transfer after domain verification; this is distinct from GitHub access.
3. Consolidate the candidate changelog, approve/tag the exact 0.3.0 source and
   run the interactive upload. Do not publish from a dirty or newer working tree.
4. Verify hosted installation in a fresh consumer, the README/screenshots/API
   pages and the server analysis. Only then advertise `^0.3.0` as available and
   consider GitHub trusted publishing for later versions.

The preparation requires no credentials in source, popularity evidence,
physical-device benchmark or automatic publisher workflow. Performance claims
still need their own measurements; Flutter's tested minimum remains explicit.
