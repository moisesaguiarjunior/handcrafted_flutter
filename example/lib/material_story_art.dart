import 'package:flutter/material.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

import 'contact_poses.dart';
import 'gesture_surfaces.dart';
import 'material_board.dart';
import 'projected_material.dart';
import 'showcase_theme.dart';
import 'soft_figure.dart';
import 'wind_art.dart';

/// Decorative recipes sampled from one caller-owned finite progress.
class MaterialStoryArtwork extends StatefulWidget {
  /// Creates an original recipe, without a clock, content or input policy.
  const MaterialStoryArtwork({
    super.key,
    required this.recipe,
    required this.progress,
    this.cut = ClothCut.sleeve,
    this.material = FigureMaterial.felt,
    this.guides = false,
    this.cameraAngle = 0,
    this.lightFromRight = false,
    this.windStrength = 1,
  });

  /// Which bounded recipe to construct.
  final MaterialRecipe recipe;

  /// Externally supplied gesture fraction, including random-access exports.
  final double progress;

  /// Independent textile dimensions.
  final ClothCut cut;

  /// Substrate comparison for the soft figure.
  final FigureMaterial material;

  /// Optional attachment/material coordinates.
  final bool guides;

  /// Parent artboard rotation, shared with every mapped attachment.
  final double cameraAngle;

  /// Changes only the shared directional source, not prepared material geometry.
  final bool lightFromRight;

  /// Independent amplitude of the shared authored gust.
  final double windStrength;
  @override
  State<MaterialStoryArtwork> createState() => _MaterialStoryArtworkState();
}

class _MaterialStoryArtworkState extends State<MaterialStoryArtwork> {
  final textures = MaterialTextures(seed: 143);
  final prints = <String, PrintedMaterial>{};
  final figureArt = SoftFigureArt();
  final windArt = WindArt();
  ProjectedMaterial? surface;
  WindMaterialFrame? wind;
  double? previousProgress, previousStrength;
  ClothCut? previousCut;
  MaterialRecipe? previousRecipe;

  PrintedMaterial printed(String key, Size size, {bool paper = false}) =>
      prints.putIfAbsent(
        key,
        () => PrintedMaterial(
          size,
          textures,
          material: paper ? CraftMaterial.paper : CraftMaterial.linen,
          frontColor: paper ? DemoPalette.paper : DemoPalette.sage,
          backColor: paper ? const Color(0xFFAFD0E3) : DemoPalette.ochre,
          paper: paper,
        ),
      );

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
    checkGestureProgress(widget.progress);
    if (previousProgress != widget.progress ||
        previousCut != widget.cut ||
        previousRecipe != widget.recipe ||
        previousStrength != widget.windStrength) {
      switch (widget.recipe) {
        case MaterialRecipe.cloth:
          surface = LiftedClothFrame(widget.progress, widget.cut).sheet;
        case MaterialRecipe.paper:
          surface = FoldedPaperFrame(widget.progress).sheet;
        case MaterialRecipe.wind:
          wind = WindMaterialFrame(
            widget.progress,
            strength: widget.windStrength,
          );
          surface = wind!.curtain;
        case MaterialRecipe.figure:
          surface = null;
      }
      previousProgress = widget.progress;
      previousCut = widget.cut;
      previousRecipe = widget.recipe;
      previousStrength = widget.windStrength;
    }
    PrintedMaterial? print;
    if (widget.recipe == MaterialRecipe.cloth) {
      final pose = ClothPose(0, widget.cut);
      print = printed(
        widget.cut.name,
        Size(pose.width, pose.upperLength + pose.lowerLength),
      );
    } else if (widget.recipe == MaterialRecipe.paper) {
      print = printed('paper', FoldedPaperFrame.size, paper: true);
    } else if (widget.recipe == MaterialRecipe.wind) {
      print = printed('curtain', WindMaterialFrame.curtainSize);
    }
    final light = CraftLight(
      x: widget.lightFromRight ? 1 : -1,
      y: -1,
      z: 1.6,
      ambient: .67,
      direct: .45,
      softness: .6,
      warmth: .3,
    );
    return ExcludeSemantics(
      child: IgnorePointer(
        child: AspectRatio(
          aspectRatio: 640 / 360,
          child: ClipRect(
            child: FittedBox(
              child: RepaintBoundary(
                child: CraftPart(
                  key: const ValueKey('story-camera'),
                  size: const Size(640, 360),
                  pivot: Alignment.center,
                  pose: PartPose(rotation: widget.cameraAngle),
                  child: CustomPaint(
                    painter: _SurfaceStoryPainter(
                      textures,
                      widget.recipe,
                      surface,
                      print,
                      light,
                      widget.guides,
                      figureArt,
                      SoftFigureFrame(widget.progress),
                      widget.material,
                      windArt,
                      wind,
                      widget.recipe == MaterialRecipe.wind
                          ? printed(
                              'note',
                              WindMaterialFrame.noteSize,
                              paper: true,
                            )
                          : null,
                    ),
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

class _SurfaceStoryPainter extends CustomPainter {
  const _SurfaceStoryPainter(
    this.textures,
    this.recipe,
    this.surface,
    this.print,
    this.light,
    this.guides,
    this.figureArt,
    this.figure,
    this.material,
    this.windArt,
    this.wind,
    this.note,
  );
  final MaterialTextures textures;
  final MaterialRecipe recipe;
  final ProjectedMaterial? surface;
  final PrintedMaterial? print;
  final CraftLight light;
  final bool guides;
  final SoftFigureArt figureArt;
  final SoftFigureFrame figure;
  final FigureMaterial material;
  final WindArt windArt;
  final WindMaterialFrame? wind;
  final PrintedMaterial? note;
  @override
  void paint(Canvas canvas, Size size) {
    paintMaterialBoard(canvas, size, textures);
    if (recipe == MaterialRecipe.figure) {
      figureArt.paint(
        canvas,
        figure,
        material,
        textures,
        light,
        guides: guides,
      );
      return;
    }
    if (surface == null || print == null) return;
    if (recipe == MaterialRecipe.cloth || recipe == MaterialRecipe.wind) {
      final cloth = recipe == MaterialRecipe.cloth;
      final left = cloth ? const Offset(240, 66) : const Offset(90, 44);
      final right = cloth ? const Offset(440, 66) : const Offset(260, 44);
      canvas.drawLine(
        left,
        right,
        Paint()
          ..color = DemoPalette.wood
          ..strokeWidth = 6
          ..strokeCap = StrokeCap.round,
      );
      for (final x
          in cloth ? [print!.size.width / 2] : [4.0, print!.size.width - 4]) {
        final p = surface!.cells.first.map(Offset(x, 0)).screen;
        canvas.drawLine(
          Offset(p.dx, left.dy),
          p,
          Paint()
            ..color = DemoPalette.wood
            ..strokeWidth = 2,
        );
        canvas.drawCircle(p, 4, Paint()..color = DemoPalette.cream);
      }
    }
    surface!.paint(canvas, print!, light);
    if (recipe == MaterialRecipe.wind) {
      windArt.paint(canvas, wind!, note!, textures, light, guides: guides);
    }
    if (guides) {
      for (final point in [
        Offset(print!.size.width / 2, 0),
        Offset(print!.size.width / 2, print!.size.height * .5),
        Offset(print!.size.width / 2, print!.size.height - .01),
      ]) {
        canvas.drawCircle(
          surface!.surfacePoint(point).screen,
          4,
          Paint()
            ..color = point.dy == 0
                ? DemoPalette.indigo
                : DemoPalette.terracotta,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_SurfaceStoryPainter old) => true;
}
