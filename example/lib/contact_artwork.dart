import 'package:flutter/material.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

import 'contact_poses.dart';
import 'continuous_cloth.dart';
import 'showcase_theme.dart';

/// Statelessly sampled artwork; textures live only as long as this board.
class ContactArtwork extends StatefulWidget {
  /// Creates an example-owned transfer or articulated textile specimen.
  const ContactArtwork({
    super.key,
    required this.progress,
    this.cloth = false,
    this.continuous = false,
    this.cut = ClothCut.sleeve,
    this.contacts = false,
    this.cameraAngle = 0,
  });

  /// External, finite timeline fraction; there is no clock in the artwork.
  final double progress;

  /// Selects the articulated textile instead of the paper transfer.
  final bool cloth;

  /// Opt-in continuous planar strip; the original articulated recipe is retained.
  final bool continuous;

  /// Independent material cut for the textile recipe.
  final ClothCut cut;

  /// Shows contact guides without changing the choreography.
  final bool contacts;

  /// Parent camera rotation, independent of all local contacts.
  final double cameraAngle;

  @override
  State<ContactArtwork> createState() => _ContactArtworkState();
}

class _ContactArtworkState extends State<ContactArtwork> {
  final textures = MaterialTextures(seed: 117);
  final clothCuts = {
    for (final cut in ClothCut.values) cut: _ClothResources(cut),
  };

  final prints = <ClothCut, ClothPrint>{};
  ContinuousClothFrame? continuousFrame;
  double? previousProgress;
  ClothCut? previousCut;

