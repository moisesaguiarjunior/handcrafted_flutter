import 'package:flutter/painting.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

import 'showcase_theme.dart';

/// Shared example receiver, using a borrowed texture owner.
void paintMaterialBoard(Canvas canvas, Size size, MaterialTextures textures) {
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
