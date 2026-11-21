# SDK compatibility lanes

| Source/version | Flutter / Dart floor | Evidence |
| --- | --- | --- |
| Published 0.3.0 and v0.3.0 | 3.47.9 / 3.13.7 | Immutable published constraints and hosted consumer smoke |
| 0.4.0 Git source | 3.35.7 / 3.9.2 | CI at 3.35.7 and 3.47.9: library/example analysis and tests, focused Chrome resource/compositing regressions, release web gallery build |

The older SDK is a chosen tested floor, not proof of the earliest possible engine.
Successful endpoint builds do not certify every intermediate patch, native
platform, physical-device performance or cross-engine pixel identity.

## Reproduce

Use a separate official Flutter checkout/tag. Do not replace the host's installed
SDK or run an older SDK in a consumer's working tree just to probe compatibility.
In a disposable package checkout, put that SDK's Flutter executable on PATH and
run the same script as CI:

```sh
bash tool/check_compatibility.sh
```

The committed locks are the 3.47.9 baseline. `flutter pub get --enforce-lockfile`
and the full format/analyze/test/publication gates remain enforced there. The
compatibility matrix re-resolves each SDK's own pinned flutter_test/sky_engine
versions in disposable CI checkouts; it does not overwrite the release locks.
Fresh consumers on the older SDK should use ordinary resolution, then commit
their own application lockfile. Formatting is checked on the baseline SDK.

## Compatibility bridges and failure evidence

The initial older-SDK probe failed on `TickerMode.valuesOf` and the test-only
`ui.Tristate` representation. The source uses the shared boolean `TickerMode.of`
accessor for the enabled flag, with exactly one documented suppression for its
newer-SDK deprecation. It still establishes the inherited dependency and keeps
the same explicit pause/resume, reduced-motion and lifecycle policy.

Semantic tests use a narrow test-only adapter to Flutter's containsSemantics
matcher, with explicit selected and enabled-state checks. That one adapter also
documents its newer-SDK deprecation; there is no global lint suppression. The sharing test taps its native label and still
verifies the clipboard URL and route change; it does not depend on whether a
framework version uses a private TextButton.icon subclass.

No texture painter, geometry, seed or animation clock is replaced. Published
version bytes and old tags remain unchanged; wider compatibility reaches hosted
consumers only after a separately authorized new release.
