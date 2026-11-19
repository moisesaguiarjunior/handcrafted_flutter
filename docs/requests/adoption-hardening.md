# Adoption hardening after 0.3.0

Accepted follow-up to an external static review. Observed ownership/allocation and
preparation costs identify experiments; they do not establish mobile slowdown.
Keep the package focused on materials around native widgets.

## Delivery order and acceptance

1. **Current documentation.** Correct the shipped 0.3.0 material list and typo;
   keep the reuse map focused on current contracts and preserve all extraction
   notes separately, with working links. Do not prune refs or useful example
   entrypoints as a proxy for engineering quality.
2. **SDK compatibility.** Probe an older stable SDK in isolation, without changing
   the maintainer's installed SDK. Resolve that SDK's pinned dependencies, analyze
   library and examples, run both suites and build the web gallery. Pin tested
   versions in CI before widening the SDK floor. Current lockfile verification
   stays on the release baseline; old SDK jobs must re-resolve their own SDK pins.
   No support is inferred from imports alone and no published tag is rewritten.
3. **Standard lints.** Add an official recommended preset in an isolated change,
   retaining strict mode and public API documentation rules. Review resulting
   fixes for behavior; do not disable the preset globally to make analysis pass.
4. **Cost baselines.** Reuse main_budget and existing owner-scoped bookkeeping.
   Measure cold and warm texture/preparation work separately from painting. For
   CraftVolume, report cut size, segment count, profile and number of pieces, and
   confirm geometry survives relighting. Owner/image counts are not physical GPU
   allocations. Record software versions and generic environments only.
5. **Opacity experiment.** Compare the existing layer composition with direct
   shader opacity before replacing it. Cover all material tiles, strengths 0/1
   and fractional values, translucent fills, holes, antialiasing, clipping and
   scaling. Preserve the approved output and demonstrate a benefit in a defined
   workload. Desktop/Chrome evidence is not a mobile performance claim.
6. **Optional scoped sharing.** Only if measurements justify it, define whether
   a resource is borrowed or owned, who disposes it, seed replacement, and safe
   independent consumers. Retain the default owner-scoped behavior and avoid a
   global mutable cache. Shared textures do not by themselves solve paint cost.
7. **Physical devices before broader guarantees.** Profile Android and iOS release/
   profile rendering and memory, including Impeller, and exercise physical
   assistive technology. This remains a separate owner-controlled stage; neither
   emulation nor high test coverage substitutes for it.

## Existing contracts

- MaterialTextures lazily owns one tile per requested material; CraftSurface owns
  its own cache. Duplicate equivalent owners are possible and are not a leak.
- CraftVolume prepares bounded height/normal geometry synchronously; callers can
  retain it across light and pose changes. Preparation is not free simply because
  its input has a bound.
- The rendering harness already supplies fixed workloads, warmup/cutoff handling
  and explicit owner accounting. Extend its evidence rather than creating a
  parallel benchmark or claiming GPU memory from logical counters.
- Native controls preserve their semantics, but each composed screen still needs
  layout, target-size, keyboard and screen-reader verification.

No new runtime API, shader, cache or 1.0 commitment is accepted by this request.
Consumer upgrades belong in their own reviewed changes with visual comparisons;
private artwork, product inventories and application policies stay outside this
public repository.
