import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';

import 'path_geometry.dart';

/// Which way the light-facing edge of a decorative impression is shaded.
enum CraftReliefKind {
  /// Light upper rim and dark lower rim, with a short contact shadow.
  raised,

  /// Dark upper rim and light lower rim, inside the supplied silhouette.
  inset,
}

/// Host-owned glyph lighting; typography and color remain native.
@immutable
final class CraftReliefStyle {
  /// Validates the same 0..8 depth and light contract as [CraftReliefText].
  CraftReliefStyle({
    this.kind = CraftReliefKind.inset,
    this.depth = 1.2,
    this.light = const Offset(-1, -1),
  }) {
    _validateRelief(depth, 1, light);
  }

  /// Raised or pressed glyph shading.
  final CraftReliefKind kind;

  /// Logical glyph shading offset; zero leaves ordinary native text.
  final double depth;

  /// Finite nonzero incoming light direction.
  final Offset light;

  @override
  bool operator ==(Object other) =>
      other is CraftReliefStyle &&
      other.kind == kind &&
      other.depth == depth &&
      other.light == light;

  @override
  int get hashCode => Object.hash(kind, depth, light);
}

/// Paints an illustrative raised or pressed motif over an existing material.
///
/// Without [fill], the original substrate remains visible. [depth] is 0..8
/// logical pixels; [strength] is 0..1; [light] is a finite nonzero direction.
/// Source must be closed with the same work limits as stitches. All inputs and
/// rim geometry are validated before painting. Raised shadows extend outside
/// the shape; reserve depth padding. Zero depth/strength leaves only [fill].
/// Directional rims are a lighting approximation, not a general path inset or
/// displaced fabric. Text should use [CraftReliefText] to retain native layout.
void paintCraftRelief(
  Canvas canvas,
  Path source, {
  CraftReliefKind kind = CraftReliefKind.inset,
  Color? fill,
  double depth = 2,
  double strength = .8,
  Offset light = const Offset(-1, -1),
}) {
  final metrics = checkedPathMetrics(source);
  _validateRelief(depth, strength, light);
  if (metrics.any((m) => !m.isClosed)) {
    throw ArgumentError('Relief requires closed contours');
  }
  if (metrics.isEmpty) return;
  final direction = light / light.distance;
  final upper = Path.combine(
    PathOperation.difference,
    source,
    source.shift(-direction * depth),
  );
  final lower = Path.combine(
    PathOperation.difference,
    source,
    source.shift(direction * depth),
  );
  final contact = kind == CraftReliefKind.raised
      ? Path.combine(
          PathOperation.difference,
          source.shift(-direction * depth),
          source,
        )
      : null;
  if (kind == CraftReliefKind.raised && depth > 0 && strength > 0) {
    canvas.drawPath(
      contact!,
      Paint()..color = Color.fromRGBO(0, 0, 0, .16 * strength),
    );
  }
  if (fill != null) canvas.drawPath(source, Paint()..color = fill);
  if (depth == 0 || strength == 0) return;
  final bright = Color.fromRGBO(255, 255, 255, .65 * strength);
  final dark = Color.fromRGBO(0, 0, 0, .42 * strength);
  canvas.drawPath(
    upper,
    Paint()..color = kind == CraftReliefKind.inset ? dark : bright,
  );
  canvas.drawPath(
    lower,
    Paint()..color = kind == CraftReliefKind.inset ? bright : dark,
  );
}

void _validateRelief(double depth, double strength, Offset light) {
  if (!depth.isFinite ||
      depth < 0 ||
      depth > 8 ||
      !strength.isFinite ||
      strength < 0 ||
      strength > 1 ||
      !light.dx.isFinite ||
      !light.dy.isFinite ||
      !light.distance.isFinite ||
      light.distance == 0) {
    throw ArgumentError('Invalid relief depth, strength or light direction');
  }
}

/// Pressed or raised lettering that remains a real, scalable [Text] widget.
///
/// Theme/style, locale, direction, text scaling and semantics stay native. An
/// inset glyph mask adds inner shading without replacing the readable text.
/// No font family, application palette or content is supplied by the package.
/// Background-painted spans and paragraphs exceeding 2048 logical pixels on
/// either axis or 1,048,576 square logical pixels keep native shadows only.
class CraftReliefText extends StatefulWidget {
  /// Creates a native text impression. Depth is 0..8 logical pixels.
  const CraftReliefText(
    this.text, {
    super.key,
    this.style,
    this.kind = CraftReliefKind.inset,
    this.depth = 1.2,
    this.light = const Offset(-1, -1),
    this.textAlign = TextAlign.start,
  });

