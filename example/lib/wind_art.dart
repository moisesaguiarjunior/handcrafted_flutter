import 'package:flutter/material.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

import 'gesture_surfaces.dart';
import 'projected_material.dart';
import 'showcase_theme.dart';

/// Prepared original plant silhouette. Its transformed cut also casts the
/// height-projected ground shadow; there is no separately animated shadow blob.
class WindArt {
  /// Fixed seeded-free leaf/stem silhouette.
  final foliage = Path()
    ..addOval(const Rect.fromLTWH(-25, -45, 25, 12))
    ..addOval(const Rect.fromLTWH(0, -58, 25, 12))
    ..addOval(const Rect.fromLTWH(-18, -69, 18, 12))
    ..addRect(const Rect.fromLTWH(-1.5, -60, 3, 47));

  /// Same matrix as painting, then projection from height onto the board.
  Path plantShadow(WindMaterialFrame frame, CraftLight light) {
    final moved = foliage.transform(
      frame.plantPose.matrixFor(Size.zero, Alignment.topLeft).storage,
    );
    final projection = Matrix4.identity();
    projection.setEntry(0, 1, light.x / (.45 * light.z));
    projection.setEntry(1, 1, light.y / (.45 * light.z));
    return moved.transform(projection.storage).shift(const Offset(520, 281));
  }

  /// Paints the transformed plant and a hand supporting the note margin.
  void paint(
    Canvas c,
    WindMaterialFrame frame,
    PrintedMaterial note,
    MaterialTextures textures,
    CraftLight light, {
    bool guides = false,
  }) {
    c.drawPath(
      plantShadow(frame, light),
      Paint()
        ..color = DemoPalette.ink.withValues(alpha: .13)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    c.save();
    c.translate(520, 281);
    c.transform(
      frame.plantPose.matrixFor(Size.zero, Alignment.topLeft).storage,
    );
    textures.paint(
      c,
      foliage,
      material: CraftMaterial.paper,
      color: DemoPalette.sage,
    );
    c.restore();
    textures.paint(
      c,
      Path()
        ..moveTo(509, 264)
        ..lineTo(531, 264)
        ..lineTo(528, 284)
        ..lineTo(512, 284)
        ..close(),
      material: CraftMaterial.eva,
      color: DemoPalette.terracotta,
    );
    final held = frame.note.cells.first.map(const Offset(0, 63)).screen;
    // Rear palm is behind the held edge; only small fingers overlap the margin.
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(held.dx - 32, held.dy - 5, 37, 18),
        const Radius.circular(8),
      ),
      Paint()..color = DemoPalette.ochre,
    );
    frame.note.paint(c, note, light);
    c.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(held.dx - 5, held.dy - 4, 11, 7),
        const Radius.circular(3),
      ),
      Paint()..color = DemoPalette.cream,
    );
    if (guides) {
      c.drawCircle(held, 3, Paint()..color = DemoPalette.indigo);
      c.drawCircle(
        frame.note.surfacePoint(const Offset(130, 63)).screen,
        3,
        Paint()..color = DemoPalette.terracotta,
      );
    }
  }
}
