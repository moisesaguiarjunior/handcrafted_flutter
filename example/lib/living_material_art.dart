import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

part 'wet_contact_art.dart';
part 'thread_pass_art.dart';
part 'thread_finish_art.dart';

/// Finite material techniques in the example gallery.
enum LivingTechnique {
  /// Pigment spreading through supplied silhouettes.
  watercolor,

  /// Ordered strands over linen.
  embroidery,
}

/// Authored watercolor experiments, separate from a pigment simulation.
enum WatercolorExperiment {
  /// An existing layered botanical painting.
  botanical,

  /// A wet brush touches paper and lifts away.
  contact,

  /// Deposits continue spreading behind a travelling brush.
  stroke,

  /// Blue contacts a pink base with adjustable illustrative wetness.
  layers,
}

/// Distinct thread studies: missing stitches, loose waves or a full reveal.
enum ThreadExperiment {
  /// An existing seam receives only its remaining stitches.
  finishing,

  /// Loose, nonperiodic loops tighten between fixed above/below-cloth anchors.
  passing,

  /// A botanical sprig fills in strand by strand.
  embroidery,
}

/// Original botanical geometry, independent of application artwork.
class LivingMaterialPainter extends CustomPainter {
  /// Paints only a supplied pose.
  LivingMaterialPainter(
    this.technique,
    this.progress, {
    this.experiment = WatercolorExperiment.botanical,
    this.wetness = .8,
    this.threadExperiment = ThreadExperiment.passing,
    this.remainingStitches = 4,
    this.showLooseThread = true,
    this.showNeedle = false,
  }) : assert(remainingStitches >= 1 && remainingStitches <= 8);

  /// Selected authored study.
  final LivingTechnique technique;

  /// Explicit finite completion.
  final double progress;

  /// Which original contact/layering composition to show.
  final WatercolorExperiment experiment;

  /// Illustrative base wetness, 0..1, rather than measured humidity.
  final double wetness;

  /// Above/below thread or botanical completion.
  final ThreadExperiment threadExperiment;

  /// Number of terminal stitches to add in the finishing recipe, 1..8.
  final int remainingStitches;

  /// Whether the botanical reveal includes its loose moving strand.
  final bool showLooseThread;

  /// Whether the botanical reveal includes optional needle artwork.
  final bool showNeedle;

