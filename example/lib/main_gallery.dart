import 'package:flutter/material.dart';

import 'bounded_effects.dart';
import 'cover_studies.dart';
import 'imported_layers.dart';
import 'main_strokes.dart' show StrokePlayground;
import 'material_studies.dart';
import 'motion_studies.dart';
import 'paper_studies.dart';
import 'pendulum_studies.dart';
import 'rotary_control.dart';
import 'showcase_theme.dart';
import 'stitch_studies.dart';
import 'trim_studies.dart';

void main() {
  final requested = Uri.base.queryParameters['study'];
  runApp(
    HandcraftedGalleryApp(
      initialStudy: GalleryStudy.values.firstWhere(
        (s) => s.name == requested,
        orElse: () => GalleryStudy.cover,
      ),
    ),
  );
}

/// Hosted gallery destinations; only the visible study is mounted.
enum GalleryStudy {
  /// Opening compositions and sculpted motifs.
  cover,

  /// Five existing material algorithms.
  materials,

  /// Paper stocks, edges and finishes.
  paper,

  /// Six shared-contour thread patterns.
  stitches,

  /// Raised cord, ribbon and thread bands.
  trims,

  /// Layered pigment over supplied shapes.
  watercolor,

  /// Independently authored body/detail poses.
  motion,

  /// Bounded gravity/wind with explicit elapsed time.
  physics,

  /// Curved pen, marker and brush treatments.
  ink,

  /// Crops, hinges, masks and native actions.
  imported,

  /// Native rotary-control recipe.
  rotary,

  /// Bounded pour, droplets and light recipe.
  effects,
}

String _label(GalleryStudy study) => switch (study) {
  GalleryStudy.cover => 'Start exploring',
  GalleryStudy.materials => 'Materials & relief',
  GalleryStudy.paper => 'Paper & edges',
  GalleryStudy.stitches => 'Stitch families',
  GalleryStudy.trims => 'Cord & ribbon',
  GalleryStudy.watercolor => 'Watercolor',
  GalleryStudy.motion => 'Body, tail & tether',
  GalleryStudy.physics => 'Gravity & wind',
  GalleryStudy.ink => 'Curves & ink',
  GalleryStudy.imported => 'Imported artwork',
  GalleryStudy.rotary => 'Rotary control',
  GalleryStudy.effects => 'Pour & light',
};

/// One native navigation shell over the existing runnable studies.
class HandcraftedGalleryApp extends StatelessWidget {
  /// Selects a study explicitly; web startup also accepts ?study=enumName.
  const HandcraftedGalleryApp({
    super.key,
    this.initialStudy = GalleryStudy.cover,
  });

  /// First study; invalid URL names fall back to the cover before construction.
  final GalleryStudy initialStudy;
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'handcrafted_flutter — material studies',
    theme: showcaseTheme(),
    home: _GalleryPage(initialStudy),
  );
}

class _GalleryPage extends StatefulWidget {
  const _GalleryPage(this.initial);
  final GalleryStudy initial;
  @override
  State<_GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<_GalleryPage> {
  late GalleryStudy selected = widget.initial;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(_label(selected))),
    drawer: Drawer(
      child: SafeArea(
        child: ListView(
          children: [
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'handcrafted_flutter',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            for (final study in GalleryStudy.values)
              ListTile(
                title: Text(_label(study)),
                selected: selected == study,
                onTap: () {
                  Navigator.of(context).pop();
                  setState(() => selected = study);
                },
              ),
          ],
        ),
      ),
    ),
    body: KeyedSubtree(
      key: ValueKey(selected),
      child: selected == GalleryStudy.cover
          ? const CoverGallery()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: _content(),
                ),
              ),
            ),
    ),
  );
  Widget _content() => switch (selected) {
    GalleryStudy.cover => const CoverGallery(),
    GalleryStudy.materials => const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [MaterialsSheet(), SizedBox(height: 36), ReliefObjectsSheet()],
    ),
    GalleryStudy.paper => const PaperPlayground(),
    GalleryStudy.stitches => const StitchPlayground(),
    GalleryStudy.trims => const TrimPlayground(),
    GalleryStudy.watercolor => const WatercolorsSheet(),
    GalleryStudy.motion => const MotionPlayground(),
    GalleryStudy.physics => const PendulumPlayground(),
    GalleryStudy.ink => const StrokePlayground(),
    GalleryStudy.imported => const ImportedLayerPlayground(),
    GalleryStudy.rotary => const RotaryControlPlayground(),
    GalleryStudy.effects => const BoundedEffectsPlayground(),
  };
}
