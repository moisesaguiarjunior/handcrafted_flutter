# Contributing

Read README.md, docs/reuse.md and docs/compatibility.md before changing APIs.
Search existing implementations and record a plan with Reuse and Create sections.
Keep code, comments, documentation and commit messages in English. Use synthetic
content and explicit seeds/time. Keep consumer-specific documents in consumer
repositories. Never commit personal paths, device identifiers or access tokens.

Run `bash tool/check.sh`. Add regression coverage for meaningful behavior changes;
show that the check can fail. Do not regenerate goldens to hide a failure. Visual
changes require owner approval. Keep native semantics, focus and text scaling.

Work on a local branch. Public pushes require independent review of the exact
commit; the author cannot approve their own changes. Report checks and limits.
