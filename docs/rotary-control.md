# A rotary illustration around native controls

Run `flutter run -d chrome -t lib/main_dial.dart` from `example/`.
The wooden disc uses `CraftSurface` and `CraftPart`; its native slider owns
keyboard stepping, focus and increment/decrement semantics. Additional native
buttons step and apply the selection. Artwork is excluded from input/semantics.

The bounded 0..12 selection maps to an unwrapped 270-degree arc. Endpoint input
clamps, so a maximum-to-minimum discontinuity never appears. New input snapshots
the currently displayed angle before retargeting. Only the decorative
`SceneEntrance` is rekeyed; native controls retain identity and focus. Its finite
350 ms clock respects host activity, TickerMode, background and reduced motion.
Initial artwork is settled. The host must supply route/viewport activity.

`RotaryArtwork(angle: angle)` is the ticker-free entry point for an external
timeline. The playground's selection policy, snapping and apply action are
example-local. Applying updates only a local label, without recording or saving.
This does not introduce a general dial API or claim mechanical physics.

Controls and text flow outside the artwork. Tests cover mid-turn retargeting,
stable native identity, keyboard endpoints, inactivity, reduced motion and
320-logical-pixel layouts at 100%, 150%, 200% and 250% real-font text.
Phone performance and interactive browser runtime remain unverified.
