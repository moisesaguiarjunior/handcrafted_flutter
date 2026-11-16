# Bounded gravity and wind

`CraftPendulum` models one rigid suspended point mass. It accepts gravity, a
constant screen-space wind acceleration and angular damping. Output is an
existing PartPose plus a bob attachment offset. There is no animation clock,
resource/cache ownership, random force or application policy in the simulation.

```dart
final motion = CraftPendulum(
  length: 140, gravity: 980, wind: const Offset(180, 0),
  damping: 1.2, style: CraftPhysicsStyle.realistic,
);
final frame = motion.sample(elapsedFromHost);
final pose = frame.pose; // pass to CraftPart with an authored pivot
final attachment = frame.bobOffset; // relative to that pivot
```

Flutter positive rotation is clockwise: a downward hanging mass rotates toward
negative x at positive angles. Positive horizontal wind therefore produces a
negative equilibrium angle and moves the mass right. Length and accelerations
use logical pixels, not device pixels. This is a point-mass approximation, not
certified physical accuracy, displaced cloth, flexible rope, fluid or buoyancy.

## Realistic / cartoon

Realistic uses supplied forces/damping directly. Cartoon uses 0.7x gravity,
1.7x wind and 0.65x damping for exaggerated response. Both use the same fixed-step
semi-implicit Euler integration. Cartoon is a documented response treatment,
not a hidden change of units or an actor-specific path preset.

The recipe accepts length 16..1024 px, gravity 0..4000 px/s², wind magnitude up to
2000 px/s², damping 0..20 s⁻¹, initial angle -pi..pi and initial angular velocity
-8..8 rad/s. Inputs must be finite. Changing a recipe means a new simulation
from its initial state, not continuous retargeting of a previous simulation.

## External time and accessibility

Time is supplied as Duration in 0..30 seconds. Sampling floors time to a 1/120s
step and recomputes from the initial state, at most 3600 steps. Repeated, reverse
and out-of-order requests produce the same pose on the same runtime. There is
no hidden elapsed gap when a host pauses. Avoid resampling many recipes during
paint: prepare bounded frame data when appropriate and measure actual workloads.
There is no indefinite streaming API yet.

Use the existing SceneEntrance for optional finite playback, or take progress
from a video timeline. Do not create a second clock in an export. A host can
supply a quiet/static sample for reduced motion; the simulation does not read
MediaQuery or detect visibility. A constant wind may leave a nonzero resting
angle. At zero gravity with no damping, the mass may continue to rotate.

For native actions, reserve the complete swept target area in the parent and
use actual layout size/pivot for attachment mapping. Painting outside a parent
cannot make that area receive touches. No collision or area reservation is
inferred by the model.

Run `flutter run -d chrome -t lib/main_physics.dart` from example/ for native
force/time sliders and two transformed native buttons. The example has no idle
playback; reduced motion supplies a fixed 12-second sample. Changing force
controls still updates that static sample. Device performance remains unmeasured.
