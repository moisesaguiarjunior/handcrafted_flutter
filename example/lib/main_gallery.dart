import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'bounded_effects.dart';
import 'gallery_welcome.dart';
import 'cover_studies.dart' show ReliefObjectsSheet;
import 'gallery_catalog.dart';
import 'gallery_routes.dart';
import 'living_materials.dart';
import 'material_vocabulary.dart';
import 'experience_study.dart';

export 'gallery_catalog.dart';
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

/// A material studio with discoverable navigation and native browser history.
class HandcraftedGalleryApp extends StatefulWidget {
  /// Creates the gallery with a query-compatible initial study.
  const HandcraftedGalleryApp({
    super.key,
    this.initialStudy = GalleryStudy.cover,
  });

  /// Startup study, superseded by a valid native route.
  final GalleryStudy initialStudy;
  @override
  State<HandcraftedGalleryApp> createState() => _HandcraftedGalleryAppState();
}

class _HandcraftedGalleryAppState extends State<HandcraftedGalleryApp> {
  late final router = GalleryRouter(
    widget.initialStudy,
    (context, study, select) => _GalleryPage(study, select),
  );
  late final parser = GalleryRouteParser(widget.initialStudy);
  @override
  void dispose() {
    router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp.router(
    title: 'Handcrafted material studio',
    theme: showcaseTheme(),
    routerDelegate: router,
    routeInformationParser: parser,
  );
}

class _GalleryPage extends StatelessWidget {
  const _GalleryPage(this.selected, this.select);
  final GalleryStudy selected;
  final ValueChanged<GalleryStudy> select;
  Widget _menu({bool close = false, required BuildContext context}) => ListView(
    children: [
      const Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          'Explore the studio',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      for (final study in galleryOrder)
        ListTile(
          title: Text(galleryLabel(study)),
          selected: selected == study,
          onTap: () {
            if (close) Navigator.of(context).pop();
            select(study);
          },
        ),
    ],
  );
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) {
      final wide = box.maxWidth >= 1100;
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Handcrafted',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          actions: [
            IconButton(
              tooltip: 'Copy study link',
              icon: const Icon(Icons.link),
              onPressed: () async {
                final uri = Uri.base.replace(
                  queryParameters: {'study': selected.name},
                  fragment: '',
                );
                await Clipboard.setData(ClipboardData(text: uri.toString()));
                if (context.mounted)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Study link copied')),
                  );
              },
            ),
          ],
        ),
        drawer: wide
            ? null
            : Drawer(
                child: SafeArea(child: _menu(close: true, context: context)),
              ),
        body: Row(
          children: [
            if (wide) SizedBox(width: 248, child: _menu(context: context)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (selected != GalleryStudy.experience)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      child: wide
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  galleryLabel(selected),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(galleryDescription(selected)),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text('Explore a study'),
                                PopupMenuButton<GalleryStudy>(
                                  key: const ValueKey('mobile-study-picker'),
                                  tooltip: 'Explore a study',
                                  initialValue: selected,
                                  onSelected: select,
                                  itemBuilder: (context) => [
                                    for (final study in galleryOrder)
                                      PopupMenuItem(
                                        value: study,
                                        child: Text(galleryLabel(study)),
                                      ),
                                  ],
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            galleryLabel(selected),
                                            key: const ValueKey(
                                              'mobile-study-label',
                                            ),
                                            style: const TextStyle(
                                              fontSize: 20,
                                            ),
                                          ),
                                        ),
                                        const Icon(Icons.arrow_drop_down),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  Expanded(
                    child: KeyedSubtree(
                      key: ValueKey(selected),
                      child: _body(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
  Widget _body() {
    final content = _content();
    if (selected == GalleryStudy.cover ||
        selected == GalleryStudy.ink ||
        selected == GalleryStudy.experience)
      return content;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: content,
        ),
      ),
    );
  }

  Widget _content() => switch (selected) {
    GalleryStudy.experience => const ExperienceFrameStudy(),
    GalleryStudy.vocabulary => const MaterialVocabularyStudy(),
    GalleryStudy.cover => GalleryWelcome(select: select),
    GalleryStudy.materials => const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [MaterialsSheet(), SizedBox(height: 36), ReliefObjectsSheet()],
    ),
    GalleryStudy.paper => const PaperPlayground(),
    GalleryStudy.stitches => const StitchPlayground(),
    GalleryStudy.trims => const TrimPlayground(),
    GalleryStudy.watercolor => const WatercolorsSheet(),
    GalleryStudy.spreading => const LivingMaterialStudy(
      technique: LivingTechnique.watercolor,
    ),
    GalleryStudy.embroidery => const LivingMaterialStudy(
      technique: LivingTechnique.embroidery,
    ),
    GalleryStudy.motion => const MotionPlayground(),
    GalleryStudy.physics => const PendulumPlayground(),
    GalleryStudy.ink => const StrokePlayground(),
    GalleryStudy.imported => const ImportedLayerPlayground(),
    GalleryStudy.rotary => const RotaryControlPlayground(),
    GalleryStudy.effects => const BoundedEffectsPlayground(),
  };
}
