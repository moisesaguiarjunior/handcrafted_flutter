import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Observes actual shaders; optionally experiments with direct paint alpha.
class TextureCanvas implements Canvas {
  TextureCanvas(this.canvas, {this.directAlpha = false});
  final Canvas canvas;
  final bool directAlpha;
  final shaders = <ui.Shader>[];
  final saves = <bool>[];
  int layers = 0;
  double opacity = 1;
  @override
  void drawPath(Path path, Paint paint) => canvas.drawPath(path, paint);
  @override
  void save() {
    saves.add(true);
    canvas.save();
  }

  @override
  void saveLayer(Rect? bounds, Paint paint) {
    layers++;
    saves.add(!directAlpha);
    if (directAlpha) {
      opacity = paint.color.a;
    } else {
      canvas.saveLayer(bounds, paint);
    }
  }

  @override
  void restore() {
    if (saves.removeLast()) {
      canvas.restore();
    } else {
      opacity = 1;
    }
  }

  @override
  void clipPath(Path path, {bool doAntiAlias = true}) =>
      canvas.clipPath(path, doAntiAlias: doAntiAlias);
  @override
  void translate(double dx, double dy) => canvas.translate(dx, dy);
  @override
  void drawPaint(Paint paint) {
    shaders.add(paint.shader!);
    canvas.drawPaint(
      directAlpha
          ? (Paint()
              ..shader = paint.shader
              ..color = Colors.white.withValues(alpha: opacity))
          : paint,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnsupportedError(invocation.memberName.toString());
}
