# A short pour and passing light

Run `flutter run -d chrome -t lib/main_effects.dart` from `example/`.
The original synthetic paper vessel uses CraftSurface and CraftPart. Its emitter
is mapped by the same PartPose as its artwork. Emitter and destination are then
supplied to an example-local PourRecipe. No physics/particle engine is added.

The recipe prepares twelve droplet variations and eighteen dust points from a
seed. Storage is fixed; a pose creates at most twelve temporary droplet offsets,
without accumulating particles. Changing progress retains the owner-scoped
recipe; changing seed replaces it. There are no raster resources in the recipe.
At progress zero/one it draws no effect. Positions, light opacity and drift are
deterministic on the same renderer. These are authored trajectories, not fluid
dynamics, atmospheric scattering or a measured simulation.

The native slider supplies explicit time without a clock. Play uses the existing
finite SceneEntrance for 1.8 seconds; initial/rest poses are quiet. Automatic
reduced motion settles to the final static pose. Manual scrubbing is explicit.
Leaving the example disposes its clock; the host still owns viewport activity.
The reserved scene rectangle clips drawing to its bounds. The light wash uses
simple translucent shapes, without blur or additional offscreen layers.

Tests cover fixed work bounds across repeated samples, seeds, empty endpoints,
mapped emitter coordinates, recipe retention/replacement, finite/reduced-motion
playback and 320px native controls with real-font text through 250%.
Raster/UI timings and phone performance remain unmeasured; use the profiling
scene before introducing a cache, prepared geometry or a more complex effect.