  static final Path _embroideryPath = _embroidery();
  static Path _embroidery() {
    final seam = Path()
      ..moveTo(270, 290)
      ..cubicTo(275, 230, 330, 160, 310, 65);
    final thread = craftStitchPath(
      seam,
      kind: CraftStitchKind.backstitch,
      pitch: 9,
    );
    for (final leaf in [
      (const Offset(282, 250), const Offset(215, 200), 19.0),
      (const Offset(294, 220), const Offset(375, 178), 25.0),
      (const Offset(309, 180), const Offset(242, 125), 21.0),
      (const Offset(315, 142), const Offset(365, 102), 17.0),
    ]) {
      final vector = leaf.$2 - leaf.$1;
      final normal = Offset(-vector.dy, vector.dx) / vector.distance;
      for (var i = 1; i < 26; i++) {
        final t = i / 26;
        final center = Offset.lerp(leaf.$1, leaf.$2, t)!;
        final reach = math.sin(math.pi * t) * leaf.$3;
        final a = center + normal * reach, b = center - normal * reach;
        final from = i.isEven ? a : b, to = i.isEven ? b : a;
        thread
          ..moveTo(from.dx, from.dy)
          ..lineTo(to.dx, to.dy);
      }
    }
    return thread;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 600, size.height / 375);
    if (technique == LivingTechnique.watercolor) {
      if (experiment == WatercolorExperiment.botanical) {
        _garden(canvas);
      } else {
        _paintContact(canvas, progress, wetness, experiment);
      }
    } else {
      if (threadExperiment == ThreadExperiment.finishing) {
        _paintThreadFinish(canvas, progress, remainingStitches);
      } else if (threadExperiment == ThreadExperiment.passing) {
        _paintThreadPass(canvas, progress);
      } else {
        _sew(canvas);
      }
    }
    canvas.restore();
  }

  void _garden(Canvas canvas) {
    const paper = Color(0xFFFFFDF8);
    // Supplied petal, ribbon and leaf silhouettes give each wash its own shape.
    final ribbon = pigmentOutline(
      const Rect.fromLTWH(45, 185, 490, 140),
      seed: 41,
    );
    paintWatercolorSpread(
      canvas,
      ribbon,
      pigment: const Color(0xFF337F98),
      companion: const Color(0xFF9EBE8A),
      paper: paper,
      seed: 41,
      opacity: .58,
      progress: progress,
      origin: const Offset(215, 275),
    );
    final stem = Path()
      ..moveTo(285, 320)
      ..cubicTo(302, 240, 340, 190, 340, 135);
    paintCraftStroke(
      canvas,
      stem,
      color: const Color(0xFF658D78),
      style: const CraftStrokeStyle(tool: CraftStrokeTool.brush, width: 2.5),
      progress: progress,
    );
    for (var i = 0; i < 7; i++) {
      final angle = i * math.pi * 2 / 7;
      const center = Offset(344, 144);
      final along = Offset(math.cos(angle), math.sin(angle));
      final across = Offset(-along.dy, along.dx);
      Offset petalPoint(double x, double y) => center + across * x + along * y;
      final root = petalPoint(0, -8);
      final a = petalPoint(-34, 18),
          b = petalPoint(-39, 77),
          tip = petalPoint(3, 83);
      final c = petalPoint(40, 75), d = petalPoint(32, 10);
      final petal = Path()
        ..moveTo(root.dx, root.dy)
        ..cubicTo(a.dx, a.dy, b.dx, b.dy, tip.dx, tip.dy)
        ..cubicTo(c.dx, c.dy, d.dx, d.dy, root.dx, root.dy)
        ..close();
      paintWatercolorSpread(
        canvas,
        petal,
        pigment: i.isEven ? const Color(0xFFC2537B) : const Color(0xFFE49B78),
        companion: const Color(0xFFE6BD8D),
        paper: paper,
        seed: 17 + i * 11,
        opacity: .76,
        progress: progress,
      );
    }
    for (final leaf in [
      (const Offset(302, 255), const Offset(206, 211)),
      (const Offset(319, 212), const Offset(407, 232)),
    ]) {
      final shape = Path()
        ..moveTo(leaf.$1.dx, leaf.$1.dy)
        ..quadraticBezierTo(leaf.$2.dx, leaf.$1.dy - 55, leaf.$2.dx, leaf.$2.dy)
        ..quadraticBezierTo(leaf.$1.dx + 5, leaf.$2.dy, leaf.$1.dx, leaf.$1.dy)
        ..close();
      paintWatercolorSpread(
        canvas,
        shape,
        pigment: const Color(0xFF3F8472),
        paper: paper,
        seed: 52,
        opacity: .65,
        progress: progress,
      );
    }
    if (progress > .6) {
      final alpha = ((progress - .6) / .4).clamp(0.0, 1.0);
      for (var i = 0; i < 13; i++) {
        final a = i * 2.4, r = 3 + math.sqrt(i) * 3;
        canvas.drawCircle(
          const Offset(344, 144) + Offset(math.cos(a), math.sin(a)) * r,
          1.8,
          Paint()
            ..color = const Color(0xFF805A4B).withValues(alpha: alpha * .6),
        );
      }
    }
  }

  static final _threadMetrics = _embroideryPath.computeMetrics().toList();
  static final _threadEnds = _threadMetrics.fold<List<double>>([
    0,
  ], (ends, metric) => ends..add(ends.last + metric.length));
  void _sew(Canvas canvas) {
    final station = progress * _threadMetrics.length;
    final index = station.floor().clamp(0, _threadMetrics.length - 1);
    final phase = progress == 1 ? 1.0 : station - index;
    final above = phase < .72;
    final visible = progress == 1
        ? 1.0
        : (_threadEnds[index] +
                  _threadMetrics[index].length *
                      (phase / .72).clamp(0.0, 1.0)) /
              _threadEnds.last;
    final frame = CraftStitchFrame.sample(_embroideryPath, progress: visible);
    const color = Color(0xFF427B6D);
    frame.paint(canvas, thread: color, width: 2.1, compression: .6);
    final tip = frame.tip;
    if (tip == null || !above) return;
    final eye = tip.position;
    final slack = _strandWander(7, progress) * 12;
    final loose = Path()
      ..moveTo(eye.dx, eye.dy)
      ..cubicTo(
        eye.dx + 36,
        eye.dy + 35 + slack,
        eye.dx + 70,
        eye.dy - 60,
        eye.dx + 88,
        eye.dy - 32,
      );
    if (showNeedle) _paintStudyNeedle(canvas, eye, tip.vector);
    if (!showLooseThread) return;
    canvas.drawPath(
      loose,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(LivingMaterialPainter old) =>
      old.progress != progress ||
      old.technique != technique ||
      old.experiment != experiment ||
      old.wetness != wetness ||
      old.threadExperiment != threadExperiment ||
      old.remainingStitches != remainingStitches ||
      old.showLooseThread != showLooseThread ||
      old.showNeedle != showNeedle;
}
