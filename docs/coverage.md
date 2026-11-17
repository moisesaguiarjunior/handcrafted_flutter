# Library coverage

`bash tool/check.sh` runs the root behavior tests with `flutter test --coverage`.
The actual LCOV report is `coverage/lcov.info`; example tests still run separately
and do not inflate the library's reported percentage. Coverage is a diagnostic,
not proof of visual quality or device performance. Negative controls and raster
behavior checks remain necessary.

CI retains that report as `library-coverage`. A separate least-privilege job sends
only the explicit LCOV file to Codecov using GitHub OIDC, without a stored upload
token. The action is pinned to the v7 commit. Upload errors fail that job rather
than silently appearing as a successful integration. Main pushes and same-repo
pull requests upload; fork PRs still run tests and retain their report but do not
receive the OIDC upload job. No pull_request_target or untrusted-code token job
is introduced.

The project comparison uses the actual baseline with one percentage point of
tolerance; patch reporting is initially informational. The first report needs a
baseline before comparisons are meaningful. Repository enablement in Codecov, if
requested by the service, is an account setup step; a generated LCOV alone is
not evidence of a received report. GitHub coverage job logs must confirm receipt.

Generated coverage is ignored by both Git and Pub's explicit archive rules.
No source lines, exclusions or tests are hidden to raise the percentage.

References: [Codecov Action](https://github.com/codecov/codecov-action),
[OIDC inputs and permissions](https://github.com/codecov/codecov-action#using-oidc).

The tested Flutter baseline resolves example dependencies from the root get,
including --enforce-lockfile. Setup runs it once. An isolated negative check with
the example lockfile removed fails at the root command; separate projects still
retain their own lockfiles.
