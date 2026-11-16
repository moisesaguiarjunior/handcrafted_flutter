import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

import 'showcase_theme.dart';

Path _disc(Size size) => Path()..addOval(Offset.zero & size);

/// Pure artwork; an external renderer may supply an unwrapped angle directly.
class RotaryArtwork extends StatelessWidget {
  /// Creates a decorative disc without a timer or input behavior.
  const RotaryArtwork({super.key, required this.angle});

  /// Rotation in radians; intentionally not wrapped at a full revolution.
  final double angle;
  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: IgnorePointer(
      child: SizedBox(
        width: 220,
        height: 220,
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Positioned.fill(child: CustomPaint(painter: _DialTicks())),
            CraftPart(
              key: const ValueKey('rotary-disc'),
              size: const Size(160, 160),
              pivot: Alignment.center,
              pose: PartPose(rotation: angle),
              child: CraftSurface(
                material: CraftMaterial.wood,
                color: DemoPalette.wood,
                outline: _disc,
                child: const CustomPaint(painter: _DialMark()),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _DialMark extends CustomPainter {
  const _DialMark();
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(
      Offset(size.width / 2, 20),
      7,
      Paint()..color = DemoPalette.ink,
    );
    canvas.drawCircle(
      size.center(Offset.zero),
      12,
      Paint()..color = DemoPalette.paper,
    );
    canvas.drawCircle(
      size.center(Offset.zero),
      4,
      Paint()..color = DemoPalette.ink,
    );
  }

  @override
  bool shouldRepaint(_DialMark oldDelegate) => false;
}

class _DialTicks extends CustomPainter {
  const _DialTicks();
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final paint = Paint()
      ..color = DemoPalette.ink
      ..strokeWidth = 2;
    for (var i = 0; i <= 12; i++) {
      final a = -3 * math.pi / 4 + i * math.pi / 8 - math.pi / 2;
      final direction = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(center + direction * 91, center + direction * 101, paint);
    }
  }

  @override
  bool shouldRepaint(_DialTicks oldDelegate) => false;
}

/// Native bounded stepping plus retargetable finite decorative movement.
class RotaryControlPlayground extends StatefulWidget {
  /// Host activity pauses the decorative clock; controls remain native.
  const RotaryControlPlayground({super.key, this.active = true});

  /// The application's explicit route/viewport activity policy.
  final bool active;
  @override
  State<RotaryControlPlayground> createState() =>
      _RotaryControlPlaygroundState();
}

class _RotaryControlPlaygroundState extends State<RotaryControlPlayground> {
  int _position = 0, _replay = 0;
  int? _applied;
  double _from = -3 * math.pi / 4, _shown = -3 * math.pi / 4;
  double get _target => -3 * math.pi / 4 + _position * math.pi / 8;
  void _select(int next) {
    next = next.clamp(0, 12);
    if (next == _position) return;
    setState(() {
      _from = _shown;
      _position = next;
      _replay++;
    });
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'A small wooden dial',
        style: TextStyle(fontFamily: 'Caveat', fontSize: 38),
      ),
      const Text(
        'Artwork turns; a native slider owns keyboard stepping and semantics.',
      ),
      Center(
        child: SceneEntrance(
          key: ValueKey(_replay),
          active: widget.active,
          startSettled: _replay == 0,
          duration: const Duration(milliseconds: 350),
          builder: (context, progress) {
            _shown =
                _from +
                (_target - _from) * Curves.easeOutCubic.transform(progress);
            return RotaryArtwork(angle: _shown);
          },
        ),
      ),
      Text('Position $_position of 12'),
      Slider(
        key: const ValueKey('rotary-position'),
        value: _position.toDouble(),
        min: 0,
        max: 12,
        divisions: 12,
        label: 'Position $_position',
        semanticFormatterCallback: (v) => 'Position ${v.round()} of 12',
        onChanged: (v) => _select(v.round()),
      ),
      Wrap(
        spacing: 12,
        runSpacing: 8,
        children: [
          IconButton(
            tooltip: 'Previous position',
            onPressed: _position > 0 ? () => _select(_position - 1) : null,
            icon: const Icon(Icons.remove),
          ),
          IconButton(
            tooltip: 'Next position',
            onPressed: _position < 12 ? () => _select(_position + 1) : null,
            icon: const Icon(Icons.add),
          ),
          TextButton(
            key: const ValueKey('apply-position'),
            onPressed: () => setState(() => _applied = _position),
            child: const Text('Apply position'),
          ),
        ],
      ),
      Text(
        _applied == null
            ? 'No position applied.'
            : 'Applied position $_applied.',
      ),
      const Text(
        'Applying changes only this example. No recording or persistence occurs. '
        'Reduced motion settles immediately; the disc never wraps between endpoints.',
      ),
    ],
  );
}
