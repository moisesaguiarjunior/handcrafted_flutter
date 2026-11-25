import 'dart:math' as math;

import 'package:flutter/painting.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

import 'contact_poses.dart';
import 'projected_material.dart';

/// Four generic construction recipes, not authored consumer scenes.
enum MaterialRecipe {
  /// A held textile with a visible lining and height-dependent receiver shadow.
  cloth,

  /// Articulated soft parts and a moving prop under one directional light.
  figure,

  /// Three lagged responses to one finite authored wind envelope.
  wind,

  /// Two hinges, persistent prints, reverse faces and constant thickness.
  paper,
}

/// Independent material comparison for the original soft figure.
enum FigureMaterial {
  /// Short matte fibers on a soft volume.
  felt,

  /// Woven grain with a flatter surface.
  linen,

  /// Rounded matte mass with little grain.
  clay,
}

/// One held gesture, sampled in material space with no temporal integration.
class LiftedClothFrame {
  /// The two cuts reuse the same normalized pose and fold law.
  LiftedClothFrame(double progress, ClothCut cut) {
    final pose = ClothPose(progress, cut);
    width = pose.width;
    length = pose.upperLength + pose.lowerLength;
    final fold = ((pose.lower.rotation + .08) / 2.13).clamp(0.0, 1.0);
    const thickness = 1.6;
    var center = const MaterialPoint(340, 84 + .45 * thickness, thickness / 2);
    final centers = <MaterialPoint>[center], normals = <MaterialPoint>[];
    MaterialPoint normalAt(double s) {
      final bend = gesturePhase(s, .1, .9);
      final angle =
          pose.upper.rotation +
          (pose.lower.rotation - pose.upper.rotation) * bend;
      final pitch = 2.6 * fold * gesturePhase(s, .25, .9);
      final across = MaterialPoint(math.cos(angle), math.sin(angle), 0);
      final along = MaterialPoint(
        -math.sin(angle) * math.cos(pitch),
        math.cos(angle) * math.cos(pitch),
        .22 * math.sin(pitch),
      );
      return across.cross(along).unit;
    }

    normals.add(normalAt(0));
    for (var row = 0; row < segments; row++) {
      final s = (row + .5) / segments;
      final bend = gesturePhase(s, .1, .9);
      final angle =
          pose.upper.rotation +
          (pose.lower.rotation - pose.upper.rotation) * bend;
      final pitch = 2.6 * fold * gesturePhase(s, .25, .9);
      center +=
          MaterialPoint(
            -math.sin(angle) * math.cos(pitch),
            math.cos(angle) * math.cos(pitch),
            .22 * math.sin(pitch),
          ) *
          (length / segments);
      centers.add(center);
      normals.add(normalAt((row + 1) / segments));
    }
    sheet = _strip(width, length, centers, normals, (s) {
      final angle =
          pose.upper.rotation +
          (pose.lower.rotation - pose.upper.rotation) * gesturePhase(s, .1, .9);
      return MaterialPoint(math.cos(angle), math.sin(angle), 0);
    }, thickness);
  }

  /// Bounded source strips; visible faces use at most 64 textured triangles.
  static const segments = 32;

  /// Width of the complete, fixed material source.
  late final double width;

  /// Length of the complete source; deformation is authored, not isometric.
  late final double length;

  /// Shared two-sided geometry and receiver shadow.
  late final ProjectedMaterial sheet;
}

ProjectedMaterial _strip(
  double width,
  double length,
  List<MaterialPoint> centers,
  List<MaterialPoint> normals,
  MaterialPoint Function(double) across,
  double thickness,
) {
  final count = centers.length - 1;
  final left = [
    for (var i = 0; i <= count; i++)
      centers[i] - across(i / count) * (width / 2),
  ];
  final right = [
    for (var i = 0; i <= count; i++)
      centers[i] + across(i / count) * (width / 2),
  ];
  return ProjectedMaterial([
    for (var row = 0; row < count; row++)
      MaterialCell(
        Rect.fromLTWH(0, row * length / count, width, length / count),
        [left[row], right[row], right[row + 1], left[row + 1]],
        [normals[row], normals[row], normals[row + 1], normals[row + 1]],
        thickness,
      ),
  ]);
}

/// An accordion with two authored hinges and an unchanging material source.
class FoldedPaperFrame {
  /// Starts folded, then opens each hinge with a small finite delay.
  FoldedPaperFrame(double progress) {
    checkGestureProgress(progress);
    // Absolute panel tilts stay nonnegative: both hinges open without
    // sweeping the final panel through the receiving board.
    angles = [
      0.0,
      2.4 * (1 - gesturePhase(progress, .1, .75)),
      .5 * (1 - gesturePhase(progress, .25, 1)),
    ];
    var hinge = const MaterialPoint(200, 120 + .45 * thickness, thickness / 2);
    final cells = <MaterialCell>[];
    hinges = [hinge];
    for (var panel = 0; panel < 3; panel++) {
      final a = angles[panel];
      final u = MaterialPoint(math.cos(a), 0, math.sin(a));
      final v = const MaterialPoint(0, 1, 0);
      final n = u.cross(v).unit;
      final next = hinge + u * panelWidth;
      cells.add(
        MaterialCell(
          Rect.fromLTWH(panel * panelWidth, 0, panelWidth, size.height),
          [hinge, next, next + v * size.height, hinge + v * size.height],
          [n, n, n, n],
          thickness,
        ),
      );
      hinge = next;
      hinges.add(hinge);
    }
    sheet = ProjectedMaterial(cells);
  }

