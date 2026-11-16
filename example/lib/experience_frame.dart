import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Example-first viewport composition; the host Scaffold owns keyboard resizing.
///
/// Only [illustration] is fitted by its own artwork widget. Heading, content and
/// footer remain native. The stable Wrap topology preserves control/focus state
/// across column/row layouts. SafeArea consumes remaining host system padding.
class ExperienceFrame extends StatelessWidget {
  /// Requires finite bounded viewport constraints from the host, not a scroll.
  const ExperienceFrame({
    super.key,
    required this.heading,
    required this.illustration,
    required this.content,
    required this.footer,
  });

  /// Native heading available before any artwork reveal.
  final Widget heading;

  /// Authored-coordinate artwork with any independently sized native overlay.
  final Widget illustration;

  /// Unscaled native text, fields and controls.
  final Widget content;

  /// Pinned native action area, independently scrollable in extreme constraints.
  final Widget footer;
  @override
  Widget build(BuildContext context) => SafeArea(
    child: LayoutBuilder(
      builder: (context, bounds) {
        if (!bounds.hasBoundedWidth || !bounds.hasBoundedHeight) {
          throw FlutterError(
            'ExperienceFrame requires a bounded host viewport. Let its body own scrolling.',
          );
        }
        return CustomMultiChildLayout(
          delegate: _FrameLayout(),
          children: [
            LayoutId(
              id: _Slot.body,
              child: SingleChildScrollView(
                key: const ValueKey('experience-body-scroll'),
                primary: false,
                padding: const EdgeInsets.all(16),
                child: LayoutBuilder(
                  builder: (context, body) {
                    final wide = body.maxWidth >= 880;
                    final width = wide
                        ? (body.maxWidth - 24) / 2
                        : body.maxWidth;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        heading,
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 24,
                          runSpacing: 24,
                          children: [
                            SizedBox(
                              width: width,
                              height: math.min(width, 420),
                              child: illustration,
                            ),
                            SizedBox(width: width, child: content),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            LayoutId(
              id: _Slot.footer,
              child: SingleChildScrollView(
                key: const ValueKey('experience-footer-scroll'),
                primary: false,
                child: footer,
              ),
            ),
          ],
        );
      },
    ),
  );
}

enum _Slot { body, footer }

// Native layout measures the actual footer once; no text measurement, second
// responsive matrix or post-frame size/state feedback loop is introduced.
class _FrameLayout extends MultiChildLayoutDelegate {
  _FrameLayout();
  @override
  void performLayout(Size size) {
    final reserve = math.min(96.0, size.height / 2);
    final footer = layoutChild(
      _Slot.footer,
      BoxConstraints(
        minWidth: size.width,
        maxWidth: size.width,
        maxHeight: size.height - reserve,
      ),
    );
    layoutChild(
      _Slot.body,
      BoxConstraints.tight(Size(size.width, size.height - footer.height)),
    );
    positionChild(_Slot.body, Offset.zero);
    positionChild(_Slot.footer, Offset(0, size.height - footer.height));
  }

  @override
  bool shouldRelayout(_FrameLayout oldDelegate) => false;
}
