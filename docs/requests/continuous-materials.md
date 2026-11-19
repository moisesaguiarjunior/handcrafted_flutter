# Continuous material and fidelity proofs

Before a consumer replaces large artwork with procedural decoration, demonstrate
synthetic recipes with the current primitives. Keep private images, geometry,
palettes, application names and editorial behavior outside the public package.

## Acceptance order

1. Retain paper/pigment in a fixed source domain above 1024 logical pixels and
   compare viewports/strips at 1× and 3×, including fractional origins. Report
   actual differences, default painter limits and a per-strip restart negative
   control. Never infer arbitrary-size continuity from one bounded example.
2. Compare a quieter, soft-edged field using native masks, with independent core
   alpha, edge transition/curve and outline irregularity. Check transparent
   export and distinguish recording, raster/readback and phone frame timings.
3. Compose repeatable check/diamond prints on cloth or paper with stable source
   phase/seed and explicit palette. Avoid globally recoloring content.
4. Evaluate fine predominantly directional paper fibers with independent length,
   density and strength. Existing flat dashed strokes already support the seam
   case; no new stitch or cap API is justified by this request.
5. Only propose a minimum package contract if these recipes demonstrably fail.
   Larger-than-2048 source domains and exact cross-engine raster equivalence
   remain open; consumer adoption and visual approval remain separate work.

The first [bounded proof](../surface-continuity.md) is example-owned. It preserves
package defaults and records clipping differences instead of declaring the
consumer's reference reproduced. Physical Android/iPhone measurement is deferred.
