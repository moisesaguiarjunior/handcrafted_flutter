# Standard lint policy

The root and example declare developer-only flutter_lints ^6.0.0. The official
preset supplements strict casts/inference/raw types and the existing public API,
awaited-future and control-flow rules. Runtime dependencies remain unchanged.
Baseline lockfiles resolve flutter_lints 6.0.0 and lints 6.1.0; their BSD notices
and hashes are recorded in the dependency inventory. Each compatibility SDK still
resolves and checks its own supported pins.

## Narrow cross-package boundaries

- Library and example code use the full preset. Example tests use package imports.
- tool/analysis_options.yaml inherits the root policy and relaxes only
  avoid_relative_lib_imports. Capture/authoring commands intentionally import the
  actual example painters across package roots; a path development dependency
  from the root back to its consumer would compromise publication and ownership.
- test/living_art_test.dart has the same single-rule file exception for its
  existing integration raster probe. No renderer is copied into lib to satisfy
  a lint. No rule is globally disabled and capture entrypoints are preserved.
- Existing SDK bridges retain their one-line compatibility suppressions; this
  adoption does not replace them with newer-only APIs.

## Evidence that the policy can fail

The normal check script also runs `python3 tool/check_lint_policy.py`. It reuses
the publication snapshot helper and real Flutter analyzer, inserts synthetic
print/unbraced-if probes plus dynamic-call and strict-cast violations in lib,
example/lib and tool, and requires each preset/project-specific diagnostic. Public API documentation is additionally checked in the
library contexts, where that rule applies. The disposable snapshot is removed;
working files and local notes are not modified or copied into fixtures.

This guard fails if the preset, project-specific dynamic-call rule or strict
casts are removed. It also fails if the tool scope stops inheriting the root
policy and includes only the upstream preset. A clean
analyzer alone would not prove dormant rules were still active. The usual
format/analyze/test and publication checks remain required.

The resulting fixes are named-argument order, an override parameter name,
redundant consts, equivalent nullable/set literals and import spelling. No pixel
baseline, input transform, material painter, seed or ownership policy changes.
