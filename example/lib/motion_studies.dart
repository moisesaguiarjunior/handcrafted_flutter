import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:handcrafted_flutter/handcrafted_flutter.dart';

import 'kite_art.dart';
import 'showcase_theme.dart';

/// Authored actors, separate from any generic physics or scene architecture.
enum MotionSubject {
  /// Paper sail and locally deforming ribbon tail.
  kite,

  /// Paper balloon with a tether following its moving tie point.
  balloon,
}

/// A pure, finite sway pose. Both ends settle at identity.
PartPose studySway(double progress) {
  if (!progress.isFinite || progress < 0 || progress > 1) {
    throw ArgumentError('Expected progress 0..1');
  }
  if (progress == 0 || progress == 1) return PartPose();
  final envelope = math.sin(math.pi * progress);
  return PartPose(
    translation: Offset(
      math.sin(progress * math.pi * 3) * 22 * envelope,
      -18 * envelope,
    ),
    rotation: math.sin(progress * math.pi * 5) * .2 * envelope,
  );
}

/// A slower, buoyant authored drift, deliberately different from the kite.
PartPose studyBalloonDrift(double progress) {
  if (!progress.isFinite || progress < 0 || progress > 1) {
    throw ArgumentError('Expected progress 0..1');
  }
  if (progress == 0 || progress == 1) return PartPose();
  final envelope = math.sin(math.pi * progress);
  return PartPose(
    translation: Offset(
      math.sin(progress * math.pi * 1.2) * 13 * envelope,
      -34 * envelope,
    ),
    rotation: math.sin(progress * math.pi * 1.4) * .065 * envelope,
  );
}

/// Decorative artwork at independent body/detail poses, with no internal clock.
/// Scale only the artwork; captions and controls remain ordinary widgets.
class MotionSample extends StatelessWidget {
  /// Creates an explicit-pose actor sample.
  const MotionSample({
    super.key,
    required this.subject,
    this.bodyProgress = 1,
    this.detailProgress = 1,
  });

  /// Which authored example to draw.
  final MotionSubject subject;

  /// Body sway progress, 0..1.
  final double bodyProgress;

  /// Independent tail or tether shape progress, 0..1.
  final double detailProgress;

  @override
  Widget build(BuildContext context) {
    final pose = subject == MotionSubject.balloon
        ? studyBalloonDrift(bodyProgress)
        : studySway(bodyProgress);
    if (!detailProgress.isFinite || detailProgress < 0 || detailProgress > 1) {
      throw ArgumentError('Expected detail progress 0..1');
    }
    return AspectRatio(
      aspectRatio: 440 / 340,
      child: FittedBox(
        child: SizedBox(
          width: 440,
          height: 340,
          child: switch (subject) {
            MotionSubject.kite => CraftPart(
              key: const ValueKey('moving-kite-body'),
              size: const Size(440, 340),
              pose: pose,
              pivot: const Alignment(.26, 176 / 340 - 1),
              child: KiteArt(progress: detailProgress, artScale: 1.6),
            ),
            MotionSubject.balloon => _Balloon(
              pose: pose,
              detail: detailProgress,
            ),
          },
        ),
      ),
    );
  }
}

class _Balloon extends StatefulWidget {
  const _Balloon({required this.pose, required this.detail});
  final PartPose pose;
  final double detail;
  @override
  State<_Balloon> createState() => _BalloonState();
}

class _BalloonState extends State<_Balloon> {
  final textures = MaterialTextures(seed: 31);
  @override
  void dispose() {
    textures.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _BalloonPainter(textures, widget.pose, widget.detail),
  );
}

class _BalloonPainter extends CustomPainter {
  _BalloonPainter(this.textures, this.pose, this.detail);
  final MaterialTextures textures;
  final PartPose pose;
  final double detail;
  @override
  void paint(Canvas canvas, Size size) {
    const local = Size(112, 144);
    const origin = Offset(174, 42);
    final tie =
        pose.mapPoint(
          const Offset(56, 148),
          size: local,
          pivot: Alignment.center,
        ) +
        origin;
    final wave =
        math.sin(detail * math.pi * 2) * math.sin(detail * math.pi) * 9;
    final tether = Path()
      ..moveTo(tie.dx, tie.dy)
      ..cubicTo(tie.dx + wave, tie.dy + 32, 115 - wave, 251, 146, 304);
    paintCraftStroke(
      canvas,
      tether,
      color: DemoPalette.ink,
      style: const CraftStrokeStyle(width: 1.3),
    );
    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    canvas.transform(pose.matrixFor(local, Alignment.center).storage);
    final body = Path()..addOval(Offset.zero & local);
    textures.paint(
      canvas,
      body,
      material: CraftMaterial.paper,
      color: const Color(0xFFE7B8A5),
    );
    paintWatercolor(
      canvas,
      body,
      pigment: const Color(0xFFC47A80),
      companion: const Color(0xFFE0AB64),
      paper: const Color(0xFFE7B8A5),
      seed: 31,
      opacity: .45,
    );
    final seam = Path()
      ..moveTo(56, 1)
      ..cubicTo(20, 35, 25, 111, 56, 142)
      ..moveTo(56, 1)
      ..cubicTo(88, 30, 88, 110, 56, 142);
    paintCraftStroke(
      canvas,
      seam,
      color: const Color(0xFFB57972),
      style: const CraftStrokeStyle(width: 1),
    );
    final knot = Path()
      ..moveTo(56, 141)
      ..lineTo(50, 150)
      ..lineTo(62, 150)
      ..close();
    canvas.drawPath(knot, Paint()..color = const Color(0xFFB57972));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_BalloonPainter old) =>
      old.pose != pose || old.detail != detail || old.textures != textures;
}