  /// Host-provided, already localized text.
  final String text;

  /// Optional style merged with the surrounding default style.
  final TextStyle? style;

  /// Raised or inset edge lighting.
  final CraftReliefKind kind;

  /// Logical glyph shading offset, 0..8.
  final double depth;

  /// Finite nonzero incoming light direction, shared with motif relief.
  final Offset light;

  /// Native paragraph alignment.
  final TextAlign textAlign;

  @override
  State<CraftReliefText> createState() => _CraftReliefTextState();
}

class _CraftReliefTextState extends State<CraftReliefText> {
  final _textKey = GlobalKey();
  final _surfaceKey = GlobalKey();

  _ParagraphFrame? _frame() {
    final root = _textKey.currentContext?.findRenderObject();
    final surface = _surfaceKey.currentContext?.findRenderObject();
    RenderParagraph? paragraph;
    void find(RenderObject object) {
      if (object is RenderParagraph) {
        paragraph = object;
        return;
      }
      object.visitChildren(find);
    }

    if (root != null) find(root);
    final found = paragraph;
    if (found == null || !found.hasSize || surface == null) return null;
    return (
      paragraph: found,
      origin: found.localToGlobal(Offset.zero, ancestor: surface),
    );
  }

  @override
  Widget build(BuildContext context) {
    _validateRelief(widget.depth, 1, widget.light);
    final resolved = DefaultTextStyle.of(context).style.merge(widget.style);
    final offset = math.min(widget.depth, 1.5);
    final direction = widget.light / widget.light.distance;
    final raised = widget.kind == CraftReliefKind.raised;
    final child = Text(
      widget.text,
      key: _textKey,
      textAlign: widget.textAlign,
      style: widget.depth == 0
          ? resolved
          : resolved.copyWith(
              shadows: [
                Shadow(
                  color: const Color(0x99FFFFFF),
                  offset: direction * (raised ? offset : -offset),
                ),
                Shadow(
                  color: const Color(0x66000000),
                  offset: direction * (raised ? -offset : offset),
                ),
              ],
            ),
    );
    if (raised || widget.depth == 0) return child;
    return CustomPaint(
      key: _surfaceKey,
      foregroundPainter: _InsetGlyphs(_frame, widget.depth, direction),
      child: child,
    );
  }
}

typedef _ParagraphFrame = ({RenderParagraph paragraph, Offset origin});

class _InsetGlyphs extends CustomPainter {
  const _InsetGlyphs(this.frame, this.depth, this.light);
  final _ParagraphFrame? Function() frame;
  final double depth;
  final Offset light;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty ||
        size.width > 2048 ||
        size.height > 2048 ||
        size.width * size.height > 1048576)
      return;
    final current = frame();
    if (current == null) return;
    final paragraph = current.paragraph;
    var background = false;
    paragraph.text.visitChildren((span) {
      if (span.style?.background != null ||
          span.style?.backgroundColor != null) {
        background = true;
      }
      return !background;
    });
    // Background-painted paragraphs keep native directional shadows only.
    if (background) return;
    // Borrow the native paragraph's resolved span/configuration instead of
    // reimplementing inherited spacing, bold-text, ellipsis or bidi layout.
    final painter = TextPainter(
      text: paragraph.text,
      textAlign: paragraph.textAlign,
      textDirection: paragraph.textDirection,
      textScaler: paragraph.textScaler,
      locale: paragraph.locale,
      maxLines: paragraph.maxLines,
      strutStyle: paragraph.strutStyle,
      textWidthBasis: paragraph.textWidthBasis,
      textHeightBehavior: paragraph.textHeightBehavior,
      ellipsis: paragraph.overflow == TextOverflow.ellipsis ? '…' : null,
    );
    try {
      painter.layout(
        minWidth: paragraph.constraints.minWidth,
        maxWidth:
            paragraph.softWrap || paragraph.overflow == TextOverflow.ellipsis
            ? paragraph.constraints.maxWidth
            : double.infinity,
      );
      final bounds = Offset.zero & size;
      canvas.saveLayer(
        bounds,
        Paint()
          ..colorFilter = const ColorFilter.mode(
            Color(0x66000000),
            BlendMode.srcIn,
          ),
      );
      try {
        painter.paint(canvas, current.origin);
        canvas.saveLayer(bounds, Paint()..blendMode = BlendMode.dstOut);
        try {
          painter.paint(canvas, current.origin - light * depth);
        } finally {
          canvas.restore();
        }
      } finally {
        canvas.restore();
      }
    } finally {
      painter.dispose();
    }
  }

  @override
  bool shouldRepaint(_InsetGlyphs old) => true;
}
