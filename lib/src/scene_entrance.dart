import 'package:flutter/widgets.dart';

/// Extracted finite scene clock with lifecycle and reduced-motion suspension.
///
/// The host must set [active] from its viewport/route visibility policy; this
/// widget does not detect scroll visibility. No ticker runs while inactive,
/// backgrounded, under disabled TickerMode or
/// after completion. Resume continues the saved pose without integrating the
/// elapsed gap. Platform reduced motion settles immediately, even if inactive.
/// A new key starts a new entrance; the host owns visit and identity policy.
/// This widget retains native child interaction/semantics. Decorative callers
/// wrap it in IgnorePointer/ExcludeSemantics themselves. No physics is implied.
class SceneEntrance extends StatefulWidget {
  /// Creates an entrance. [duration] must be positive or mounting throws.
  const SceneEntrance({
    super.key,
    required this.builder,
    this.active = true,
    this.startSettled = false,
    this.duration = const Duration(milliseconds: 4200),
  });

  /// Entrance duration; must be positive. Changing it preserves normalized pose.
  final Duration duration;

  /// Receives linear normalized progress, from zero to one.
  final Widget Function(BuildContext context, double progress) builder;

  /// Host-supplied visibility/activity policy; false pauses elapsed time.
  /// Defaults to true. Viewport visibility is not detected automatically.
  final bool active;

  /// Suppress replay when returning to an already greeted home this session.
  final bool startSettled;

  @override
  State<SceneEntrance> createState() => _SceneEntranceState();
}

class _SceneEntranceState extends State<SceneEntrance>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _arrival = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  bool _reduced = false;
  bool _tickerEnabled = true;
  bool _foreground = true;

  @override
  void initState() {
    super.initState();
    if (widget.duration <= Duration.zero) {
      throw ArgumentError.value(
        widget.duration,
        'duration',
        'Must be positive',
      );
    }
    if (widget.startSettled) _arrival.value = 1;
    WidgetsBinding.instance.addObserver(this);
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    _foreground = lifecycle == null || lifecycle == AppLifecycleState.resumed;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduced = MediaQuery.disableAnimationsOf(context);
    // Both supported SDKs expose the enabled flag through this accessor.
    // ignore: deprecated_member_use
    _tickerEnabled = TickerMode.of(context);
    _sync();
  }

  @override
  void didUpdateWidget(SceneEntrance oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.duration <= Duration.zero) {
      throw ArgumentError.value(
        widget.duration,
        'duration',
        'Must be positive',
      );
    }
    if (oldWidget.duration != widget.duration) {
      _arrival.stop(canceled: false);
      _arrival.duration = widget.duration;
    }
    if (widget.startSettled && !_arrival.isCompleted) {
      _arrival.value = 1;
    }
    _sync();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    _sync();
  }

  void _sync() {
    if (_reduced) {
      _arrival.stop();
      _arrival.value = 1;
    } else if (!widget.active || !_foreground || !_tickerEnabled) {
      _arrival.stop(canceled: false);
    } else if (!_arrival.isCompleted && !_arrival.isAnimating) {
      _arrival.forward();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _arrival.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RepaintBoundary(
    child: AnimatedBuilder(
      animation: _arrival,
      builder: (context, _) => widget.builder(context, _arrival.value),
    ),
  );
}