  @override
  void dispose() {
    for (final print in prints.values) {
      print.dispose();
    }
    textures.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transfer = TransferPose(widget.progress);
    final cloth = ClothPose(widget.progress, widget.cut);
    if (widget.cloth &&
        widget.continuous &&
        (previousProgress != widget.progress || previousCut != widget.cut)) {
      continuousFrame = ContinuousClothFrame(widget.progress, widget.cut);
      previousProgress = widget.progress;
      previousCut = widget.cut;
    }
    return ExcludeSemantics(
      child: IgnorePointer(
        child: AspectRatio(
          aspectRatio: 640 / 360,
          child: ClipRect(
            child: FittedBox(
              child: RepaintBoundary(
                child: CraftPart(
                  key: const ValueKey('contact-camera'),
                  size: const Size(640, 360),
                  pivot: Alignment.center,
                  pose: PartPose(rotation: widget.cameraAngle),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(painter: _BoardPainter(textures)),
                      ),
                      if (widget.cloth)
                        Positioned.fill(
                          child: CustomPaint(
                            painter: widget.continuous
                                ? _ContinuousPainter(
                                    continuousFrame!,
                                    prints.putIfAbsent(
                                      widget.cut,
                                      () => ClothPrint.prepare(
                                        textures,
                                        widget.cut,
                                      ),
                                    ),
                                    widget.contacts,
                                  )
                                : _ClothPainter(
                                    textures,
                                    cloth,
                                    clothCuts[widget.cut]!,
                                    widget.contacts,
                                  ),
                          ),
                        )
                      else ...[
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _HandsPainter(
                              textures,
                              transfer,
                              front: false,
                              contacts: widget.contacts,
                            ),
                          ),
                        ),
                        Positioned(
                          left: TransferPose.sheetOrigin.dx,
                          top: TransferPose.sheetOrigin.dy,
                          child: CraftPart(
                            key: const ValueKey('transfer-sheet'),
                            size: TransferPose.sheetSize,
                            pivot: Alignment.center,
                            pose: transfer.sheet,
                            child: CustomPaint(
                              painter: _SheetPainter(textures),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _HandsPainter(
                              textures,
                              transfer,
                              front: true,
                              contacts: widget.contacts,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BoardPainter extends CustomPainter {
  const _BoardPainter(this.textures);
  final MaterialTextures textures;
  @override
  void paint(Canvas canvas, Size size) {
    textures.paint(
      canvas,
      Path()..addRect(Offset.zero & size),
      material: CraftMaterial.paper,
      color: DemoPalette.board,
      strength: .35,
    );
    canvas.drawLine(
      const Offset(70, 302),
      const Offset(570, 302),
      Paint()
        ..color = DemoPalette.wood.withValues(alpha: .3)
        ..strokeWidth = 1,
    );
  }

  @override
  bool shouldRepaint(_BoardPainter old) => textures != old.textures;
}

class _SheetPainter extends CustomPainter {
  const _SheetPainter(this.textures);
  final MaterialTextures textures;
  @override
  void paint(Canvas canvas, Size size) {
    final cut = Path()
      ..moveTo(1, 5)
      ..lineTo(size.width - 3, 0)
      ..lineTo(size.width, size.height - 4)
      ..lineTo(4, size.height)
      ..close();
    canvas.drawShadow(cut, DemoPalette.ink.withValues(alpha: .22), 5, false);
    textures.paint(
      canvas,
      cut,
      material: CraftMaterial.paper,
      color: DemoPalette.paper,
      strength: .65,
    );
    final stem = Path()
      ..moveTo(91, 104)
      ..cubicTo(83, 77, 111, 53, 92, 36);
    paintCraftStroke(
      canvas,
      stem,
      color: DemoPalette.sage,
      style: const CraftStrokeStyle(width: 2.5),
    );
    for (final leaf in [
      const Rect.fromLTWH(68, 62, 25, 12),
      const Rect.fromLTWH(97, 78, 25, 12),
    ]) {
      canvas.drawOval(leaf, Paint()..color = DemoPalette.sage);
    }
    for (final offset in [
      const Offset(82, 34),
      const Offset(95, 25),
      const Offset(107, 37),
      const Offset(94, 46),
    ]) {
      canvas.drawOval(
        Rect.fromCenter(center: offset, width: 17, height: 21),
        Paint()..color = DemoPalette.rose.withValues(alpha: .85),
      );
    }
    canvas.drawCircle(
      const Offset(94, 36),
      5,
      Paint()..color = DemoPalette.ochre,
    );
  }

  @override
  bool shouldRepaint(_SheetPainter old) => textures != old.textures;
}

class _HandsPainter extends CustomPainter {
  const _HandsPainter(
    this.textures,
    this.pose, {
    required this.front,
    required this.contacts,
  });
  final MaterialTextures textures;
  final TransferPose pose;
  final bool front, contacts;

  @override
  void paint(Canvas canvas, Size size) {
    for (final left in [true, false]) {
      final matrix = pose.handMatrix(left);
      final x = left ? 0.0 : TransferPose.sheetSize.width;
      if (!front) {
        final wrist = MatrixUtils.transformPoint(matrix, Offset(x, 103));
        final shoulder = Offset(left ? 69 : 571, 268);
        final c1 = Offset.lerp(shoulder, wrist, .35)! + const Offset(0, -20);
        final c2 = wrist + Offset(left ? -44 : 44, 12);
        final v0 = c1 - shoulder, v1 = wrist - c2;
        final n0 = Offset(-v0.dy, v0.dx) / v0.distance;
        final n1 = Offset(-v1.dy, v1.dx) / v1.distance;
        final a = shoulder + n0 * 18, b = wrist + n1 * 16;
        final c = wrist - n1 * 16, d = shoulder - n0 * 18;
        final sleeve = Path()
          ..moveTo(a.dx, a.dy)
          ..cubicTo(
            c1.dx + n0.dx * 18,
            c1.dy + n0.dy * 18,
            c2.dx + n1.dx * 16,
            c2.dy + n1.dy * 16,
            b.dx,
            b.dy,
          )
          ..lineTo(c.dx, c.dy)
          ..cubicTo(
            c2.dx - n1.dx * 16,
            c2.dy - n1.dy * 16,
            c1.dx - n0.dx * 18,
            c1.dy - n0.dy * 18,
            d.dx,
            d.dy,
          )
          ..close();
        canvas.drawShadow(sleeve, const Color(0x223D342B), 3, false);
        textures.paint(
          canvas,
          sleeve,
          material: CraftMaterial.cotton,
          color: left ? DemoPalette.rose : DemoPalette.indigo,
          strength: .7,
        );
      }
      canvas.save();
      try {
        canvas.transform(matrix.storage);
        final hand = front
            ? TransferPose.fingers(left)
            : (Path()..addRRect(
                RRect.fromRectAndRadius(
                  Rect.fromLTWH(left ? -23 : x - 2, 76, 25, 40),
                  const Radius.circular(11),
                ),
              ));
        if (front) {
          canvas.drawShadow(hand, const Color(0x163D342B), 1, false);
        }
        textures.paint(
          canvas,
          hand,
          material: CraftMaterial.felt,
          color: DemoPalette.cream,
          strength: .55,
        );
      } finally {
        canvas.restore();
      }
      if (front && contacts) {
        _pin(
          canvas,
          pose.contact(left),
          left ? pose.leftSupports : pose.rightSupports,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_HandsPainter old) => true;
}

class _ClothResources {
  _ClothResources(ClothCut cut) {
    final pose = ClothPose(0, cut);
    final total = pose.upperLength + pose.lowerLength;
    source = Path()..addRect(Rect.fromLTWH(0, -12, pose.width, total + 36));
    seam = CraftStitchFrame.sample(
      craftStitchPath(
        Path()
          ..moveTo(7, 0)
          ..lineTo(7, total)
          ..moveTo(pose.width - 7, 0)
          ..lineTo(pose.width - 7, total),
        pitch: 8,
      ),
      progress: 1,
    );
    cuts = [
      for (final length in [pose.upperLength, pose.lowerLength])
        Path()..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(0, -10, pose.width, length + 22),
            const Radius.circular(18),
          ),
        ),
    ];
    volumes = [
      for (final path in cuts)
        CraftVolume(path, CraftVolumeProfile.rounded, height: 4, bevel: 12),
    ];
  }
  late final Path source;
  late final CraftStitchFrame seam;
  late final List<Path> cuts;
  late final List<CraftVolume> volumes;
}

class _ClothPainter extends CustomPainter {
  const _ClothPainter(this.textures, this.pose, this.resources, this.contacts);
  final MaterialTextures textures;
  final ClothPose pose;
  final _ClothResources resources;
  final bool contacts;

  @override
  void paint(Canvas canvas, Size size) {
    final light = CraftLight(x: -1, y: -1, z: 1.6, softness: .7);
    _paintSupport(canvas);
    for (var i = 0; i < 2; i++) {
      final upper = i == 0;
      final origin = upper ? pose.upperOrigin : pose.lowerOrigin;
      final part = upper ? pose.upper : pose.lower;
      final length = upper ? pose.upperLength : pose.lowerLength;
      final sourceY = upper ? 0.0 : pose.upperLength;
      canvas.save();
      try {
        canvas.translate(origin.dx, origin.dy);
        canvas.transform(
          part.matrixFor(Size(pose.width, length), Alignment.topCenter).storage,
        );
        final localLight = light.inLocalSpace(part.rotation);
        resources.volumes[i].shadow(canvas, localLight, lift: upper ? 3 : 7);
        canvas.save();
        try {
          canvas.clipPath(resources.cuts[i]);
          canvas.translate(0, -sourceY);
          textures.paint(
            canvas,
            resources.source,
            material: CraftMaterial.linen,
            color: DemoPalette.sage,
            strength: .8,
          );
          // Printed marks and sewing share one material-space origin.
          for (var row = 0; row < 16; row++) {
            canvas.drawLine(
              Offset(12, row * 16.0),
              Offset(pose.width - 12, row * 16.0),
              Paint()
                ..color = DemoPalette.paper.withValues(alpha: .27)
                ..strokeWidth = 2,
            );
          }
          resources.seam.paint(canvas, thread: DemoPalette.cream, width: 1.25);
        } finally {
          canvas.restore();
        }
        resources.volumes[i].shade(canvas, localLight);
        if (!upper) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(3, length - 14, pose.width - 6, 16),
              const Radius.circular(5),
            ),
            Paint()..color = DemoPalette.indigo.withValues(alpha: .75),
          );
        }
      } finally {
        canvas.restore();
      }
    }
    if (contacts) {
      _pin(canvas, ClothPose.shoulder, true);
      _pin(canvas, pose.elbow, true);
      _pin(canvas, pose.cuff, false);
    }
  }

  @override
  bool shouldRepaint(_ClothPainter old) => true;
}

void _pin(Canvas canvas, Offset point, bool held) {
  canvas.drawCircle(point, 5, Paint()..color = DemoPalette.paper);
  canvas.drawCircle(
    point,
    3,
    Paint()..color = held ? DemoPalette.indigo : DemoPalette.terracotta,
  );
}

class _ContinuousPainter extends CustomPainter {
  const _ContinuousPainter(this.frame, this.print, this.contacts);
  final ContinuousClothFrame frame;
  final ClothPrint print;
  final bool contacts;
  @override
  void paint(Canvas canvas, Size size) {
    _paintSupport(canvas);
    frame.paint(canvas, print, guides: contacts);
  }

  @override
  bool shouldRepaint(_ContinuousPainter old) =>
      frame != old.frame || print != old.print || contacts != old.contacts;
}

void _paintSupport(Canvas canvas) {
  canvas.drawLine(
    const Offset(238, 65),
    const Offset(442, 65),
    Paint()
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..color = DemoPalette.wood,
  );
  canvas.drawLine(
    const Offset(340, 65),
    ClothPose.shoulder,
    Paint()..color = DemoPalette.wood,
  );
}
