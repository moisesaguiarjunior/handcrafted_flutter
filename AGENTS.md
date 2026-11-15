# Working here

Use English for code, documentation and commits. Read README.md, docs/reuse.md
and relevant decisions before editing. Search by name, behavior and type, record
what was searched, and plan with Reuse and Create.

Prefer existing dependencies over parallel implementations. Keep values explicit,
immutable where possible, and statically typed; validate public input. Rendering
accepts seeds and time rather than reading the wall clock or global app state.
Use synthetic content only. Never commit machine/device identifiers or personal
paths. Document dependency licenses and source provenance before redistribution.

Run bash tool/check.sh before finishing. Test material failure modes and show
that protected regressions fail when the behavior is removed; avoid getter tests.
Never regenerate goldens to make tests pass. Visual changes need owner approval.

Work on a local branch. No public pushes before independent local review of the
exact commit; the author cannot approve their own changes. Review the original
requirement and actual callers before author rationale. Report file, line,
scenario and severity; outcomes are no blocking findings, changes required, or
verification incomplete. Do not claim automated publication gates exist yet.