/// Interactive finite motion controls; idle/return visits start in a still pose.
class MotionPlayground extends StatefulWidget {
  /// Creates the motion study.
  const MotionPlayground({super.key});
  @override
  State<MotionPlayground> createState() => _MotionPlaygroundState();
}

class _MotionPlaygroundState extends State<MotionPlayground> {
  MotionSubject _subject = MotionSubject.kite;
  double? _body = 1, _detail = 1;
  bool _bodyEnabled = true, _detailEnabled = true;
  int _replay = 0;
  @override
  Widget build(BuildContext context) => SceneEntrance(
    key: ValueKey(_replay),
    duration: Duration(
      milliseconds: _subject == MotionSubject.balloon ? 6500 : 3600,
    ),
    active:
        (_bodyEnabled && _body == null) || (_detailEnabled && _detail == null),
    startSettled: _body != null && _detail != null,
    builder: (context, progress) {
      final body = _bodyEnabled ? _body ?? progress : 1.0;
      final detail = _detailEnabled ? _detail ?? progress : 1.0;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              for (final subject in MotionSubject.values)
                ChoiceChip(
                  label: Text(switch (subject) {
                    MotionSubject.kite => 'Kite',
                    MotionSubject.balloon => 'Balloon',
                  }),
                  selected: _subject == subject,
                  onSelected: (_) => setState(() => _subject = subject),
                ),
            ],
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Semantics(
                image: true,
                label: 'Authored ${_subject.name} motion',
                child: MotionSample(
                  subject: _subject,
                  bodyProgress: body,
                  detailProgress: detail,
                ),
              ),
            ),
          ),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilterChip(
                label: const Text('Body motion'),
                selected: _bodyEnabled,
                onSelected: (v) => setState(() => _bodyEnabled = v),
              ),
              FilterChip(
                label: Text(
                  _subject == MotionSubject.kite
                      ? 'Tail motion'
                      : 'Tether motion',
                ),
                selected: _detailEnabled,
                onSelected: (v) => setState(() => _detailEnabled = v),
              ),
              FilledButton(
                onPressed: () => setState(() {
                  _body = null;
                  _detail = null;
                  _replay++;
                }),
                child: const Text('Play motion'),
              ),
              OutlinedButton(
                onPressed: () => setState(() {
                  _body = 1;
                  _detail = 1;
                }),
                child: const Text('Still pose'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Body ${(body * 100).round()}%'),
          Slider(
            key: const ValueKey('motion-body'),
            value: body,
            onChanged: (v) => setState(() {
              _bodyEnabled = true;
              _body = v;
            }),
          ),
          Text(
            '${_subject == MotionSubject.kite ? 'Tail' : 'Tether'} ${(detail * 100).round()}%',
          ),
          Slider(
            key: const ValueKey('motion-detail'),
            value: detail,
            onChanged: (v) => setState(() {
              _detailEnabled = true;
              _detail = v;
            }),
          ),
          const Text(
            'Each movement is authored and finite. Body and detail can be '
            'scrubbed independently. System reduced motion settles automatic playback.',
          ),
        ],
      );
    },
  );
}

/// Four explicit-pose comparisons shared by the gallery and GIF capture.
class MotionAtlas extends StatelessWidget {
  /// Creates a synchronized comparison without starting a clock.
  const MotionAtlas({super.key, required this.progress});

  /// Explicit normalized capture time.
  final double progress;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth < 620 ? 1 : 2;
      final width = (constraints.maxWidth - (columns - 1) * 24) / columns;
      return Wrap(
        spacing: 24,
        runSpacing: 20,
        children: [
          for (final sample in [
            ('Kite body', MotionSubject.kite, progress, 1.0),
            ('Kite tail', MotionSubject.kite, 1.0, progress),
            ('Together', MotionSubject.kite, progress, progress),
            ('Balloon & tether', MotionSubject.balloon, progress, progress),
          ])
            SizedBox(
              width: width,
              child: Column(
                children: [
                  Text(
                    sample.$1,
                    style: const TextStyle(fontFamily: 'Caveat', fontSize: 30),
                  ),
                  MotionSample(
                    subject: sample.$2,
                    bodyProgress: sample.$3,
                    detailProgress: sample.$4,
                  ),
                ],
              ),
            ),
        ],
      );
    },
  );
}

/// Two actors on one supplied timeline: a quick gust and a slower drift.
class MotionStage extends StatelessWidget {
  /// No clock is created; progress spans seven authored seconds.
  const MotionStage({super.key, required this.progress});

  /// Explicit finite scene progress.
  final double progress;
  @override
  Widget build(BuildContext context) {
    if (!progress.isFinite || progress < 0 || progress > 1) {
      throw ArgumentError('Expected progress 0..1');
    }
    final kite = (progress * 1.75).clamp(0.0, 1.0);
    return AspectRatio(
      aspectRatio: 1000 / 420,
      child: FittedBox(
        child: SizedBox(
          width: 1000,
          height: 420,
          child: Stack(
            children: [
              Positioned(
                left: 20,
                top: 35,
                width: 440,
                height: 340,
                child: MotionSample(
                  subject: MotionSubject.kite,
                  bodyProgress: kite,
                  detailProgress: kite,
                ),
              ),
              Positioned(
                left: 505,
                top: 30,
                width: 440,
                height: 340,
                child: MotionSample(
                  subject: MotionSubject.balloon,
                  bodyProgress: progress,
                  detailProgress: progress,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
