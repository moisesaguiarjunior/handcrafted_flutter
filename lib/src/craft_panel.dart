import 'package:flutter/widgets.dart';

import 'contour_inset.dart';
import 'craft_stitch.dart';
import 'craft_surface.dart';
import 'craft_theme.dart';

/// Material behind native content, with optional contour-following thread.
///
/// Content determines layout and is never clipped to the decorative cut.
/// Decoration has no input or semantics. Above 1024 logical pixels on either
/// axis it becomes a plain host-colored background, retaining native text and
/// actions rather than relaxing painter budgets or shrinking the content.
/// Exhausted contour/thread preparation budgets use the same fallback.
class CraftPanel extends StatefulWidget {
  /// Uses [role] from CraftTheme, or an explicit [style].
  const CraftPanel({
    super.key,
    required this.child,
    this.role = CraftRole.sheet,
    this.style,
    this.padding,
  });

  /// Native layout and controls, never rasterized into the material.
  final Widget child;

  /// Visual role to resolve from the material theme.
  final CraftRole role;

  /// Optional explicit style; requires no installed CraftTheme.
  final CraftPanelStyle? style;

  /// Overrides style padding, for compositions such as native buttons.
  final EdgeInsetsGeometry? padding;
  @override
  State<CraftPanel> createState() => _CraftPanelState();
}

class _CraftPanelState extends State<CraftPanel> {
  _PanelGeometry? _geometry;
  Object? _recipe;
  @override
  Widget build(BuildContext context) {
    final style = widget.style ?? CraftTheme.of(context).styleFor(widget.role);
    final padding = (widget.padding ?? style.padding).resolve(
      Directionality.of(context),
    );
    if (![
      padding.left,
      padding.top,
      padding.right,
      padding.bottom,
    ].every((v) => v.isFinite && v >= 0)) {
      throw ArgumentError('Expected finite nonnegative content padding');
    }
    final seam = style.seam;
    final recipe = (
      style.shape,
      seam?.inset,
      seam?.kind,
      seam?.pitch,
      seam?.depth,
      seam?.side,
    );
    if (_recipe != recipe) {
      _recipe = recipe;
      _geometry = _PanelGeometry(style);
    }
    final geometry = _geometry!;
    return Stack(
      fit: StackFit.passthrough,
      children: [
        Positioned.fill(
          child: ExcludeSemantics(
            child: IgnorePointer(
              child: LayoutBuilder(
                builder: (context, bounds) {
                  if (bounds.maxWidth > 1024 ||
                      bounds.maxHeight > 1024 ||
                      !geometry.prepare(bounds.biggest)) {
                    return ColoredBox(color: style.color);
                  }
                  return CraftSurface(
                    material: style.material,
                    color: style.color,
                    seed: style.seed,
                    scale: style.scale,
                    strength: style.strength,
                    outline: geometry.pathFor,
                    child: CustomPaint(
                      foregroundPainter: seam == null
                          ? null
                          : _PanelThread(geometry, seam),
                      child: const SizedBox.expand(),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        Padding(padding: padding, child: widget.child),
      ],
    );
  }
}

// Shared cut and lazy offset/prepared-thread cache, following the existing
// example geometry owner; native content remains outside decorative clipping.
class _PanelGeometry {
  _PanelGeometry(this.style);
  final CraftPanelStyle style;
  Size? _size;
  bool _ready = false;
  Path _outline = Path();
  CraftStitchFrame? frame;
  bool prepare(Size size) {
    if (_size == size) return _ready;
    _size = size;
    frame = null;
    try {
      _outline = style.shape.pathFor(size);
      final seam = style.seam;
      if (seam != null) {
        final path = craftStitchPath(
          insetCraftPath(_outline, distance: seam.inset, sampleSpacing: 2),
          kind: seam.kind,
          pitch: seam.pitch,
          depth: seam.depth,
          side: seam.side,
        );
        frame = CraftStitchFrame.sample(path, progress: 1);
      }
      _ready = true;
    } on ArgumentError {
      // Style inputs have already been validated. Actual-size work budgets
      // may still be exhausted; omit decoration and retain native content.
      _outline = Path();
      _ready = false;
    }
    return _ready;
  }

  Path pathFor(Size size) {
    prepare(size);
    return _outline;
  }
}

class _PanelThread extends CustomPainter {
  const _PanelThread(this.geometry, this.seam);
  final _PanelGeometry geometry;
  final CraftSeam seam;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    try {
      canvas.clipPath(geometry.pathFor(size));
      geometry.frame!.paint(
        canvas,
        thread: seam.color,
        width: seam.width,
        compression: seam.compression,
      );
    } finally {
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_PanelThread old) =>
      old.geometry != geometry || old.seam != seam;
}
