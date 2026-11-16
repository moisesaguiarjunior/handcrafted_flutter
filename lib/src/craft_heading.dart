import 'package:flutter/material.dart';

import 'craft_relief.dart';
import 'craft_theme.dart';

/// A native heading with optional host-themed relief, not rasterized lettering.
///
/// Uses the native headlineMedium style, merged with [style]. Words wrap and
/// scale normally. No CraftTheme is required: absent lighting gives plain text.
/// The accessible heading label exists independently of any decorative reveal.
class CraftHeading extends StatelessWidget {
  /// Creates one native heading; text must already be localized by the host.
  const CraftHeading(
    this.text, {
    super.key,
    this.style,
    this.relief,
    this.textAlign = TextAlign.start,
  });

  /// Host-provided text; there is no content or application identity default.
  final String text;

  /// Merged with the host's native headlineMedium style.
  final TextStyle? style;

  /// Explicit lighting overrides CraftTheme.heading, without requiring a theme.
  /// Set depth to zero for plain text, including under a decorated theme.
  final CraftReliefStyle? relief;

  /// Native paragraph alignment, resolved in the host direction.
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final native = Theme.of(context);
    final lighting = relief ?? native.extension<CraftTheme>()?.heading;
    return Semantics(
      header: true,
      child: CraftReliefText(
        text,
        style: native.textTheme.headlineMedium?.merge(style) ?? style,
        textAlign: textAlign,
        kind: lighting?.kind ?? CraftReliefKind.inset,
        depth: lighting?.depth ?? 0,
        light: lighting?.light ?? const Offset(-1, -1),
      ),
    );
  }
}
