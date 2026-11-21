import 'package:flutter/material.dart';

import 'craft_panel.dart';
import 'craft_theme.dart';

/// Native TextButton over a themed material, with a minimum 48px target.
///
/// The material sits behind the native Material/InkWell so focus, hover and
/// press feedback stay visible. Ancestors must permit the minimum target size.
/// Colors and typography are inherited from the application's button theme.
class CraftButton extends StatelessWidget {
  /// Creates an action; optional [selected] makes selection part of its node.
  const CraftButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.selected,
    this.style,
    this.focusNode,
    this.autofocus = false,
  });

  /// Native activation; null disables the action.
  final VoidCallback? onPressed;

  /// Native label or icon/label composition.
  final Widget child;

  /// Optional native selected state, merged onto the actionable semantics node.
  final bool? selected;

  /// Explicit material override, independent of button foreground/text style.
  final CraftPanelStyle? style;

  /// Host-owned native focus node.
  final FocusNode? focusNode;

  /// Native initial focus policy.
  final bool autofocus;
  @override
  Widget build(BuildContext context) {
    final role = selected == null
        ? CraftRole.button
        : selected!
        ? CraftRole.selectedChoice
        : CraftRole.choice;
    final look = style ?? CraftTheme.of(context).styleFor(role);
    return CraftPanel(
      style: look,
      padding: EdgeInsets.zero,
      child: MergeSemantics(
        child: Semantics(
          selected: selected,
          child: TextButton(
            onPressed: onPressed,
            focusNode: focusNode,
            autofocus: autofocus,
            style: TextButton.styleFrom(
              backgroundColor: Colors.transparent,
              minimumSize: const Size(48, 48),
              maximumSize: Size.infinite,
              fixedSize: Size.infinite,
              padding: look.padding,
              visualDensity: VisualDensity.standard,
              tapTargetSize: MaterialTapTargetSize.padded,
            ),
            // Selection is shown by a native check mark, not color alone and
            // not a fixed outline that would fight the decorative cut.
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 6,
              runSpacing: 4,
              children: [
                if (selected == true) const _CheckMark(),
                KeyedSubtree(
                  key: const ValueKey('craft-button-label'),
                  child: child,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Controlled choice retaining native button focus, activation and selection.
class CraftChoice extends StatelessWidget {
  /// Toggles through [onSelected]; null disables the choice.
  const CraftChoice({
    super.key,
    required this.selected,
    required this.onSelected,
    required this.child,
    this.style,
    this.focusNode,
    this.autofocus = false,
  });

  /// Host-owned selected state, announced on the actionable button itself.
  final bool selected;

  /// Receives the new selected value; the component owns no application state.
  final ValueChanged<bool>? onSelected;

  /// Native accessible label.
  final Widget child;

  /// Optional explicit material override.
  final CraftPanelStyle? style;

  /// Host-owned native focus node.
  final FocusNode? focusNode;

  /// Native initial focus policy.
  final bool autofocus;
  @override
  Widget build(BuildContext context) => CraftButton(
    selected: selected,
    onPressed: onSelected == null ? null : () => onSelected!(!selected),
    style: style,
    focusNode: focusNode,
    autofocus: autofocus,
    child: child,
  );
}

/// A drawn check in the button's foreground color; needs no icon font.
class _CheckMark extends StatelessWidget {
  const _CheckMark();
  @override
  Widget build(BuildContext context) {
    final color =
        IconTheme.of(context).color ??
        DefaultTextStyle.of(context).style.color ??
        const Color(0xFF000000);
    final size = MediaQuery.textScalerOf(context).scale(16);
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _CheckPainter(color)),
    );
  }
}

class _CheckPainter extends CustomPainter {
  const _CheckPainter(this.color);
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    canvas.drawPath(
      Path()
        ..moveTo(s * .14, s * .54)
        ..lineTo(s * .4, s * .78)
        ..lineTo(s * .88, s * .24),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = s * .14
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_CheckPainter old) => old.color != color;
}
