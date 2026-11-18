import 'dart:math' as math;
import 'dart:ui' show Tangent;

import 'package:flutter/material.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

import 'showcase_theme.dart';

/// Original leather tag used as the project mark in documentation.
///
/// Every layer uses public renderers: leather grain, contour seam, running
/// stitch with recessed punctures, raised edge, twisted cord and native
/// pressed lettering. Nothing is imported artwork.
class LeatherBrandMark extends StatefulWidget {
  /// Creates the mark at the size supplied by its parent.
  const LeatherBrandMark({
    super.key,
    this.title = 'handcrafted',
    this.subtitle = 'FOR FLUTTER',
  });

  /// Pressed title, kept as real text.
  final String title;

  /// Smaller pressed line under the title.
  final String subtitle;

  @override
  State<LeatherBrandMark> createState() => _LeatherBrandMarkState();
}

class _LeatherBrandMarkState extends State<LeatherBrandMark> {
  final textures = MaterialTextures(seed: 29);
  _TagGeometry? geometry;

  @override
  void dispose() {
    textures.dispose();
    super.dispose();
  }

  _TagGeometry _geometryFor(Size size) {
    final cached = geometry;
    if (cached != null && cached.size == size) return cached;
    return geometry = _TagGeometry(size);
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      // The decoration scales from a bounded artboard; preparing geometry at
      // unrestricted display dimensions would exceed stitch and inset budgets.
      final size = Size(
        math.min(box.maxWidth, 1200),
        math.min(box.maxHeight, 400),
      );
      final tag = _geometryFor(size);
      final ink = Color.lerp(DemoPalette.cognac, Colors.black, .38)!;
      return FittedBox(
        fit: BoxFit.contain,
        child: SizedBox.fromSize(
          size: size,
          child: Stack(
            children: [
              Positioned.fill(
                child: ExcludeSemantics(
                  child: CustomPaint(painter: _TagPainter(textures, tag)),
                ),
              ),
              Positioned.fromRect(
                rect: tag.label,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CraftReliefText(
                        widget.title,
                        depth: 2,
                        style: TextStyle(
                          fontFamily: 'Caveat',
                          fontWeight: FontWeight.w700,
                          fontSize: tag.body.height * .42,
                          height: 1,
                          color: ink,
                        ),
                      ),
                      SizedBox(height: tag.body.height * .03),
                      CraftReliefText(
                        widget.subtitle,
                        depth: 1.2,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                          fontSize: tag.body.height * .075,
                          letterSpacing: tag.body.height * .04,
                          color: ink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Size-dependent paths, prepared once per layout size, never per frame.
class _TagGeometry {
  _TagGeometry(this.size) {
    final height = math.min(size.height * .72, size.width * .3);
    final width = math.min(size.width * .7, height * 2.9);
    body = Rect.fromCenter(
      center: size.center(Offset(width * .04, 0)),
      width: width,
      height: height,
    );
    final chamfer = height * .3;
    final radius = height * .12;
    final b = body;
    outline = Path()
      ..moveTo(b.left + chamfer, b.top)
      ..lineTo(b.right - radius, b.top)
      ..arcToPoint(
        Offset(b.right, b.top + radius),
        radius: Radius.circular(radius),
      )
      ..lineTo(b.right, b.bottom - radius)
      ..arcToPoint(
        Offset(b.right - radius, b.bottom),
        radius: Radius.circular(radius),
      )
      ..lineTo(b.left + chamfer, b.bottom)
      ..lineTo(b.left, b.bottom - chamfer)
      ..lineTo(b.left, b.top + chamfer)
      ..close();
    hole = Offset(b.left + height * .24, b.center.dy);
    holeRadius = height * .065;
    final punched = Path()
      ..fillType = PathFillType.evenOdd
      ..addPath(outline, Offset.zero)
      ..addOval(Rect.fromCircle(center: hole, radius: holeRadius));
    leather = punched;
    seam = insetCraftPath(outline, distance: height * .075, sampleSpacing: 1);
    label = Rect.fromLTRB(
      hole.dx + height * .35,
      b.top + height * .14,
      b.right - height * .16,
      b.bottom - height * .14,
    );
    // The cord leaves the eyelet over the leather, loops off the left edge and
    // returns with a loose end; both runs start at the eyelet.
    final h = hole;
    upper = craftCurveThrough([
      h,
      h + Offset(-height * .38, -height * .32),
      h + Offset(-height * .9, -height * .34),
      Offset(math.max(4, h.dx - height * 1.6), b.top - height * .02),
    ]);
    lower = craftCurveThrough([
      h,
      h + Offset(-height * .32, height * .2),
      h + Offset(-height * .62, height * .36),
      h + Offset(-height * .78, height * .58),
    ]);
  }

  final Size size;
  late final Rect body, label;
  late final Path outline, leather, seam, upper, lower;
  late final Offset hole;
  late final double holeRadius;
}

const _minDetail = 48.0, _maxDetail = 900.0;

class _TagPainter extends CustomPainter {
  const _TagPainter(this.textures, this.tag);
  final MaterialTextures textures;
  final _TagGeometry tag;

  @override
  void paint(Canvas canvas, Size size) {
    if (tag.body.isEmpty) return;
    final h = tag.body.height;
    // Thread, cord and eyelet need a readable size and stay inside the shared
    // stitch/trim work limits; outside that range the tag is plain leather.
    final detailed = h >= _minDetail && h <= _maxDetail;
    canvas.drawShadow(tag.leather, const Color(0x66311A0A), h * .05, false);
    textures.paint(
      canvas,
      tag.leather,
      material: CraftMaterial.leather,
      color: DemoPalette.cognac,
      // Grain follows the tag size; 288px tall is the documentation capture.
      scale: (h / 288).clamp(.5, 1.0),
    );
    // A soft top-left sheen and a darker burnished edge read as finished hide.
    canvas.save();
    canvas.clipPath(tag.leather);
    canvas.drawRect(
      tag.body,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-.5, -.9),
          radius: 1.3,
          colors: const [
            Color(0x2EFFE9CF),
            Color(0x00FFFFFF),
            Color(0x26000000),
          ],
          stops: const [0, .55, 1],
        ).createShader(tag.body),
    );
    canvas.drawPath(
      tag.outline,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = h * .05
        ..color = const Color(0x40200C02),
    );
    if (detailed) {
      paintRunningStitch(
        canvas,
        tag.seam,
        thread: DemoPalette.cream,
        dash: h * .05,
        gap: h * .026,
        width: h * .019,
        compression: .6,
        irregularity: .35,
        pucker: .12,
        seed: 31,
      );
    }
    canvas.restore();
    paintCraftRelief(
      canvas,
      tag.outline,
      kind: CraftReliefKind.raised,
      depth: 3,
      strength: .55,
    );
    if (!detailed) return;
    _eyelet(canvas, h);
    for (final (path, end) in [(tag.lower, true), (tag.upper, false)]) {
      paintCraftTrim(
        canvas,
        path,
        color: DemoPalette.cream,
        width: h * .052,
        pitch: h * .05,
        strandColors: const [DemoPalette.cream, DemoPalette.indigo],
      );
      if (end) {
        final metric = path.computeMetrics().last;
        final tip = metric.getTangentForOffset(metric.length);
        if (tip != null) _fray(canvas, tip, h);
      }
    }
  }

  void _eyelet(Canvas canvas, double h) {
    final ring = Rect.fromCircle(
      center: tag.hole,
      radius: tag.holeRadius * 1.7,
    );
    canvas.drawCircle(
      tag.hole + const Offset(1.5, 2),
      tag.holeRadius * 1.7,
      Paint()..color = const Color(0x55000000),
    );
    canvas.drawCircle(
      tag.hole,
      tag.holeRadius * 1.35,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = tag.holeRadius * .7
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF2D9A0), Color(0xFFB98E46), Color(0xFF7A5A26)],
        ).createShader(ring),
    );
    canvas.drawCircle(
      tag.hole,
      tag.holeRadius,
      Paint()
        ..color = const Color(0x33000000)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
  }

  /// Short loose fibers where the cord ends.
  void _fray(Canvas canvas, Tangent tip, double h) {
    final random = math.Random(5);
    final along = tip.vector;
    final across = Offset(-along.dy, along.dx);
    for (var i = 0; i < 14; i++) {
      final start =
          tip.position + across * ((random.nextDouble() - .5) * h * .045);
      final end =
          start +
          along * (h * (.03 + random.nextDouble() * .05)) +
          across * ((random.nextDouble() - .5) * h * .05);
      canvas.drawLine(
        start,
        end,
        Paint()
          ..strokeWidth = .9
          ..strokeCap = StrokeCap.round
          ..color = (i.isEven ? DemoPalette.cream : DemoPalette.indigo)
              .withValues(alpha: .8),
      );
    }
  }

  @override
  bool shouldRepaint(_TagPainter old) =>
      old.textures != textures || old.tag != tag;
}