  /// Stable source dimensions shared by both prints.
  static const size = Size(240, 144);

  /// Each of the three source panels is the same width.
  static const panelWidth = 80.0;

  /// Actual separation of paired world vertices throughout the entire gesture.
  static const thickness = .8;

  /// Absolute world angle for each panel, in material order.
  late final List<double> angles;

  /// The same world hinge is used by both neighboring panels.
  late final List<MaterialPoint> hinges;

  /// Visible faces, depth order, attachments and shadow share this geometry.
  late final ProjectedMaterial sheet;
}

/// One source envelope sampled with independent lag/amplitude per object.
class AuthoredGust {
  /// Supplies one finite pulse. It is a choreography, not a fluid/wind solver.
  AuthoredGust(double progress, {double strength = 1}) {
    checkGestureProgress(progress);
    if (!strength.isFinite || strength < 0 || strength > 1) {
      throw ArgumentError('Expected wind strength in 0..1');
    }
    double pulse(double start, double end) {
      if (progress <= start || progress >= end) return 0;
      final t = (progress - start) / (end - start);
      return math.pow(math.sin(math.pi * t), 2).toDouble() * strength;
    }

    curtain = pulse(.05, .76);
    note = pulse(.24, .9);
    plant = pulse(.36, 1);
  }

  /// Optional caller-owned response curves, already sampled by its own clock.
  AuthoredGust.responses({
    required this.curtain,
    required this.note,
    required this.plant,
  }) {
    if ([curtain, note, plant].any((v) => !v.isFinite || v < 0 || v > 1)) {
      throw ArgumentError('Expected finite gust responses in 0..1');
    }
  }

  /// Earliest response, with a pinned upper rail.
  late final double curtain;

  /// Delayed paper response, while one edge remains held.
  late final double note;

  /// Latest plant response; its silhouette also produces its shadow.
  late final double plant;
}

/// A curtain, a hinged note and a plant all sample the same authored gust.
class WindMaterialFrame {
  /// Retains support geometry and fixed source prints through all responses.
  WindMaterialFrame(
    double progress, {
    double strength = 1,
    AuthoredGust? supplied,
  }) {
    checkGestureProgress(progress);
    gust = supplied ?? AuthoredGust(progress, strength: strength);
    final centers = <MaterialPoint>[], normals = <MaterialPoint>[];
    for (var i = 0; i <= 24; i++) {
      final s = i / 24;
      final z = gust.curtain * 18 * math.pow(math.sin(math.pi * s), 2);
      final slope =
          gust.curtain *
          18 *
          math.pi *
          math.sin(2 * math.pi * s) /
          curtainSize.height;
      centers.add(
        MaterialPoint(
          175 + gust.curtain * 12 * s * s,
          58 + s * curtainSize.height,
          1 + z,
        ),
      );
      normals.add(MaterialPoint(0, -slope, 1).unit);
    }
    curtain = _strip(
      curtainSize.width,
      curtainSize.height,
      centers,
      normals,
      (_) => const MaterialPoint(1, 0, 0),
      1,
    );
    final angle = gust.note * .45;
    final a = const MaterialPoint(345, 218 + .45 * .8, .4);
    final across = MaterialPoint(math.cos(angle), 0, math.sin(angle));
    final down = const MaterialPoint(0, 1, 0), n = across.cross(down).unit;
    note = ProjectedMaterial([
      MaterialCell(
        Offset.zero & noteSize,
        [
          a,
          a + across * noteSize.width,
          a + across * noteSize.width + down * noteSize.height,
          a + down * noteSize.height,
        ],
        [n, n, n, n],
        .8,
      ),
    ]);
    plantPose = PartPose(rotation: gust.plant * .2);
  }

  /// Bounded curtain source, painted once per side.
  static const curtainSize = Size(150, 190);

  /// Note print source, hinged at its left edge.
  static const noteSize = Size(130, 78);

  /// Shared wind input with distinct object responses.
  late final AuthoredGust gust;

  /// Both top corners remain fixed despite the lower fabric response.
  late final ProjectedMaterial curtain;

  /// The entire left edge remains supported before/after its free edge lifts.
  late final ProjectedMaterial note;

  /// The same rigid transform moves the plant and its shadow silhouette.
  late final PartPose plantPose;
}

/// Native recipe labels, also used by captures.
String materialRecipeTitle(MaterialRecipe recipe) => switch (recipe) {
  MaterialRecipe.cloth => 'A lined textile',
  MaterialRecipe.figure => 'A small helping hand',
  MaterialRecipe.wind => 'One passing breeze',
  MaterialRecipe.paper => 'Two folds, one print',
};

/// Honest construction contract displayed next to each visual proof.
String materialRecipeDescription(MaterialRecipe recipe) => switch (recipe) {
  MaterialRecipe.cloth =>
    'A pinned shoulder, a lining and a delayed cuff. Height changes the shadow. This is an authored compressible strip, not cloth simulation.',
  MaterialRecipe.figure =>
    'A soft figure reaches the stool, then pulls it closer. Two fixed-length links keep the hand attached. One light illuminates felt, linen or matte clay.',
  MaterialRecipe.wind =>
    'One finite breeze reaches the curtain, the held note and the plant at different times. Their prints and shadows follow their geometry.',
  MaterialRecipe.paper =>
    'A single printed sheet opens along two hinges. Front, reverse and cut edges share the same material coordinates. This is an authored accordion, not arbitrary paper folding.',
};
