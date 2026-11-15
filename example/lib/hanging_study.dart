import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

/// A synthetic assembly: supplied widgets, mixed materials and authored pivots.
/// This demonstrates API composition, not physical wind or approved app artwork.
class HangingStudy extends StatefulWidget {
  /// Creates the independent composition study.
  const HangingStudy({super.key});
  @override
  State<HangingStudy> createState() => _HangingStudyState();
}

class _HangingStudyState extends State<HangingStudy> {
  var _visit = 0;
  var _selected = '';
  bool _still = false;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text('Mixed-material assembly · authored finite motion'),
      Wrap(
        spacing: 12,
        children: [
          OutlinedButton(
            onPressed: () => setState(() => _visit++),
            child: const Text('Replay'),
          ),
          FilterChip(
            label: const Text('Still'),
            selected: _still,
            onSelected: (v) => setState(() => _still = v),
          ),
          Text(
            _selected.isEmpty
                ? 'Select a hanging piece'
                : 'Selected: $_selected',
          ),
        ],
      ),
      Center(
        child: SizedBox(
          width: 260,
          height: 240,
          child: SceneEntrance(
            key: ValueKey(_visit),
            startSettled: _still,
            builder: (context, progress) {
              final swing = math.sin(progress * math.pi * 5) * (1 - progress);
              return CraftPart(
                key: const ValueKey('assembly'),
                size: const Size(260, 230),
                pose: PartPose(rotation: swing * .08),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Positioned(
                      left: 14,
                      right: 14,
                      top: 16,
                      height: 14,
                      child: CraftSurface(
                        material: CraftMaterial.wood,
                        color: Color(0xFFC9AF82),
                      ),
                    ),
                    Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(painter: _Strings()),
                      ),
                    ),
                    for (final (id, x, material, color, sign) in [
                      (
                        'Paper',
                        15.0,
                        CraftMaterial.paper,
                        const Color(0xFFE9CF9E),
                        1.0,
                      ),
                      (
                        'Felt',
                        145.0,
                        CraftMaterial.felt,
                        const Color(0xFF9FB8B0),
                        -1.0,
                      ),
                    ])
                      Positioned(
                        left: x,
                        top: 80,
                        child: CraftPart(
                          key: ValueKey(id),
                          size: const Size(100, 90),
                          pose: PartPose(rotation: swing * sign * .2),
                          child: CraftSurface(
                            material: material,
                            color: color,
                            child: TextButton(
                              onPressed: () => setState(() => _selected = id),
                              child: Text(id),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    ],
  );
}

class _Strings extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF746356)
      ..strokeWidth = 1.5;
    for (final x in [65.0, 195.0]) {
      canvas.drawLine(Offset(x, 30), Offset(x, 80), paint);
    }
  }

  @override
  bool shouldRepaint(_Strings oldDelegate) => false;
}
