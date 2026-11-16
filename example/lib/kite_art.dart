import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

import 'showcase_theme.dart';

/// Shared kite artwork; progress deforms only the attached ribbon tail.
class KiteArt extends StatefulWidget {
  /// Creates the existing artwork with explicit tail progress and drawing scale.
  const KiteArt({super.key, required this.progress, this.artScale = 1.1});

  /// Uniform artwork scale; the legacy capture uses 1.1.
  final double artScale;

  /// Finite authored tail progress, clamped by the example painter.
  final double progress;
  @override
  State<KiteArt> createState() => _KiteStudyState();
}

class _KiteStudyState extends State<KiteArt> {
  final textures = MaterialTextures();
  @override
  void dispose() {
    textures.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.artScale.isFinite ||
        widget.artScale <= 0 ||
        widget.artScale > 4) {
      throw ArgumentError('Expected a finite artwork scale in (0, 4]');
    }
    return CustomPaint(
      painter: _KitePainter(widget.progress, textures, widget.artScale),
    );
  }
}

class _KitePainter extends CustomPainter {
  _KitePainter(this.progress, this.textures, this.artScale);

  /// Uniform artwork scale; the legacy capture uses 1.1.
  final double artScale;

  /// Finite authored tail progress, clamped by the example painter.
  final double progress;
  final MaterialTextures textures;
  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width * .63, 88);
    canvas.scale(artScale);
    final sail = Path()
      ..moveTo(0, -28)
      ..lineTo(20, 0)
      ..lineTo(0, 28)
      ..lineTo(-20, 0)
      ..close();
    textures.paint(
      canvas,
      sail,
      material: CraftMaterial.paper,
      color: DemoPalette.rose,
    );
    final thread = Paint()
      ..color = DemoPalette.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawPath(
      Path()
        ..moveTo(0, -28)
        ..lineTo(0, 28)
        ..moveTo(-20, 0)
        ..lineTo(20, 0),
      thread,
    );
    if (!progress.isFinite) throw ArgumentError('Expected finite progress');
    final p = progress.clamp(0.0, 1.0);
    final bend = 6 * math.sin(p * math.pi) * math.sin(p * math.pi * 4);
    // Example-only waypoints: no application artwork or exported actor preset.
    final tail = craftCurveThrough([
      const Offset(0, 28),
      Offset(18 + bend, 60),
      Offset(-12 - bend, 98),
      const Offset(6, 132),
    ]);
    canvas.drawPath(tail, thread);
    final metric = tail.computeMetrics().single;
    for (final fraction in [.18, .36, .66]) {
      final tangent = metric.getTangentForOffset(metric.length * fraction);
      if (tangent == null) continue;
      canvas.save();
      canvas.translate(tangent.position.dx, tangent.position.dy);
      canvas.rotate(tangent.angle);
      final bow = Path()
        ..moveTo(0, 0)
        ..lineTo(-5, -8)
        ..lineTo(6, -7)
        ..close()
        ..moveTo(0, 0)
        ..lineTo(-5, 8)
        ..lineTo(6, 7)
        ..close();
      textures.paint(
        canvas,
        bow,
        material: CraftMaterial.twill,
        color: DemoPalette.sage,
      );
      canvas.restore();
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_KitePainter old) =>
      old.progress != progress ||
      old.textures != textures ||
      old.artScale != artScale;
}
